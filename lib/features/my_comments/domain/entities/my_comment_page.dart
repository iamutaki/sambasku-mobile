import 'my_comment_item.dart';

class MyCommentPage {
  const MyCommentPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<MyCommentItem> items;
  final String? nextCursor;
  final bool hasMore;
}
