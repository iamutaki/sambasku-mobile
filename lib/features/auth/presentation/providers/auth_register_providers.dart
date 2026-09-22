import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/register_use_case.dart';
import '../models/auth_register_state.dart';
import 'auth_status_providers.dart';

part 'auth_register_providers.g.dart';

@riverpod
class AuthRegisterNotifier extends _$AuthRegisterNotifier {
  var _inFlight = false;

  @override
  AuthRegisterState build() => const AuthRegisterState();

  Future<void> submit({
    required String name,
    required String email,
    String? phoneNationalDigits,
    required String password,
    required String confirmPassword,
  }) async {
    if (_inFlight) return;
    _inFlight = true;
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearErrorCode: true,
      success: false,
      clearPendingEmail: true,
      clearSession: true,
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
          errorCode: failure.errorCode,
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
    _inFlight = false;
  }

  Future<void> submitGoogle() async {
    if (_inFlight) return;
    _inFlight = true;
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearErrorCode: true,
      success: false,
      clearSession: true,
    );

    final result = await ref.read(authLoginWithGoogleUseCaseProvider).call();
    if (result == null) {
      state = state.copyWith(isSubmitting: false);
      _inFlight = false;
      return;
    }

    result.match(
      (failure) => _applyGoogleFailure(failure),
      (session) => _applyGoogleSession(session),
    );
    _inFlight = false;
  }

  Future<void> submitFacebook() async {
    if (_inFlight) return;
    _inFlight = true;
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearErrorCode: true,
      success: false,
      clearSession: true,
    );

    final result = await ref.read(authLoginWithFacebookUseCaseProvider).call();
    if (result == null) {
      state = state.copyWith(isSubmitting: false);
      _inFlight = false;
      return;
    }

    result.match(
      (failure) => _applyFacebookFailure(failure),
      (session) => _applyGoogleSession(session),
    );
    _inFlight = false;
  }

  void _applyGoogleFailure(AuthFailure failure) {
    final hide = failure.errorCode == 'GOOGLE_AUTH_UNAVAILABLE';
    state = state.copyWith(
      isSubmitting: false,
      errorMessage: failure.message,
      errorCode: failure.errorCode,
      googleUnavailable: hide || state.googleUnavailable,
      success: false,
    );
  }

  void _applyFacebookFailure(AuthFailure failure) {
    final hide = failure.errorCode == 'FACEBOOK_AUTH_UNAVAILABLE';
    state = state.copyWith(
      isSubmitting: false,
      errorMessage: hide ? null : failure.message,
      errorCode: failure.errorCode,
      facebookUnavailable: hide || state.facebookUnavailable,
      success: false,
    );
  }

  void _applyGoogleSession(AuthSession session) {
    ref.read(authStatusProvider.notifier).markLoggedIn(session);
    state = state.copyWith(isSubmitting: false, session: session);
  }

  /// Dipakai UI setelah navigasi ke OTP supaya daftar berikutnya
  /// tidak memicu pendingEmail / success lama.
  void acknowledgeSuccess() {
    state = state.copyWith(success: false);
  }
}
