import 'package:local_auth/local_auth.dart';
void main() {
  final auth = LocalAuthentication();
  auth.authenticate(
    localizedReason: 'Test',
    biometricOnly: true,
  );
}
