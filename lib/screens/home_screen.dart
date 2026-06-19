import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_theme.dart';
import '../models/bank_data.dart';
import '../services/api_service.dart';
import '../widgets/bank_loader.dart';
import 'package:bank_scan/myapp.dart';
import 'scan_data_extraction_screen.dart';
import 'home/image_sections/welcome_header.dart';
import 'home/image_sections/scan_document_section.dart';
import 'home/image_sections/source_section.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onExtractionScreenShown;
  final VoidCallback? onExtractionScreenHidden;

  const HomeScreen({
    super.key,
    this.onExtractionScreenShown,
    this.onExtractionScreenHidden,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  BankData? _bankData;
  String? _imagePath;
  bool _isProcessing = false;
  bool _isSaving = false;
  bool _wasShowingExtraction = false;
  String? _userName;
  bool _isCapturingCamera = false;

  @override
  void initState() {
    super.initState();
    // Check static variable first (set during login)
    _userName = MyApp.userName;
    // Also load from SharedPreferences as fallback
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    await MyApp.loadUserData();
    if (mounted) {
      setState(() {
        _userName = MyApp.userName ?? _userName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isShowingExtraction = _bankData != null && _imagePath != null;

    // Check if user name is available in static variable and update if needed
    if (MyApp.userName != null && MyApp.userName != _userName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _userName = MyApp.userName;
          });
        }
      });
    }

    // Notify state changes
    if (isShowingExtraction && !_wasShowingExtraction) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onExtractionScreenShown?.call();
      });
      _wasShowingExtraction = true;
    } else if (!isShowingExtraction && _wasShowingExtraction) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onExtractionScreenHidden?.call();
      });
      _wasShowingExtraction = false;
    }

    // Show loader when processing
    if (_isProcessing) {
      // Notify that extraction screen is shown (to hide bottom nav)
      if (!_wasShowingExtraction) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onExtractionScreenShown?.call();
        });
      }
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        body: const BankLoader(message: 'Processing your document...'),
      );
    }

    // Show home screen with conditional content
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Column(
        children: [
          // Welcome Header (only show when not showing extraction)
          if (!isShowingExtraction) WelcomeHeader(userName: _userName),
          // Main Content
          Expanded(
            child: isShowingExtraction
                ? ScanDataExtractionScreen(
                    bankData: _bankData!,
                    imagePath: _imagePath!,
                    onSaveSuccess: () {
                      setState(() {
                        _bankData = null;
                        _imagePath = null;
                        _selectedImage = null;
                      });
                    },
                    onBack: () {
                      setState(() {
                        _bankData = null;
                        _imagePath = null;
                        _selectedImage = null;
                      });
                    },
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Scan the Document Section
                        ScanDocumentSection(
                          selectedImage: _selectedImage,
                          isProcessing: _isProcessing,
                          onTap: () => _showImageSourceDialog(context),
                        ),
                        const SizedBox(height: 24),
                        // Source Section
                        SourceSection(
                          onCameraTap: _captureFromCamera,
                          onGalleryTap: _pickFromGallery,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppTheme.primaryBlue,
                ),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _captureFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppTheme.primaryBlue,
                ),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Capture image from camera
  /// Let image_picker handle permissions automatically to avoid conflicts
  Future<void> _captureFromCamera() async {
    // Prevent multiple simultaneous camera calls
    if (_isCapturingCamera || _isProcessing) {
      return;
    }

    try {
      if (!mounted) return;
      
      _isCapturingCamera = true;
      setState(() => _isProcessing = true);

      // Open camera - image_picker handles permission requests automatically
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 75,
      );

      if (!mounted) return;

      if (image != null) {
        // Process the captured image
        await _processImage(image);
      } else {
        setState(() => _isProcessing = false);
        widget.onExtractionScreenHidden?.call();
      }
    } catch (e) {
      print('Camera error: $e');
      if (!mounted) return;
      setState(() => _isProcessing = false);
      widget.onExtractionScreenHidden?.call();
      
      // Don't show error for permission or cancellation errors
      final errorMsg = e.toString().toLowerCase();
      if (!errorMsg.contains('permission') &&
          !errorMsg.contains('camera') &&
          !errorMsg.contains('cancel') &&
          !errorMsg.contains('multiple_request')) {
        _showError('Failed to capture image. Please try again.');
      }
    } finally {
      _isCapturingCamera = false;
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() => _isProcessing = true);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 75,
      );

      if (image != null) {
        // Process the image directly
        await _processImage(image);
      } else {
        setState(() => _isProcessing = false);
        // Show bottom nav again if cancelled
        widget.onExtractionScreenHidden?.call();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      // Show bottom nav again on error
      widget.onExtractionScreenHidden?.call();
      _showError('Gallery Error: $e');
    }
  }

  /// Process the image
  Future<void> _processImage(XFile image) async {
    try {
      setState(() {
        _selectedImage = image;
        _isProcessing = true;
      });

      // Upload and extract data
      final response = await ApiService.uploadImage(File(image.path));
      final bankData = BankData.fromJson(response);

      if (mounted) {
        setState(() {
          _bankData = bankData;
          _imagePath = image.path;
          _isProcessing = false;
        });
        // Processing complete, extraction screen will be shown
        // Bottom nav will be hidden by the extraction screen shown callback
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        widget.onExtractionScreenHidden?.call();
        _showError('Request timed out. Please check your internet connection and try again.');
      }
    } on SocketException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        widget.onExtractionScreenHidden?.call();
        _showError('Network error. Please check your internet connection.');
      }
    } on HttpException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        widget.onExtractionScreenHidden?.call();
        _showError('Server error: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        // Show bottom nav again if processing failed
        widget.onExtractionScreenHidden?.call();
        String errorMessage = 'Processing Error: $e';
        if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
          errorMessage = 'Request timed out. Please try again.';
        } else if (e.toString().contains('SocketException') || e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (e.toString().contains('too large') || e.toString().contains('413')) {
          errorMessage = 'Image file is too large. Please use a smaller image or reduce the image quality.';
        }
        _showError(errorMessage);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.successColor),
    );
  }
}
