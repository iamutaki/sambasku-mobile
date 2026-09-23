import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/env.dart';
import '../domain/ports/google_sign_in_port.dart';

class GoogleSignInAdapter implements GoogleSignInPort {
  bool _initialized = false;

  @override
  Future<String?> authenticate() async {
    final serverClientId = Env.googleWebClientId?.trim();
    if (serverClientId == null || serverClientId.isEmpty) {
      throw StateError(
        'Masuk dengan Google belum siap di perangkat ini. Coba lagi nanti.',
      );
    }

    try {
      if (!_initialized) {
        await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
        _initialized = true;
      }

      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'openid', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.trim().isEmpty) {
        throw StateError('ID token Google kosong setelah akun dipilih.');
      }
      return idToken;
    } on GoogleSignInException catch (error, stack) {
      _log('GoogleSignInException code=${error.code}', error, stack);

      // User dismiss / batal / interrupt → null (toast "dibatalkan" di UI).
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }

      if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
        _log(
          'clientConfigurationError — cek SHA-1 debug + package '
          'com.iamutaki.sambasku.staging di GCP (Web client ID yang sama)',
          error,
          stack,
        );
        throw StateError(
          'Masuk dengan Google belum siap di perangkat ini. Coba lagi nanti.',
        );
      }

      throw StateError('Tidak bisa masuk dengan Google. Coba lagi.');
    } catch (error, stack) {
      _log('authenticate gagal', error, stack);
      rethrow;
    }
  }

  void _log(String message, Object error, StackTrace stack) {
    debugPrint('[auth.google] $message: $error');
    developer.log(
      message,
      name: 'auth.google',
      error: error,
      stackTrace: stack,
    );
  }
}
