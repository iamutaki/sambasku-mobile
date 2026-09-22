import 'package:fpdart/fpdart.dart';

import '../entities/inbox_notification_page.dart';
import '../failures/notification_failure.dart';

abstract interface class NotificationRepository {
  Future<Either<NotificationFailure, InboxNotificationPage>> listMine({
    int limit = 20,
    String? cursor,
  });

  Future<Either<NotificationFailure, int>> unreadCount();

  Future<Either<NotificationFailure, bool>> markRead(String id);

  Future<Either<NotificationFailure, int>> markAllRead();
}
