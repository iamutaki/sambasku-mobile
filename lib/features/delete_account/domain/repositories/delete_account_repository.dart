import 'package:fpdart/fpdart.dart';

import '../failures/delete_account_failure.dart';

abstract interface class DeleteAccountRepository {
  /// DELETE /api/v1/auth/account. Sukses = akun sudah dianonimkan di server.
  /// Pemanggil wajib mengosongkan sesi lokal setelahnya.
  Future<Either<DeleteAccountFailure, String>> deleteAccount({
    String? password,
    required String confirmation,
  });
}
