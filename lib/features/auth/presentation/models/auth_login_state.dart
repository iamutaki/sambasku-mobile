import '../../domain/entities/auth_session.dart';

/// State halaman login (pola jnn_mobile): copyWith manual dengan flag
/// clearX supaya null bisa DISET, bukan hanya ditimpa.
class AuthLoginState {
  const AuthLoginState({
    this.isSubmitting = false,
    this.errorMessage,
    this.session,
    this.showUnverifiedSheet = false,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final AuthSession? session;

  /// Password benar tapi email belum OTP. UI tampilkan sheet, bukan toast.
  final bool showUnverifiedSheet;

  AuthLoginState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    AuthSession? session,
    bool clearSession = false,
    bool? showUnverifiedSheet,
  }) {
    return AuthLoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      session: clearSession ? null : session ?? this.session,
      showUnverifiedSheet: showUnverifiedSheet ?? this.showUnverifiedSheet,
    );
  }
}
