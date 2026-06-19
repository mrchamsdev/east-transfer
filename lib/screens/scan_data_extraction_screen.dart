import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/bank_loader.dart';
import '../models/bank_data.dart';
import '../services/api_service.dart';

class ScanDataExtractionScreen extends StatefulWidget {
  final BankData bankData;
  final String imagePath;
  final VoidCallback? onSaveSuccess;
  final VoidCallback? onBack;

  const ScanDataExtractionScreen({
    super.key,
    required this.bankData,
    required this.imagePath,
    this.onSaveSuccess,
    this.onBack,
  });

  @override
  State<ScanDataExtractionScreen> createState() =>
      _ScanDataExtractionScreenState();

  static Future<void> navigateTo(
    BuildContext context, {
    required BankData bankData,
    required String imagePath,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ScanDataExtractionScreen(bankData: bankData, imagePath: imagePath),
        fullscreenDialog: true,
      ),
    );
  }
}

class _ScanDataExtractionScreenState extends State<ScanDataExtractionScreen> {
  late TextEditingController _customerNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscCodeController;
  late TextEditingController _dateController;
  late TextEditingController _nicknameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _aadharController;
  late TextEditingController _panController;
  late TextEditingController _commentController;
  late TextEditingController _amountToPayController;

  bool _isSaving = false;
  DateTime? _selectedDate;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }

  String _formatDateForApi(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year-$month-$day';
  }

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(
      text: widget.bankData.accountHolderName,
    );
    _accountNumberController = TextEditingController(
      text: widget.bankData.accountNumber,
    );
    _ifscCodeController = TextEditingController(text: widget.bankData.ifscCode);
    _selectedDate = DateTime.now();
    _dateController = TextEditingController(text: _formatDate(_selectedDate!));
    _nicknameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _aadharController = TextEditingController();
    _panController = TextEditingController();
    _commentController = TextEditingController();
    _amountToPayController = TextEditingController();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _dateController.dispose();
    _nicknameController.dispose();
    _phoneNumberController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _commentController.dispose();
    _amountToPayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100), // Allow future dates for future transactions
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _saveDetails() async {
    if (_customerNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _ifscCodeController.text.isEmpty ||
        _selectedDate == null ||
        _amountToPayController.text.isEmpty) {
      _showSnackBar('Please fill all required fields', false);
      return;
    }

    // Validate phone number (10 digits)
    final phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.isNotEmpty &&
        (phoneNumber.length != 10 ||
            !RegExp(r'^[0-9]+$').hasMatch(phoneNumber))) {
      _showSnackBar('Please enter a valid 10-digit phone number', false);
      return;
    }

    // Validate Aadhar number (12 digits)
    final aadharNumber = _aadharController.text.trim();
    if (aadharNumber.isNotEmpty &&
        (aadharNumber.length != 12 ||
            !RegExp(r'^[0-9]+$').hasMatch(aadharNumber))) {
      _showSnackBar('Please enter a valid 12-digit Aadhar number', false);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final photoFile = File(widget.imagePath);
      if (!await photoFile.exists()) {
        _showSnackBar('Photo file not found', false);
        setState(() => _isSaving = false);
        return;
      }

      final success = await ApiService.addPayment(
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscCodeController.text.trim(),
        customerName: _customerNameController.text.trim(),
        paymentDate: _formatDateForApi(_selectedDate!),
        amountToPay: _amountToPayController.text.trim(),
        photo: photoFile,
        bankName: widget.bankData.branchName.isNotEmpty
            ? widget.bankData.branchName
            : null,
        nickname: _nicknameController.text.trim().isNotEmpty
            ? _nicknameController.text.trim()
            : null,
        phoneNumber: _phoneNumberController.text.trim().isNotEmpty
            ? _phoneNumberController.text.trim()
            : null,
        panNumber: _panController.text.trim().isNotEmpty
            ? _panController.text.trim()
            : null,
        aadhaarNumber: _aadharController.text.trim().isNotEmpty
            ? _aadharController.text.trim()
            : null,
        comments: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
        bankInfoId: null, // Can be added later if needed
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          _showSnackBar('Payment details saved successfully!', true);
          // Wait a bit for the snackbar to show, then handle navigation/callback
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              // If callback is provided (embedded mode), use it
              if (widget.onSaveSuccess != null) {
                widget.onSaveSuccess!();
              } else {
                // Otherwise, pop back (navigation mode)
                Navigator.of(context).pop();
              }
            }
          });
        } else {
          _showSnackBar('Failed to save payment details', false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar('Error: $e', false);
      }
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? AppTheme.successColor
            : AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {
            // If callback is provided (embedded mode), use it
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              // Otherwise, pop back (navigation mode)
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Scan Document',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightBlueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Extraction completed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verify and edit details below.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Form Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _customerNameController,
                      label: 'Customer Name',
                      icon: Icons.person_outline,
                      placeholder: 'Enter customer name here',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _accountNumberController,
                      label: 'Account Number',
                      icon: Icons.account_balance_outlined,
                      placeholder: 'Enter account number here',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _ifscCodeController,
                      label: 'IFSC Code',
                      icon: Icons.credit_card_outlined,
                      placeholder: 'Enter IFSC code here',
                    ),
                    const SizedBox(height: 20),
                    _buildDateField(),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _amountToPayController,
                      label: 'Amount to Pay',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      placeholder: 'Enter amount here',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _nicknameController,
                      label: 'Nickname (Optional)',
                      icon: Icons.person_outline,
                      isOptional: true,
                      placeholder: 'Add a nickname here',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _phoneNumberController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isOptional: true,
                      placeholder: 'Enter your phone number here',
                      maxLength: 10,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _aadharController,
                      label: 'Aadhar Number',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      isOptional: true,
                      placeholder: 'Enter your Aadhar number here',
                      maxLength: 12,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _panController,
                      label: 'PAN Number',
                      icon: Icons.credit_card_outlined,
                      isOptional: true,
                      placeholder: 'Enter your PAN number here',
                    ),
                    const SizedBox(height: 16),
                    _buildCommentField(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Save Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: RefreshLoader(
                            size: 24,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save to sheet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isOptional = false,
    TextInputType? keyboardType,
    String? placeholder,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey[600],
              size: 20,
            ),
            suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Comment (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Add any notes...',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Icon(
                Icons.comment_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
