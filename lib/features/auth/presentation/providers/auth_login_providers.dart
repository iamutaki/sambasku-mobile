import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/login_use_case.dart';
import '../models/auth_login_state.dart';

part 'auth_login_providers.g.dart';

@riverpod
class AuthLoginNotifier extends _$AuthLoginNotifier {
  @override
  AuthLoginState build() => const AuthLoginState();

  Future<void> submit({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSession: true,
    );

    final result = await ref
        .read(authLoginUseCaseProvider)
        .call(LoginParams(email: email, password: password));

    result.match(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          clearSession: true,
        );
      },
      (session) {
        state = state.copyWith(
          isSubmitting: false,
          session: session,
        );
      },
    );
  }
}
