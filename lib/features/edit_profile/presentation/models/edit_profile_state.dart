class EditProfileState {
  const EditProfileState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.username,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final String? username;
  final String? errorMessage;
  final String? successMessage;

  EditProfileState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? username,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      username: username ?? this.username,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}
