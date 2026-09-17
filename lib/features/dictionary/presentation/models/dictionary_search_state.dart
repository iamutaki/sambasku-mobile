import '../../domain/entities/word_summary.dart';

/// State halaman pencarian (tab Home) - akumulasi item cursor-based
/// lewat loadMore (pola infinite scroll, base-stack Section 6).
class DictionarySearchState {
  const DictionarySearchState({
    this.query = '',
    this.searchIn = 'lemma',
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.hasSearched = false,
  });

  final String query;
  final String searchIn; // lemma | translation
  final List<WordSummary> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasSearched;

  DictionarySearchState copyWith({
    String? query,
    String? searchIn,
    List<WordSummary>? items,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? hasSearched,
  }) {
    return DictionarySearchState(
      query: query ?? this.query,
      searchIn: searchIn ?? this.searchIn,
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}
