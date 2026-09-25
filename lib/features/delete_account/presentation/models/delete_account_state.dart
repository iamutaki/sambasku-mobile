class DeleteAccountState {
  const DeleteAccountState({
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  DeleteAccountState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return DeleteAccountState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccessMessage ? null : successMessage ?? this.successMessage,
    );
  }
}
