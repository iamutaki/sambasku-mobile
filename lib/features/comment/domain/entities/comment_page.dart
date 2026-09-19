import 'word_comment.dart';

/// Halaman komentar (cursor-based, pola api-base-stack Section 13).
class CommentPage {
  const CommentPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<WordComment> items;
  final String? nextCursor;
  final bool hasMore;
}