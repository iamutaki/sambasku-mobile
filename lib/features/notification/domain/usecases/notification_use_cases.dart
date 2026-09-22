import 'package:fpdart/fpdart.dart';

import '../entities/inbox_notification_page.dart';
import '../failures/notification_failure.dart';
import '../repositories/notification_repository.dart';

class ListMyNotificationsUseCase {
  const ListMyNotificationsUseCase(this._repo);

  final NotificationRepository _repo;

  Future<Either<NotificationFailure, InboxNotificationPage>> call({
    int limit = 20,
    String? cursor,
  }) {
    return _repo.listMine(limit: limit, cursor: cursor);
  }
}

class GetUnreadNotificationCountUseCase {
  const GetUnreadNotificationCountUseCase(this._repo);

  final NotificationRepository _repo;

  Future<Either<NotificationFailure, int>> call() => _repo.unreadCount();
}

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repo);

  final NotificationRepository _repo;

  Future<Either<NotificationFailure, bool>> call(String id) => _repo.markRead(id);
}

class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this._repo);

  final NotificationRepository _repo;

  Future<Either<NotificationFailure, int>> call() => _repo.markAllRead();
}
