import 'package:fpdart/fpdart.dart';

import '../entities/public_profile.dart';
import '../failures/user_profile_failure.dart';

abstract interface class UserProfileRepository {
  Future<Either<UserProfileFailure, PublicProfile>> getByUsername(
    String username,
  );
}
