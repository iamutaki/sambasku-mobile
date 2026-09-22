/// State bookmark satu kata milik user login (16-api-bookmark.md).
class BookmarkStatus {
  const BookmarkStatus({
    required this.wordId,
    this.isBookmarked = false,
    this.bookmarkedAt,
  });

  final String wordId;
  final bool isBookmarked;
  final String? bookmarkedAt;
}
