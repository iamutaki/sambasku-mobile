import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/dictionary_domain_providers.dart';
import '../../domain/usecases/list_words_use_case.dart';
import '../models/word_list_state.dart';

part 'word_list_providers.g.dart';

/// Debounce filter q - sama dengan pencarian beranda (400 ms).
const _kDebounceMs = 400;

/// Notifier halaman Daftar Kata A-Z (18-api-list-words.md). Meniru
/// DictionarySearchNotifier: debounce, req id guard anti stale response,
/// sync lock anti double-fire. Bedanya: halaman 1 dimuat sejak build
/// (bukan idle menunggu query), q kosong = full A-Z.
///
/// keepAlive: cache list + posisi fetch tetap saat keluar ke detail /
/// beranda lalu kembali - jangan reload A-Z dari nol tiap buka.
///
/// PENTING: early-return (stale / !mounted) JANGAN tinggalkan
/// `isLoading: true` tanpa in-flight request — itu biang infinite
/// skeleton saat user back lalu masuk lagi (terutama korpus kosong).
@Riverpod(keepAlive: true)
class WordListNotifier extends _$WordListNotifier {
  Timer? _debounce;
  int _loadReqId = 0;
  int _loadMoreReqId = 0;
  bool _isLoadingSync = false;
  bool _isLoadingMoreSync = false;

  @override
  WordListState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _debounce = null;
    });

    // keepAlive: listener hilang saat pop, kembali saat push. Jika state
    // tersisa isLoading tanpa Future (race stale/dispose lama), pulihkan.
    ref.onResume(() {
      if (!ref.mounted) return;
      if (state.isLoading && !_isLoadingSync) {
        scheduleMicrotask(load);
      }
    });

    // Muat halaman pertama segera (juga setelah invalidate/pull-to-refresh).
    scheduleMicrotask(load);
    return const WordListState(isLoading: true);
  }

  /// Filter q berubah (dari search box halaman list). Debounce 400 ms →
  /// reset + fetch halaman pertama dengan q baru (server-side). q kosong
  /// → kembali full A-Z tanpa menunggu debounce.
  void onQueryChanged(String q) {
    final nextEmpty = q.trim().isEmpty;
    final alreadyIdleEmpty = nextEmpty &&
        state.q.trim().isEmpty &&
        !state.isLoading &&
        !_isLoadingSync &&
        state.items.isEmpty &&
        state.errorMessage == null;

    // Remount FTextField / echo onChange('') setelah empty load selesai
    // tidak boleh memicu refetch (bisa bikin skeleton + race).
    if (alreadyIdleEmpty) {
      if (q != state.q) state = state.copyWith(q: q);
      return;
    }

    state = state.copyWith(q: q, clearErrorMessage: true);
    if (nextEmpty) {
      _debounce?.cancel();
      state = state.copyWith(
        items: [],
        clearNextCursor: true,
        hasMore: false,
      );
      scheduleMicrotask(load);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: _kDebounceMs), load);
  }

  /// Halaman berikutnya (infinite scroll: `maxScrollExtent - 200`).
  Future<void> loadMore() async {
    if (_isLoadingMoreSync ||
        !ref.mounted ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.nextCursor == null) {
      return;
    }
    _isLoadingMoreSync = true;
    final reqId = ++_loadMoreReqId;

    state = state.copyWith(isLoadingMore: true, clearErrorMessage: true);

    try {
      final result = await ref.read(listWordsUseCaseProvider)(
        ListWordsParams(q: state.q, cursor: state.nextCursor),
      );

      if (!ref.mounted || reqId != _loadMoreReqId) return;

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
    } catch (e) {
      if (ref.mounted && reqId == _loadMoreReqId) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: e.toString(),
        );
      }
    } finally {
      if (reqId == _loadMoreReqId) {
        _isLoadingMoreSync = false;
      }
    }
  }

  /// Halaman pertama (buka halaman / q berubah / pull-to-refresh).
  Future<void> load() async {
    if (_isLoadingSync || !ref.mounted) return;
    _isLoadingSync = true;
    final reqId = ++_loadReqId;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await ref.read(listWordsUseCaseProvider)(
        ListWordsParams(q: state.q),
      );

      // Hasil usang (q sudah berubah lagi) ATAU notifier sudah diganti —
      // jangan tulis state; finally tetap lepas sync-lock.
      if (!ref.mounted || reqId != _loadReqId) return;

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
    } catch (e) {
      if (ref.mounted && reqId == _loadReqId) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    } finally {
      if (reqId == _loadReqId) {
        _isLoadingSync = false;
      }
    }
  }
}
