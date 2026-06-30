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
  bool _isFaceIdEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final faceEnabled = await _secureStorage.read(key: 'isFaceEnabled');
    final bioEnabled = await _secureStorage.read(key: 'isBiometricEnabled');

    if (mounted) {
      setState(() {
        _isFaceIdEnabled = faceEnabled == 'true';
        _isBiometricEnabled = bioEnabled == 'true';
      });
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
      setState(() => _isLoading = true);
      await _secureStorage.delete(key: 'isFaceEnabled');
      setState(() {
        _isFaceIdEnabled = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (!availableBiometrics.contains(BiometricType.face) && !availableBiometrics.contains(BiometricType.strong)) {
        _showError('Face Recognition is not available on this device. Please use Fingerprint.');
        setState(() {
          _isFaceIdEnabled = false;
          _isLoading = false;
        });
        return;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable Face ID',
      );

      if (didAuthenticate) {
        setState(() => _isLoading = true);
        final token = GoldSession.instance.token;
        if (token == null) {
          _showError('Session expired.');
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
          _showError(faceRes.message ?? 'Failed to enable Face ID.');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    if (_isLoading) return;

    if (!enable) {
      setState(() => _isLoading = true);
      await _secureStorage.delete(key: 'isBiometricEnabled');
      setState(() {
        _isBiometricEnabled = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (!availableBiometrics.contains(BiometricType.fingerprint) && !availableBiometrics.contains(BiometricType.strong)) {
        _showError('Fingerprint is not available on this device. Please use Face ID.');
        setState(() {
          _isBiometricEnabled = false;
          _isLoading = false;
        });
        return;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable Biometric',
      );

      if (didAuthenticate) {
        setState(() => _isLoading = true);
        final token = GoldSession.instance.token;
        if (token == null) {
          _showError('Session expired.');
          setState(() => _isLoading = false);
          return;
        }

        final deviceId = await _getDeviceId();
        final bioRes = await FaceAuthRepository.instance.enableBiometric(token, deviceId);

        if (bioRes.isSuccess) {
          await _secureStorage.write(key: 'isBiometricEnabled', value: 'true');
          await _secureStorage.write(key: 'biometricDeviceId', value: deviceId);
          setState(() => _isBiometricEnabled = true);
        } else {
          _showError(bioRes.message ?? 'Failed to enable Biometric.');
        }
      }
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
          'Security Settings',
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
                'Enabling security features allows you to log into\nM-Pesa and authorise transactions',
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enable Biometric (Fingerprint)',
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
                          value: _isBiometricEnabled,
                          activeColor: const Color(0xFF00B0FF),
                          onChanged: _toggleBiometric,
                        ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
