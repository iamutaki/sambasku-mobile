import 'dart:developer' as developer;

import 'package:fpdart/fpdart.dart';

import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../ports/google_sign_in_port.dart';
import '../repositories/auth_repository.dart';

/// Google Sign-In. Batal sheet → `AuthFailure` dengan
/// [AuthFailure.googleSignInCanceled] (toast, bukan alert form).
class LoginWithGoogleUseCase {
  const LoginWithGoogleUseCase(this._repository, this._signIn);

  final AuthRepository _repository;
  final GoogleSignInPort _signIn;

  Future<Either<AuthFailure, AuthSession>> call() async {
    try {
      final idToken = await _signIn.authenticate();
      if (idToken == null) {
        return Either.left(
          const AuthFailure(
            'Masuk dibatalkan.',
            errorCode: AuthFailure.googleSignInCanceled,
          ),
        );
      }
      if (idToken.trim().isEmpty) {
        return Either.left(
          const AuthFailure(
            'Tidak bisa masuk dengan Google.',
            errorCode: 'INVALID_GOOGLE_TOKEN',
          ),
        );
      }
      return _repository.loginWithGoogle(idToken: idToken);
    } catch (error, stack) {
      developer.log(
        'loginWithGoogle gagal',
        name: 'auth.google',
        error: error,
        stackTrace: stack,
      );
      final message = error is StateError
          ? error.message
          : 'Tidak bisa masuk dengan Google. Coba lagi.';
      final safe = message.contains('SHA') || message.length > 120
          ? 'Tidak bisa masuk dengan Google. Coba lagi.'
          : message;
      return Either.left(AuthFailure(safe));
    }
  }
}
