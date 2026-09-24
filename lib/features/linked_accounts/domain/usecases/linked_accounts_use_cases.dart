import 'package:fpdart/fpdart.dart';

import '../failures/linked_accounts_failure.dart';
import '../repositories/linked_accounts_repository.dart';

class GetGoogleLinkStatusUseCase {
  GetGoogleLinkStatusUseCase(this._repository);

  final LinkedAccountsRepository _repository;

  Future<Either<LinkedAccountsFailure, bool>> call() =>
      _repository.isGoogleLinked();
}

class LinkGoogleAccountUseCase {
  LinkGoogleAccountUseCase(this._repository);

  final LinkedAccountsRepository _repository;

  Future<Either<LinkedAccountsFailure, void>> call(String idToken) =>
      _repository.linkGoogle(idToken);
}

class UnlinkGoogleAccountUseCase {
  UnlinkGoogleAccountUseCase(this._repository);

  final LinkedAccountsRepository _repository;

  Future<Either<LinkedAccountsFailure, String>> call() =>
      _repository.unlinkGoogle();
}
