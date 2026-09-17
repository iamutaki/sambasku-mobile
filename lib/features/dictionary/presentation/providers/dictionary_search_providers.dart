import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/dictionary_domain_providers.dart';
import '../../domain/usecases/search_words_use_case.dart';
import '../models/dictionary_search_state.dart';

part 'dictionary_search_providers.g.dart';

@riverpod
class DictionarySearchNotifier extends _$DictionarySearchNotifier {
  Timer? _debounce;

  @override
  DictionarySearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const DictionarySearchState();
  }

  /// Query berubah (dari search box) - debounce 400ms lalu cari halaman 1.
  void onQueryChanged(String query) {
    _debounce?.cancel();
    state = state.copyWith(
      query: query,
      clearErrorMessage: true,
    );
    if (query.trim().isEmpty) {
      state = state.copyWith(items: [], clearNextCursor: true, hasMore: false, hasSearched: false);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), search);
  }

  /// Ganti arah pencarian: lemma (Sambas->ID) atau translation (ID->Sambas)
  void onSearchInChanged(String searchIn) {
    if (searchIn == state.searchIn) return;
    state = state.copyWith(searchIn: searchIn);
    if (state.query.trim().isNotEmpty) search();
  }

  Future<void> search() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      hasSearched: true,
    );

    final result = await ref.read(searchWordsUseCaseProvider)(
      SearchWordsParams(
        query: state.query,
        searchIn: state.searchIn,
      ),
    );

    result.match(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (page) => state = state.copyWith(
        isLoading: false,
        items: page.items,
        nextCursor: page.nextCursor,
        clearNextCursor: page.nextCursor == null,
        hasMore: page.hasMore,
      ),
    );
  }

  /// Halaman berikutnya (tombol "Muat lagi" / infinite scroll)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);

    final result = await ref.read(searchWordsUseCaseProvider)(
      SearchWordsParams(
        query: state.query,
        searchIn: state.searchIn,
        cursor: state.nextCursor,
      ),
    );

    result.match(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      ),
      (page) {
        final merged = [...state.items, ...page.items];
        state = state.copyWith(
          isLoadingMore: false,
          items: merged,
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
          hasMore: page.hasMore,
        );
      },
    );
  }
}
