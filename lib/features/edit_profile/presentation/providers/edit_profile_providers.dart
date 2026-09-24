import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/edit_profile_domain_providers.dart';
import '../models/edit_profile_state.dart';

part 'edit_profile_providers.g.dart';

@riverpod
class EditProfileNotifier extends _$EditProfileNotifier {
  @override
  EditProfileState build() => const EditProfileState(isLoading: true);

  Future<({String displayName, String bio})?> load() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    final result = await ref.read(getMyProfileUseCaseProvider).call();
    return result.match(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (profile) {
        state = state.copyWith(
          isLoading: false,
          username: profile.username,
          clearErrorMessage: true,
        );
        return (displayName: profile.displayName, bio: profile.bio ?? '');
      },
    );
  }

  Future<void> submit({
    required String displayName,
    required String bio,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final result = await ref.read(updateMyProfileUseCaseProvider).call(
          displayName: displayName.trim(),
          bio: bio.trim().isEmpty ? null : bio.trim(),
        );

    result.match(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Profil berhasil disimpan.',
        clearErrorMessage: true,
      ),
    );
  }
}
