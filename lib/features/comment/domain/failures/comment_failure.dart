/// Failure operasi komentar. `errorCode` membawa kode backend untuk
/// penanganan spesifik (COMMENT_NOT_FOUND -> 404, FORBIDDEN -> 403,
/// RATE_LIMITED -> 429).
class CommentFailure {
  const CommentFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  bool get isNotFound => errorCode == 'COMMENT_NOT_FOUND';
  bool get isForbidden => errorCode == 'FORBIDDEN';
  bool get isRateLimited => errorCode == 'RATE_LIMITED';
}