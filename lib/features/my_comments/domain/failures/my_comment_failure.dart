class MyCommentFailure extends Error {
  MyCommentFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => 'MyCommentFailure($errorCode): $message';
}
