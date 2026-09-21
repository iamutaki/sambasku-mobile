import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/register_use_case.dart';
import '../models/auth_register_state.dart';

part 'auth_register_providers.g.dart';

@riverpod
class AuthRegisterNotifier extends _$AuthRegisterNotifier {
  @override
  AuthRegisterState build() => const AuthRegisterState();

  Future<void> submit({
    required String name,
    required String email,
    String? phoneNationalDigits,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      success: false,
      clearPendingEmail: true,
    );

    final registerResult = await ref
        .read(authRegisterUseCaseProvider)
        .call(
          RegisterParams(
            name: name,
            email: email,
            phoneNationalDigits: phoneNationalDigits,
            password: password,
            confirmPassword: confirmPassword,
          ),
        );

    registerResult.match(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          success: false,
        );
      },
      (_) {
        state = state.copyWith(
          isSubmitting: false,
          success: true,
          pendingEmail: email.trim(),
        );
      },
    );
  }
}
