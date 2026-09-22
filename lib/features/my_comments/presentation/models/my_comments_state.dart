import '../../domain/entities/my_comment_item.dart';

class MyCommentsState {
  const MyCommentsState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.status,
  });

  final List<MyCommentItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String? status;
}
