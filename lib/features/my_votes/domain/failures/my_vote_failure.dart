class MyVoteFailure extends Error {
  MyVoteFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => 'MyVoteFailure($errorCode): $message';
}
