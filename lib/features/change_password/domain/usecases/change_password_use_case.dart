import 'package:fpdart/fpdart.dart';

import '../failures/change_password_failure.dart';
import '../repositories/change_password_repository.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final ChangePasswordRepository _repository;

  Future<Either<ChangePasswordFailure, String>> call(ChangePasswordParams params) {
    return _repository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}

class ChangePasswordParams {
  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
}
