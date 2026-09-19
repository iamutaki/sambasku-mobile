import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../models/auth_register_state.dart';
import 'auth_status_providers.dart';

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
      needsManualLogin: false,
    );

    final registerResult = await ref.read(authRegisterUseCaseProvider).call(
          RegisterParams(
            name: name,
            email: email,
            phoneNationalDigits: phoneNationalDigits,
            password: password,
            confirmPassword: confirmPassword,
          ),
        );

    final registerFailure = registerResult.fold((f) => f, (_) => null);
    if (registerFailure != null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: registerFailure.message,
        success: false,
        needsManualLogin: false,
      );
      return;
    }

    // Seamless: akun aktif tanpa OTP → langsung login dengan kredensial sama.
    final loginResult = await ref.read(authLoginUseCaseProvider).call(
          LoginParams(email: email, password: password),
        );

    loginResult.match(
      (_) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage:
              'Akun dibuat, tapi masuk otomatis gagal. Silakan masuk manual.',
          success: false,
          needsManualLogin: true,
        );
      },
      (session) {
        ref.read(authStatusProvider.notifier).markLoggedIn(session);
        state = state.copyWith(
          isSubmitting: false,
          success: true,
          needsManualLogin: false,
        );
      },
    );
  }
}
