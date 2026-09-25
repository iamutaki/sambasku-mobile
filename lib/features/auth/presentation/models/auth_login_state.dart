import '../../../../core/constants/env.dart';
import '../../domain/entities/auth_session.dart';

/// State halaman login (pola jnn_mobile): copyWith manual dengan flag
/// clearX supaya null bisa DISET, bukan hanya ditimpa.
class AuthLoginState {
  const AuthLoginState({
    this.isSubmitting = false,
    this.errorMessage,
    this.errorCode,
    this.session,
    this.showUnverifiedSheet = false,
    this.googleUnavailable = false,
    this.facebookUnavailable = false,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final String? errorCode;
  final AuthSession? session;

  /// Password benar tapi email belum OTP. UI tampilkan sheet, bukan toast.
  final bool showUnverifiedSheet;

  /// 503 GOOGLE_AUTH_UNAVAILABLE - sembunyikan tombol Google.
  final bool googleUnavailable;

  /// 503 FACEBOOK_AUTH_UNAVAILABLE - sembunyikan tombol Facebook.
  final bool facebookUnavailable;

  AuthLoginState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? errorCode,
    bool clearErrorCode = false,
    AuthSession? session,
    bool clearSession = false,
    bool? showUnverifiedSheet,
    bool? googleUnavailable,
    bool? facebookUnavailable,
  }) {
    return AuthLoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      errorCode: clearErrorCode ? null : errorCode ?? this.errorCode,
      session: clearSession ? null : session ?? this.session,
      showUnverifiedSheet: showUnverifiedSheet ?? this.showUnverifiedSheet,
      googleUnavailable: googleUnavailable ?? this.googleUnavailable,
      facebookUnavailable: facebookUnavailable ?? this.facebookUnavailable,
    );
  }
}

bool isGoogleAuthConfigured() {
  final id = Env.googleWebClientId;
  return id != null && id.trim().isNotEmpty;
}

bool isFacebookAuthConfigured() {
  final id = Env.facebookAppId;
  return id != null && id.trim().isNotEmpty;
}
