import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/login_use_case.dart';
import '../models/auth_login_state.dart';
import 'auth_status_providers.dart';

part 'auth_login_providers.g.dart';

@riverpod
class AuthLoginNotifier extends _$AuthLoginNotifier {
  @override
  AuthLoginState build() => const AuthLoginState();

  Future<void> submit({required String email, required String password}) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSession: true,
      showUnverifiedSheet: false,
    );

    final result = await ref
        .read(authLoginUseCaseProvider)
        .call(LoginParams(email: email, password: password));

    result.match(
      (failure) {
        if (failure.isEmailNotVerified) {
          state = state.copyWith(
            isSubmitting: false,
            clearErrorMessage: true,
            clearSession: true,
            showUnverifiedSheet: true,
          );
          return;
        }
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          clearSession: true,
          showUnverifiedSheet: false,
        );
      },
      (session) {
        // Token sudah di storage - set status langsung, jangan invalidate
        // (reload async masih expose previous isAuth:false).
        ref.read(authStatusProvider.notifier).markLoggedIn(session);
        state = state.copyWith(
          isSubmitting: false,
          session: session,
          showUnverifiedSheet: false,
        );
      },
    );
  }

  void acknowledgeUnverifiedSheet() {
    state = state.copyWith(showUnverifiedSheet: false);
  }
}
