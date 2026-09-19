import 'bookmark_word.dart';

/// Satu item daftar bookmark milik user login.
class BookmarkItem {
  const BookmarkItem({
    required this.wordId,
    required this.bookmarkedAt,
    required this.word,
  });

  final String wordId;
  final String? bookmarkedAt;
  final BookmarkWord word;
}
