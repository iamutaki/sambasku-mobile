import 'package:fpdart/fpdart.dart';

import '../entities/bookmark_page.dart';
import '../entities/bookmark_status.dart';
import '../failures/bookmark_failure.dart';

/// Interface repository bookmark (16-api-bookmark.md). Semua method
/// mengembalikan `Either`, failure = [BookmarkFailure].
abstract interface class BookmarkRepository {
  /// Toggle bookmark kata (login). Semantik servernya idempotent satu
  /// arah: sudah ada = lepas, belum ada = pasang. Response selalu
  /// membawa state final.
  Future<Either<BookmarkFailure, BookmarkStatus>> toggle(String wordId);

  /// Daftar bookmark user login (login) - cursor pagination.
  Future<Either<BookmarkFailure, BookmarkPage>> myBookmarks({
    int limit = 20,
    String? cursor,
  });

  /// Cek status bookmark batch by word id (login). Kunci map = wordId;
  /// hanya kata yang di-bookmark user yang muncul.
  Future<Either<BookmarkFailure, Map<String, BookmarkStatus>>> statuses(
    List<String> wordIds,
  );
}
