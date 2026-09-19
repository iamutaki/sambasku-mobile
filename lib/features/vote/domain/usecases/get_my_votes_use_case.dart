import 'package:fpdart/fpdart.dart';

import '../entities/vote_target.dart';
import '../failures/vote_failure.dart';
import '../repositories/vote_repository.dart';

/// Vote milik user login untuk batch target (login wajib).
///
/// Digunakan merender state tombol upvote/downvote; hanya target yang
/// user pilih yang dikembalikan.
class GetMyVotesUseCase {
  const GetMyVotesUseCase(this._repository);

  final VoteRepository _repository;

  Future<Either<VoteFailure, Map<String, int>>> call(
    List<VoteTarget> targets,
  ) async {
    final seen = <String>{};
    final deduped = <VoteTarget>[];
    for (final t in targets) {
      if (seen.add(t.key)) deduped.add(t);
    }
    return _repository.myVotes(deduped);
  }
}