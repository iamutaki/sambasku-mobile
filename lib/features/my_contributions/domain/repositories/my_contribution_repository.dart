import 'package:fpdart/fpdart.dart';

import '../entities/my_submission.dart';
import '../entities/my_submission_page.dart';
import '../failures/my_contribution_failure.dart';

abstract interface class MyContributionRepository {
  Future<Either<MyContributionFailure, MySubmissionPage>> listMine({
    int limit = 20,
    String? cursor,
  });

  Future<Either<MyContributionFailure, MySubmission>> getMine({
    required String kind,
    required String id,
  });
}
