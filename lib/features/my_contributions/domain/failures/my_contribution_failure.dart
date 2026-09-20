class MyContributionFailure extends Error {
  MyContributionFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  bool get isNotFound =>
      errorCode == 'CONTRIBUTION_NOT_FOUND' ||
      errorCode == 'SUGGESTION_NOT_FOUND';

  @override
  String toString() => 'MyContributionFailure($errorCode): $message';
}
