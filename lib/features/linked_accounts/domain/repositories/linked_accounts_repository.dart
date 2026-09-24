import 'package:fpdart/fpdart.dart';

import '../failures/linked_accounts_failure.dart';

abstract interface class LinkedAccountsRepository {
  Future<Either<LinkedAccountsFailure, bool>> isGoogleLinked();

  Future<Either<LinkedAccountsFailure, void>> linkGoogle(String idToken);

  Future<Either<LinkedAccountsFailure, String>> unlinkGoogle();
}
