import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/login_use_case.dart';
import '../models/auth_login_state.dart';
import 'auth_status_providers.dart';

part 'auth_login_providers.g.dart';

@riverpod
bool googleAuthEnabled(Ref ref) => isGoogleAuthConfigured();

@riverpod
bool facebookAuthEnabled(Ref ref) => isFacebookAuthConfigured();

@riverpod
class AuthLoginNotifier extends _$AuthLoginNotifier {
  var _inFlight = false;

  @override
  AuthLoginState build() => const AuthLoginState();

  Future<void> submit({required String email, required String password}) async {
    if (_inFlight) return;
    _inFlight = true;
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearErrorCode: true,
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
            clearErrorCode: true,
            clearSession: true,
            showUnverifiedSheet: true,
          );
          _inFlight = false;
          return;
        }
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          errorCode: failure.errorCode,
          clearSession: true,
          showUnverifiedSheet: false,
        );
      },
      (session) {
        ref.read(authStatusProvider.notifier).markLoggedIn(session);
        state = state.copyWith(
          isSubmitting: false,
          session: session,
          showUnverifiedSheet: false,
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
      clearSession: true,
      showUnverifiedSheet: false,
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
      clearSession: true,
      showUnverifiedSheet: false,
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
      clearSession: true,
    );
  }

  void _applyFacebookFailure(AuthFailure failure) {
    final hide = failure.errorCode == 'FACEBOOK_AUTH_UNAVAILABLE';
    state = state.copyWith(
      isSubmitting: false,
      errorMessage: hide ? null : failure.message,
      errorCode: failure.errorCode,
      facebookUnavailable: hide || state.facebookUnavailable,
      clearSession: true,
    );
  }

  void _applyGoogleSession(AuthSession session) {
    ref.read(authStatusProvider.notifier).markLoggedIn(session);
    state = state.copyWith(isSubmitting: false, session: session);
  }

  void acknowledgeUnverifiedSheet() {
    state = state.copyWith(showUnverifiedSheet: false);
  }
}
