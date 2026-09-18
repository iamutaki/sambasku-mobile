import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/dictionary_domain_providers.dart';
import '../../domain/usecases/search_words_use_case.dart';
import '../models/dictionary_search_state.dart';

part 'dictionary_search_providers.g.dart';

/// 400 ms = sweet spot mobile: tidak terasa lambat bagi user, cukup jarang
/// buat tidak membanjiri API ketika user mengetik cepat.
const _kDebounceMs = 400;

@riverpod
class DictionarySearchNotifier extends _$DictionarySearchNotifier {
  Timer? _debounce;

  /// Req id guard: setiap panggilan `search()` increment ini. Sebelum
  /// menulis state, future yang sudah lewat reqId-nya dibandingkan dan
  /// dibuang bila tidak match. Mencegah overwrite data baru dengan
  /// hasil request lama yang nyangkut (stale response race condition).
  int _searchReqId = 0;
  int _loadMoreReqId = 0;

  /// Synchronous lock. `state.isLoading` hanya menjamin setelah
  /// `copyWith` diset (satu frame kemudian). Scroll listener infinite
  /// scroll bisa fire BERKALI-KALI dalam satu frame sebelum async gap
  /// selesai. Lock ini mencegah spawn 2-3 Future sekaligus.
  bool _isSearchingSync = false;
  bool _isLoadingMoreSync = false;

  /// Setelah dispose, semua Future yang masih jalan di-silence: tidak
  /// boleh tulis state lagi (flame error "set state after dispose").
  bool _isDisposed = false;

  @override
  DictionarySearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _debounce = null;
      _isDisposed = true;
    });
    return const DictionarySearchState();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Query berubah (dari search box). Jadwalkan pencarian halaman 1
  /// setelah debounce 400 ms (batal jadwal bila user ketik lagi).
  void onQueryChanged(String query) {
    state = state.copyWith(
      query: query,
      clearErrorMessage: true,
    );
    if (query.trim().isEmpty) {
      _debounce?.cancel();
      state = state.copyWith(
        items: [],
        clearNextCursor: true,
        hasMore: false,
        hasSearched: false,
      );
      return;
    }
    _scheduleSearch();
  }

  /// Ganti arah pencarian (lemma / translation).
  ///
  /// Sama seperti query: debounce 400 ms, karena user kadang toggle
  /// bolak-balik cepat untuk cek dua arah.
  void onSearchInChanged(String searchIn) {
    if (searchIn == state.searchIn) return;
    state = state.copyWith(searchIn: searchIn);
    if (state.query.trim().isNotEmpty) _scheduleSearch();
  }

  /// Halaman berikutnya (infinite scroll: `maxScrollExtent - 200`).
  ///
  /// Cukup dipanggil berkali-kali. Sync lock + state guard di sini
  /// pastikan hanya satu Future yang berjalan.
  Future<void> loadMore() async {
    if (_isLoadingMoreSync ||
        _isDisposed ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.nextCursor == null) {
      return;
    }
    _isLoadingMoreSync = true;
    final reqId = ++_loadMoreReqId;

    state = state.copyWith(isLoadingMore: true, clearErrorMessage: true);

    final result = await ref.read(searchWordsUseCaseProvider)(
      SearchWordsParams(
        query: state.query,
        searchIn: state.searchIn,
        cursor: state.nextCursor,
      ),
    );

    if (_isDisposed || reqId != _loadMoreReqId) {
      _isLoadingMoreSync = false;
      return;
    }

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

    _isLoadingMoreSync = false;
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// Batalkan timer sebelumnya, jadwalkan `search()` setelah
  /// [_kDebounceMs] ms. Dipakai oleh query dan searchIn.
  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: _kDebounceMs),
      search,
    );
  }

  /// Halaman pertama (query / searchIn berubah, bukan scroll).
  ///
  /// - Cancel / abaikan hasil sebelumnya via reqId guard
  /// - Sync lock `_isSearchingSync` sebelum await
  Future<void> search() async {
    if (_isSearchingSync || _isDisposed) return;
    _isSearchingSync = true;
    final reqId = ++_searchReqId;

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

    // Hasil usang (user sudah ketik lagi / ganti searchIn), buang.
    if (_isDisposed || reqId != _searchReqId) {
      _isSearchingSync = false;
      return;
    }

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

    _isSearchingSync = false;
  }
}
