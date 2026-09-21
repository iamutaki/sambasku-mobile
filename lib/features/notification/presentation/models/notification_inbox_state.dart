import '../../domain/entities/inbox_notification.dart';

class NotificationInboxState {
  const NotificationInboxState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<InboxNotification> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  NotificationInboxState copyWith({
    List<InboxNotification>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationInboxState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
