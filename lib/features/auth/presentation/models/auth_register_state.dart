/// State halaman register (pola sama auth_login_state).
class AuthRegisterState {
  const AuthRegisterState({
    this.isSubmitting = false,
    this.errorMessage,
    this.success = false,
    this.needsManualLogin = false,
  });

  final bool isSubmitting;
  final String? errorMessage;

  /// Register + auto-login sukses.
  final bool success;

  /// Akun sudah dibuat tapi auto-login gagal → UI arahkan ke /login.
  final bool needsManualLogin;

  AuthRegisterState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? success,
    bool? needsManualLogin,
  }) {
    return AuthRegisterState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      success: success ?? this.success,
      needsManualLogin: needsManualLogin ?? this.needsManualLogin,
    );
  }
}
