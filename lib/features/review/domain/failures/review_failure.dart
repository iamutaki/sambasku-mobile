class ReviewFailure extends Error {
  ReviewFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  bool get isForbidden => errorCode == 'FORBIDDEN';

  /// Usulan atau kata sudah diputuskan orang lain / ketukan sebelumnya.
  bool get isAlreadyDecided =>
      errorCode == 'CONTRIBUTION_ALREADY_REVIEWED' ||
      errorCode == 'WORD_ALREADY_VERIFIED' ||
      errorCode == 'WORD_ALREADY_UNVERIFIED';

  @override
  String toString() => 'ReviewFailure($errorCode): $message';
}
