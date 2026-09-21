import 'package:fpdart/fpdart.dart';

import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../ports/facebook_sign_in_port.dart';
import '../repositories/auth_repository.dart';

/// `null` = user batal di sheet Facebook (bukan failure).
class LoginWithFacebookUseCase {
  const LoginWithFacebookUseCase(this._repository, this._signIn);

  final AuthRepository _repository;
  final FacebookSignInPort _signIn;

  Future<Either<AuthFailure, AuthSession>?> call() async {
    try {
      final accessToken = await _signIn.authenticate();
      if (accessToken == null) return null;
      if (accessToken.trim().isEmpty) {
        return Either.left(
          const AuthFailure(
            'Tidak bisa masuk dengan Facebook.',
            errorCode: 'INVALID_FACEBOOK_TOKEN',
          ),
        );
      }
      return _repository.loginWithFacebook(accessToken: accessToken);
    } catch (_) {
      return Either.left(
        const AuthFailure('Tidak bisa masuk dengan Facebook.'),
      );
    }
  }
}
