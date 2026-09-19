import 'package:fpdart/fpdart.dart';

import '../entities/comment_page.dart';
import '../failures/comment_failure.dart';
import '../repositories/comment_repository.dart';

class ListWordCommentsUseCase {
  const ListWordCommentsUseCase(this._repository);

  final CommentRepository _repository;

  Future<Either<CommentFailure, CommentPage>> call({
    required String wordId,
    int limit = 20,
    String? cursor,
  }) =>
      _repository.listByWord(wordId: wordId, limit: limit, cursor: cursor);
}