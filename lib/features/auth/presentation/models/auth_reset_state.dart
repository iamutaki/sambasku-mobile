/// State halaman atur password baru (token dari email).
class AuthResetState {
  const AuthResetState({
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isSubmitting;
  final String? errorMessage;

  /// Non-null = reset sukses. Semua sesi lama sudah dicabut backend.
  final String? successMessage;

  AuthResetState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return AuthResetState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
