import 'package:fpdart/fpdart.dart';

import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';

abstract interface class AuthRepository {
  Future<Either<AuthFailure, void>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
  });

  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  });

  /// Revoke refresh token di backend (POST /api/v1/auth/logout),
  /// lalu clear sesi lokal. Best-effort: gagal jaringan tetap clear.
  Future<Either<AuthFailure, void>> logout();
}
