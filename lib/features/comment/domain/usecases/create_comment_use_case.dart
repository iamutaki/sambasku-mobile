import 'package:fpdart/fpdart.dart';

import '../entities/word_comment.dart';
import '../failures/comment_failure.dart';
import '../repositories/comment_repository.dart';

/// Tulis komentar (login). Body di-trim; minimal 1 karakter (validasi
/// final di backend: VALIDATION_ERROR kalau kosong).
class CreateCommentUseCase {
  const CreateCommentUseCase(this._repository);

  final CommentRepository _repository;

  Future<Either<CommentFailure, WordComment>> call({
    required String wordId,
    required String body,
  }) =>
      _repository.create(wordId: wordId, body: body.trim());
}