class NotificationFailure extends Error {
  NotificationFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  bool get isNotFound => errorCode == 'NOTIFICATION_NOT_FOUND';

  @override
  String toString() => 'NotificationFailure($errorCode): $message';
}
