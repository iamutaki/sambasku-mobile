import 'package:fpdart/fpdart.dart';

import '../entities/my_submission.dart';
import '../entities/my_submission_page.dart';
import '../failures/my_contribution_failure.dart';
import '../repositories/my_contribution_repository.dart';

class ListMyContributionsUseCase {
  const ListMyContributionsUseCase(this._repo);

  final MyContributionRepository _repo;

  Future<Either<MyContributionFailure, MySubmissionPage>> call({
    int limit = 20,
    String? cursor,
  }) {
    return _repo.listMine(limit: limit, cursor: cursor);
  }
}

class GetMyContributionDetailUseCase {
  const GetMyContributionDetailUseCase(this._repo);

  final MyContributionRepository _repo;

  Future<Either<MyContributionFailure, MySubmission>> call({
    required String kind,
    required String id,
  }) {
    return _repo.getMine(kind: kind, id: id);
  }
}
