/// State halaman ubah password (pola AuthLoginState): copyWith manual
/// dengan flag clearX supaya null bisa DISET, bukan hanya ditimpa.
class ChangePasswordState {
  const ChangePasswordState({
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isSubmitting;
  final String? errorMessage;

  /// Non-null = sukses - halaman menampilkan dialog lalu logout paksa
  /// (semua session sudah di-revoke backend).
  final String? successMessage;

  ChangePasswordState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return ChangePasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage ? null : successMessage ?? this.successMessage,
    );
  }
}
