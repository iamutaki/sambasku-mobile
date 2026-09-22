import 'inbox_notification.dart';

class InboxNotificationPage {
  const InboxNotificationPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<InboxNotification> items;
  final String? nextCursor;
  final bool hasMore;
}
