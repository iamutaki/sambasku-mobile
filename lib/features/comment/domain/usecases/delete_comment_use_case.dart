import 'package:fpdart/fpdart.dart';

import '../failures/comment_failure.dart';
import '../repositories/comment_repository.dart';

/// Soft-delete komentar sendiri (atau oleh verifikator).
class DeleteCommentUseCase {
  const DeleteCommentUseCase(this._repository);

  final CommentRepository _repository;

  Future<Either<CommentFailure, void>> call(String commentId) =>
      _repository.delete(commentId);
}