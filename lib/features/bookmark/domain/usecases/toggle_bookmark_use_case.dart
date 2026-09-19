import 'package:fpdart/fpdart.dart';

import '../entities/bookmark_status.dart';
import '../failures/bookmark_failure.dart';
import '../repositories/bookmark_repository.dart';

/// Toggle bookmark kata (pasang/lepas) - login wajib.
class ToggleBookmarkUseCase {
  const ToggleBookmarkUseCase(this._repository);

  final BookmarkRepository _repository;

  Future<Either<BookmarkFailure, BookmarkStatus>> call({
    required String wordId,
  }) =>
      _repository.toggle(wordId);
}
