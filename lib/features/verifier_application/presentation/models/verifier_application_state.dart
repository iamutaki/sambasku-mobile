import '../../domain/entities/verifier_application.dart';

class VerifierApplicationState {
  const VerifierApplicationState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.application,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final VerifierApplication? application;
  final String? errorMessage;
  final String? successMessage;

  VerifierApplicationState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    VerifierApplication? application,
    bool clearApplication = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return VerifierApplicationState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      application: clearApplication
          ? null
          : application ?? this.application,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
