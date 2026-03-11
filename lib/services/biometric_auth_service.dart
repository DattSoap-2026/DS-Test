import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../utils/app_logger.dart';

class BiometricCredentials {
  final String email;
  final String password;

  const BiometricCredentials({required this.email, required this.password});
}

class BiometricAvailability {
  final bool available;
  final bool hasHardwareSupport;
  final bool hasEnrolledBiometrics;

  const BiometricAvailability({
    required this.available,
    required this.hasHardwareSupport,
    required this.hasEnrolledBiometrics,
  });
}

class BiometricAuthService {
  static const String _emailKey = 'biometric_login_email_v1';
  static const String _passwordKey = 'biometric_login_password_v1';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final LocalAuthentication _auth = LocalAuthentication();

  Future<BiometricAvailability> getAvailability() async {
    try {
      final hardwareSupported = await _auth.isDeviceSupported();
      final canCheckBiometric = await _auth.canCheckBiometrics;
      final enrolledTypes = await _auth.getAvailableBiometrics();
      final hasEnrolledBiometrics =
          canCheckBiometric || enrolledTypes.isNotEmpty;

      return BiometricAvailability(
        available: hardwareSupported && hasEnrolledBiometrics,
        hasHardwareSupport: hardwareSupported,
        hasEnrolledBiometrics: hasEnrolledBiometrics,
      );
    } on PlatformException catch (e, s) {
      AppLogger.warning(
        'Biometric availability check failed: ${e.code} ${e.message}',
        tag: 'Auth',
      );
      AppLogger.error('Biometric availability error', error: e, stackTrace: s);
      return const BiometricAvailability(
        available: false,
        hasHardwareSupport: false,
        hasEnrolledBiometrics: false,
      );
    }
  }

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      return;
    }
    await _storage.write(key: _emailKey, value: normalizedEmail);
    await _storage.write(key: _passwordKey, value: password);
  }

  Future<BiometricCredentials?> readCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    if (email == null || email.trim().isEmpty) return null;
    if (password == null || password.isEmpty) return null;
    return BiometricCredentials(email: email.trim(), password: password);
  }

  Future<bool> hasStoredCredentials() async {
    final creds = await readCredentials();
    return creds != null;
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }

  Future<bool> authenticateForLogin() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to sign in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } on PlatformException catch (e, s) {
      AppLogger.warning(
        'Biometric authentication failed: ${e.code} ${e.message}',
        tag: 'Auth',
      );
      AppLogger.error('Biometric auth error', error: e, stackTrace: s);
      return false;
    }
  }
}
