import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/public_profile.dart';
import '../../domain/failures/user_profile_failure.dart';
import '../../domain/providers/user_profile_domain_providers.dart';

part 'user_profile_providers.g.dart';

/// Load profil publik; error object = [UserProfileFailure] (termasuk 404).
@riverpod
Future<PublicProfile> publicProfile(Ref ref, String username) async {
  final result = await ref.watch(getPublicProfileUseCaseProvider)(username);
  return result.match((failure) => throw failure, (profile) => profile);
}
