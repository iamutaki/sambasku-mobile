import 'package:fpdart/fpdart.dart';

import '../entities/bookmark_status.dart';
import '../failures/bookmark_failure.dart';
import '../repositories/bookmark_repository.dart';

/// Cek status bookmark batch by word id (login wajib) - state tombol
/// bookmark di halaman detail kata.
class GetBookmarkStatusesUseCase {
  const GetBookmarkStatusesUseCase(this._repository);

  final BookmarkRepository _repository;

  Future<Either<BookmarkFailure, Map<String, BookmarkStatus>>> call(
    List<String> wordIds,
  ) {
    final deduped = wordIds.toSet().toList(growable: false);
    return _repository.statuses(deduped);
  }
}
