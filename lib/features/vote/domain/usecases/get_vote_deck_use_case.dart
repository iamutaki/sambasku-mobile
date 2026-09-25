import 'package:fpdart/fpdart.dart';

import '../entities/vote_deck_item.dart';
import '../failures/vote_failure.dart';
import '../repositories/vote_repository.dart';

class GetVoteDeckUseCase {
  const GetVoteDeckUseCase(this._repository);

  final VoteRepository _repository;

  Future<Either<VoteFailure, VoteDeckPage>> call({
    int limit = 10,
    String? cursor,
  }) =>
      _repository.getDeck(limit: limit, cursor: cursor);
}
