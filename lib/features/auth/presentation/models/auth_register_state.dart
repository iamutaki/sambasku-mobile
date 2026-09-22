import '../../domain/entities/auth_session.dart';

/// State halaman register. Sukses = akun dibuat, lanjut OTP (bukan auto-login).
/// Google: session terisi, langsung home.
class AuthRegisterState {
  const AuthRegisterState({
    this.isSubmitting = false,
    this.errorMessage,
    this.errorCode,
    this.success = false,
    this.pendingEmail,
    this.session,
    this.googleUnavailable = false,
    this.facebookUnavailable = false,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final String? errorCode;

  /// Register sukses, belum login. UI arahkan ke /verify-email.
  final bool success;
  final String? pendingEmail;
  final AuthSession? session;
  final bool googleUnavailable;
  final bool facebookUnavailable;

  AuthRegisterState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? errorCode,
    bool clearErrorCode = false,
    bool? success,
    String? pendingEmail,
    bool clearPendingEmail = false,
    AuthSession? session,
    bool clearSession = false,
    bool? googleUnavailable,
    bool? facebookUnavailable,
  }) {
    return AuthRegisterState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      errorCode: clearErrorCode ? null : errorCode ?? this.errorCode,
      success: success ?? this.success,
      pendingEmail: clearPendingEmail
          ? null
          : pendingEmail ?? this.pendingEmail,
      session: clearSession ? null : session ?? this.session,
      googleUnavailable: googleUnavailable ?? this.googleUnavailable,
      facebookUnavailable: facebookUnavailable ?? this.facebookUnavailable,
    );
  }
}
