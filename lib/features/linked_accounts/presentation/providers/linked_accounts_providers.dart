import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/data/providers/auth_data_providers.dart';
import '../../../auth/domain/ports/google_sign_in_port.dart';
import '../../domain/providers/linked_accounts_domain_providers.dart';
import '../models/linked_accounts_state.dart';

part 'linked_accounts_providers.g.dart';

@riverpod
class LinkedAccountsNotifier extends _$LinkedAccountsNotifier {
  @override
  LinkedAccountsState build() {
    Future.microtask(refresh);
    return const LinkedAccountsState();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    final result = await ref.read(getGoogleLinkStatusUseCaseProvider).call();
    result.match(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (linked) => state = state.copyWith(
        isLoading: false,
        googleLinked: linked,
        clearError: true,
      ),
    );
  }

  Future<void> linkGoogle() async {
    state = state.copyWith(isBusy: true, clearError: true, clearInfo: true);
    final GoogleSignInPort google = ref.read(googleSignInPortProvider);
    try {
      final idToken = await google.authenticate();
      if (idToken == null) {
        state = state.copyWith(isBusy: false);
        return;
      }
      final result =
          await ref.read(linkGoogleAccountUseCaseProvider).call(idToken);
      result.match(
        (failure) => state = state.copyWith(
          isBusy: false,
          errorMessage: failure.message,
        ),
        (_) => state = state.copyWith(
          isBusy: false,
          googleLinked: true,
          infoMessage: 'Akun Google berhasil dihubungkan.',
          clearError: true,
        ),
      );
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: error.toString().replaceFirst('Bad state: ', ''),
      );
    }
  }

  Future<void> unlinkGoogle() async {
    state = state.copyWith(isBusy: true, clearError: true, clearInfo: true);
    final result = await ref.read(unlinkGoogleAccountUseCaseProvider).call();
    result.match(
      (failure) => state = state.copyWith(
        isBusy: false,
        errorMessage: failure.message,
      ),
      (message) => state = state.copyWith(
        isBusy: false,
        googleLinked: false,
        infoMessage: message,
        clearError: true,
      ),
    );
  }
}
