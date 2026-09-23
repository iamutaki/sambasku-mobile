import 'package:fpdart/fpdart.dart';

import '../entities/review_contribution.dart';
import '../failures/review_failure.dart';

abstract class ReviewRepository {
  Future<Either<ReviewFailure, ReviewListPage>> list({
    String? status,
    String? entityType,
    String? wordId,
    int limit = 20,
    String? cursor,
  });

  Future<Either<ReviewFailure, ReviewDetail>> detail(String id);

  Future<Either<ReviewFailure, ReviewDecisionResult>> approve(
    String id, {
    String? comment,
  });

  Future<Either<ReviewFailure, ReviewDecisionResult>> reject(
    String id, {
    required String comment,
  });

  Future<Either<ReviewFailure, ReviewDecisionResult>> correct(
    String id,
    Map<String, dynamic> body,
  );
}
