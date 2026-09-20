/// Failure GET profil publik. extends Error supaya Riverpod tidak auto-retry
/// 4xx (USER_NOT_FOUND / RATE_LIMITED).
class UserProfileFailure extends Error {
  UserProfileFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  bool get isNotFound => errorCode == 'USER_NOT_FOUND';
  bool get isRateLimited => errorCode == 'RATE_LIMITED';

  @override
  String toString() => 'UserProfileFailure($errorCode): $message';
}
