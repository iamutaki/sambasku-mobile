import 'package:fpdart/fpdart.dart';

import '../entities/vote_view.dart';
import '../failures/vote_failure.dart';
import '../repositories/vote_repository.dart';
import '../entities/vote_target.dart';

/// Toggle vote (upvote/downvote/batal) - login wajib.
class ToggleVoteUseCase {
  const ToggleVoteUseCase(this._repository);

  final VoteRepository _repository;

  /// [value] hanya 1 (upvote) atau -1 (downvote); 0 tidak diterima.
  Future<Either<VoteFailure, VoteView>> call({
    required VoteTarget target,
    required int value,
  }) =>
      _repository.toggle(target, value);
}