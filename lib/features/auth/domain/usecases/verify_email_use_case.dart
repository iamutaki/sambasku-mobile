import 'package:fpdart/fpdart.dart';

import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  const VerifyEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<AuthFailure, AuthSession>> call(VerifyEmailParams params) {
    return _repository.verifyEmail(
      email: params.email.trim(),
      code: params.code.trim(),
    );
  }
}

class VerifyEmailParams {
  const VerifyEmailParams({required this.email, required this.code});

  final String email;
  final String code;
}

class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<AuthFailure, void>> call(String email) {
    return _repository.resendOtp(email: email.trim());
  }
}
