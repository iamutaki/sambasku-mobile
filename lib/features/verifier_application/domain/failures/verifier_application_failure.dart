class VerifierApplicationFailure extends Error {
  VerifierApplicationFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  bool get isNotFound => errorCode == 'VERIFIER_APPLICATION_NOT_FOUND';
  bool get isRateLimited => errorCode == 'RATE_LIMITED';

  @override
  String toString() => 'VerifierApplicationFailure($errorCode): $message';
}
