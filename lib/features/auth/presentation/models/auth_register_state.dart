/// State halaman register. Sukses = akun dibuat, lanjut OTP (bukan auto-login).
class AuthRegisterState {
  const AuthRegisterState({
    this.isSubmitting = false,
    this.errorMessage,
    this.success = false,
    this.pendingEmail,
  });

  final bool isSubmitting;
  final String? errorMessage;

  /// Register sukses, belum login. UI arahkan ke /verify-email.
  final bool success;
  final String? pendingEmail;

  AuthRegisterState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? success,
    String? pendingEmail,
    bool clearPendingEmail = false,
  }) {
    return AuthRegisterState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      success: success ?? this.success,
      pendingEmail: clearPendingEmail
          ? null
          : pendingEmail ?? this.pendingEmail,
    );
  }
}
