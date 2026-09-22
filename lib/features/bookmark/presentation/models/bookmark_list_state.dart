import '../../domain/entities/bookmark_item.dart';

/// State daftar bookmark milik user (list + paging).
class BookmarkListState {
  const BookmarkListState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<BookmarkItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  BookmarkListState copyWith({
    List<BookmarkItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return BookmarkListState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
