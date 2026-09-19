import 'package:fpdart/fpdart.dart';

import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<AuthFailure, void>> call(RegisterParams params) {
    return _repository.register(
      name: params.name.trim(),
      email: params.email.trim(),
      phone: params.phoneNationalDigits,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
  }
}

class RegisterParams {
  const RegisterParams({
    required this.name,
    required this.email,
    this.phoneNationalDigits,
    required this.password,
    required this.confirmPassword,
  });

  final String name;
  final String email;

  /// Digit nasional tanpa prefix negara (mis. 81234567890). Null/kosong = skip.
  final String? phoneNationalDigits;
  final String password;
  final String confirmPassword;
}
