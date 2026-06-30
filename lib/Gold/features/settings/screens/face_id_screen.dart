import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/gold_session.dart';
import '../../auth/repository/face_auth_repository.dart';
import '../../../widgets/gold_back_button.dart';

class FaceIdScreen extends StatefulWidget {
  const FaceIdScreen({super.key});

  @override
  State<FaceIdScreen> createState() => _FaceIdScreenState();
}

class _FaceIdScreenState extends State<FaceIdScreen> {
  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  bool _isFaceIdEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final enabled = await _secureStorage.read(key: 'isFaceEnabled');
    final deviceId = await _secureStorage.read(key: 'biometricDeviceId');

    if (enabled == 'false') {
      if (mounted) {
        setState(() {
          _isFaceIdEnabled = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isFaceIdEnabled = true;
      });
    }

    if (enabled != 'true' || deviceId == null) {
      try {
        final canCheck = await _localAuth.canCheckBiometrics;
        final isSupported = await _localAuth.isDeviceSupported();
        if (canCheck && isSupported) {
          final token = GoldSession.instance.token;
          if (token != null && token.isNotEmpty) {
            final newDeviceId = await _getDeviceId();
            final res = await FaceAuthRepository.instance.enableFace(token, newDeviceId);
            if (res.isSuccess) {
              await _secureStorage.write(key: 'isFaceEnabled', value: 'true');
              await _secureStorage.write(key: 'biometricDeviceId', value: newDeviceId);
            }
          }
        }
      } catch (e) {
        debugPrint('Silent auto-register in settings failed: $e');
      }
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios_id';
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleFaceId(bool enable) async {
    if (_isLoading) return;

    if (!enable) {
      // Disabling Face ID
      setState(() => _isLoading = true);
      await _secureStorage.delete(key: 'isFaceEnabled');
      await _secureStorage.delete(key: 'biometricDeviceId');
      setState(() {
        _isFaceIdEnabled = false;
        _isLoading = false;
      });
      return;
    }

    // Enabling Face ID
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        _showError('Biometric authentication is not supported on this device.');
        return;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable Face ID',
      );

      if (didAuthenticate) {
        setState(() => _isLoading = true);
        final token = GoldSession.instance.token;
        if (token == null || token.isEmpty) {
          _showError('Session expired. Please login again.');
          setState(() => _isLoading = false);
          return;
        }

        final deviceId = await _getDeviceId();
        final faceRes = await FaceAuthRepository.instance.enableFace(token, deviceId);

        if (faceRes.isSuccess) {
          await _secureStorage.write(key: 'isFaceEnabled', value: 'true');
          await _secureStorage.write(key: 'biometricDeviceId', value: deviceId);
          setState(() => _isFaceIdEnabled = true);
        } else {
          _showError(faceRes.message ?? 'Failed to enable Face ID on server.');
        }
      }
    } catch (e) {
      _showError('Authentication error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: GoldBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Face ID',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enabling Face ID allows you to log into\nM-Pesa and authorise transactions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enable Face ID',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  _isLoading
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : CupertinoSwitch(
                          value: _isFaceIdEnabled,
                          activeColor: const Color(0xFF00B0FF),
                          onChanged: _toggleFaceId,
                        ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: 'PIN entry Face ID is ',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  children: [
                    TextSpan(
                      text: _isFaceIdEnabled ? 'switched on' : 'switched off',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please note that any biometric stored on your device can be used to log into M-Pesa. You can switch off Face ID and return to PIN usage at anytime',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
