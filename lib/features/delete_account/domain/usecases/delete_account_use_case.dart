import 'package:fpdart/fpdart.dart';

import '../failures/delete_account_failure.dart';
import '../repositories/delete_account_repository.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final DeleteAccountRepository _repository;

  Future<Either<DeleteAccountFailure, String>> call({
    String? password,
    required String confirmation,
  }) {
    return _repository.deleteAccount(
      password: password,
      confirmation: confirmation,
    );
  }
}
