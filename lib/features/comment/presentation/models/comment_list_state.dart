import '../../domain/entities/word_comment.dart';
import '../../domain/failures/comment_failure.dart';

/// State daftar komentar per kata (list + paging + submit).
class CommentListState {
  const CommentListState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.submitFailure,
  });

  final List<WordComment> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSubmitting;

  /// Kegagalan submit komentar terakhir (toast di widget).
  final CommentFailure? submitFailure;

  CommentListState copyWith({
    List<WordComment>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSubmitting,
    CommentFailure? submitFailure,
    bool clearSubmitFailure = false,
  }) {
    return CommentListState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitFailure: clearSubmitFailure
          ? null
          : submitFailure ?? this.submitFailure,
    );
  }
}