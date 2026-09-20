import '../../domain/entities/word_summary.dart';

/// State halaman Daftar Kata A-Z - akumulasi item cursor-based lewat
/// loadMore (pola DictionarySearchState, tanpa searchIn/hasSearched:
/// list selalu tampil sejak buka, q = filter).
class WordListState {
  const WordListState({
    this.q = '',
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final String q;
  final List<WordSummary> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  WordListState copyWith({
    String? q,
    List<WordSummary>? items,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return WordListState(
      q: q ?? this.q,
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
