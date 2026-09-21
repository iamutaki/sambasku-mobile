import '../../domain/entities/auth_session.dart';

class AuthVerifyState {
  const AuthVerifyState({
    this.isSubmitting = false,
    this.isResending = false,
    this.errorMessage,
    this.errorCode,
    this.resendMessage,
    this.session,
  });

  final bool isSubmitting;
  final bool isResending;
  final String? errorMessage;
  final String? errorCode;
  final String? resendMessage;
  final AuthSession? session;

  AuthVerifyState copyWith({
    bool? isSubmitting,
    bool? isResending,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? errorCode,
    bool clearErrorCode = false,
    String? resendMessage,
    bool clearResendMessage = false,
    AuthSession? session,
    bool clearSession = false,
  }) {
    return AuthVerifyState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isResending: isResending ?? this.isResending,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      errorCode: clearErrorCode ? null : errorCode ?? this.errorCode,
      resendMessage: clearResendMessage
          ? null
          : resendMessage ?? this.resendMessage,
      session: clearSession ? null : session ?? this.session,
    );
  }
}
