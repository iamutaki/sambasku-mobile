import 'package:fpdart/fpdart.dart';

import '../failures/change_password_failure.dart';

abstract interface class ChangePasswordRepository {
  /// POST /api/v1/auth/change-password. Sukses = SEMUA session user
  /// ter-revoke di backend; pemanggil wajib clear sesi lokal setelahnya.
  /// Return pesan sukses dari backend untuk ditampilkan ke user.
  Future<Either<ChangePasswordFailure, String>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
