import 'package:fpdart/fpdart.dart';

import '../entities/public_profile.dart';
import '../failures/user_profile_failure.dart';
import '../repositories/user_profile_repository.dart';

class GetPublicProfileUseCase {
  const GetPublicProfileUseCase(this._repository);

  final UserProfileRepository _repository;

  Future<Either<UserProfileFailure, PublicProfile>> call(String username) =>
      _repository.getByUsername(username);
}
