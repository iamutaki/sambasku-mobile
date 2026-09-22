import 'package:fpdart/fpdart.dart';

import '../entities/my_comment_page.dart';
import '../failures/my_comment_failure.dart';
import '../repositories/my_comment_repository.dart';

class ListMyCommentsUseCase {
  const ListMyCommentsUseCase(this._repo);

  final MyCommentRepository _repo;

  Future<Either<MyCommentFailure, MyCommentPage>> call({
    int limit = 20,
    String? cursor,
    String? status,
  }) {
    return _repo.listMine(limit: limit, cursor: cursor, status: status);
  }
}
