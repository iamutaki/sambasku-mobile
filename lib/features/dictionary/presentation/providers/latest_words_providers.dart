import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/dictionary_domain_providers.dart';
import '../../domain/usecases/list_latest_words_use_case.dart';
import '../models/latest_words_state.dart';

part 'latest_words_providers.g.dart';

/// Feed beranda. Halaman pertama dimuat sejak build. keepAlive supaya
/// pindah tab tidak mengulang unduhan dari nol.
///
/// early-return (stale / !mounted) tidak boleh meninggalkan isLoading
/// tanpa request yang masih jalan.
@Riverpod(keepAlive: true)
class LatestWordsNotifier extends _$LatestWordsNotifier {
  int _loadReqId = 0;
  int _loadMoreReqId = 0;
  bool _isLoadingSync = false;
  bool _isLoadingMoreSync = false;

  @override
  LatestWordsState build() {
    ref.onResume(() {
      if (!ref.mounted) return;
      if (state.isLoading && !_isLoadingSync) {
        scheduleMicrotask(load);
      }
    });

    scheduleMicrotask(load);
    return const LatestWordsState(isLoading: true);
  }

  Future<void> loadMore() async {
    if (_isLoadingMoreSync ||
        _isLoadingSync ||
        !ref.mounted ||
        state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.nextCursor == null) {
      return;
    }
    _isLoadingMoreSync = true;
    final reqId = ++_loadMoreReqId;

    state = state.copyWith(isLoadingMore: true, clearErrorMessage: true);

    try {
      final result = await ref.read(listLatestWordsUseCaseProvider)(
        ListLatestWordsParams(cursor: state.nextCursor),
      );

      if (!ref.mounted || reqId != _loadMoreReqId) return;

      result.match(
        (failure) => state = state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        ),
        (page) {
          state = state.copyWith(
            isLoadingMore: false,
            items: [...state.items, ...page.items],
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

  Future<void> load() async {
    if (_isLoadingSync || !ref.mounted) return;
    _isLoadingSync = true;
    final reqId = ++_loadReqId;
    // Buang loadMore yang masih di udara supaya halaman lama tidak
    // menempel di halaman pertama yang baru.
    _loadMoreReqId++;
    _isLoadingMoreSync = false;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      clearErrorMessage: true,
    );

    try {
      final result = await ref.read(listLatestWordsUseCaseProvider)(
        const ListLatestWordsParams(),
      );

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
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    } finally {
      if (reqId == _loadReqId) {
        _isLoadingSync = false;
      }
    }
  }
}
