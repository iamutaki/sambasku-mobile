import 'package:fpdart/fpdart.dart';

import '../entities/bookmark_page.dart';
import '../failures/bookmark_failure.dart';
import '../repositories/bookmark_repository.dart';

/// Daftar bookmark user login (login wajib) - halaman Bookmark di profil.
class GetMyBookmarksUseCase {
  const GetMyBookmarksUseCase(this._repository);

  final BookmarkRepository _repository;

  Future<Either<BookmarkFailure, BookmarkPage>> call({
    int limit = 20,
    String? cursor,
  }) =>
      _repository.myBookmarks(limit: limit, cursor: cursor);
}
