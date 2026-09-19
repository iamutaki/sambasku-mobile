import 'bookmark_item.dart';

/// Halaman daftar bookmark (cursor-based, pola api-base-stack Section 13).
class BookmarkPage {
  const BookmarkPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<BookmarkItem> items;
  final String? nextCursor;
  final bool hasMore;
}
