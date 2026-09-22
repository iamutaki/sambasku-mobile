import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/bookmark_status.dart';
import '../../domain/failures/bookmark_failure.dart';
import '../../domain/providers/bookmark_domain_providers.dart';
import '../models/bookmark_list_state.dart';

part 'bookmark_providers.g.dart';

/// State bookmark satu kata (1 keluarga = 1 wordId). Guest = selalu
/// unbookmarked; saat login, seed status dari GET /bookmarks/my?word_ids=.
/// Seed gagal → degrade unbookmarked (tombol tetap ada). Toggle memutakhirkan
/// state dari response server (state final).
@riverpod
class BookmarkToggleController extends _$BookmarkToggleController {
  @override
  Future<BookmarkStatus> build(String wordId) async {
    final auth = await ref.watch(authStatusProvider.future);
    if (!auth.isAuth) return BookmarkStatus(wordId: wordId);

    final mine = await ref.watch(getBookmarkStatusesUseCaseProvider)([wordId]);
    // Seed status gagal (4xx/5xx/stale-session) → unbookmarked. Jangan throw:
    // error state di header detail = tombol hilang tanpa pesan. Toggle tulis
    // tetap surface failure lewat toast di caller.
    return mine.match(
      (_) => BookmarkStatus(wordId: wordId),
      (map) => map[wordId] ?? BookmarkStatus(wordId: wordId),
    );
  }

  /// Toggle pasang/lepas. Kembalikan `BookmarkFailure?` (null = sukses)
  /// supaya caller bisa menampilkan toast; state di-update hanya saat
  /// sukses (state lama tetap utuh saat gagal).
  Future<BookmarkFailure?> toggle() async {
    final result = await ref.watch(toggleBookmarkUseCaseProvider)(
      wordId: wordId,
    );
    return result.match(
      (failure) => failure,
      (status) {
        state = AsyncData(status);
        // List dari Profil → Bookmark keepAlive; tanpa invalidate, item
        // baru/hilang tidak muncul sampai pull-to-refresh / cold start.
        ref.invalidate(bookmarkListControllerProvider);
        return null;
      },
    );
  }
}

/// State halaman Bookmark (list milik user login, cursor pagination).
/// Guest = state kosong (halaman menampilkan prompt login). Hapus item
/// optimistik + restore saat gagal.
///
/// keepAlive: cache daftar tersimpan saat keluar halaman lalu kembali.
/// Watch authStatus: login/logout otomatis rebuild (jangan invalidate dari
/// AuthStatusNotifier — circular di Riverpod 3).
@Riverpod(keepAlive: true)
class BookmarkListController extends _$BookmarkListController {
  static const _pageSize = 20;

  @override
  Future<BookmarkListState> build() async {
    // Snapshot (bukan await .future): await di sini memicu rebuild ganda
    // saat transisi loading→data authStatus; watch AsyncValue cukup -
    // provider otomatis rebuild saat authStatus berubah.
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return const BookmarkListState();

    final result = await ref.watch(getMyBookmarksUseCaseProvider)(
      limit: _pageSize,
    );
    final page = result.match(
      (failure) => throw failure,
      (page) => page,
    );
    return BookmarkListState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<BookmarkFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final result = await ref.watch(getMyBookmarksUseCaseProvider)(
      limit: _pageSize,
      cursor: current.nextCursor,
    );
    return result.match(
      (failure) {
        final s = state.value ?? current;
        state = AsyncData(s.copyWith(isLoadingMore: false));
        return failure;
      },
      (page) {
        final s = state.value ?? current;
        state = AsyncData(
          s.copyWith(
            isLoadingMore: false,
            items: [...s.items, ...page.items],
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
          ),
        );
        return null;
      },
    );
  }

  /// Hapus satu bookmark (toggle lepas) - optimistik, restore saat gagal.
  Future<BookmarkFailure?> remove(String wordId) async {
    final current = state.value;
    if (current == null) return null;

    final before = current.items;
    state = AsyncData(
      current.copyWith(
        items: before.where((i) => i.wordId != wordId).toList(growable: false),
      ),
    );

    final result = await ref.watch(toggleBookmarkUseCaseProvider)(
      wordId: wordId,
    );
    return result.match(
      (failure) {
        state = AsyncData((state.value ?? current).copyWith(items: before));
        return failure;
      },
      (_) => null,
    );
  }
}
