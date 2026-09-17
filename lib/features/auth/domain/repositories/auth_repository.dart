import 'package:fpdart/fpdart.dart';

import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';

abstract interface class AuthRepository {
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  });
}
