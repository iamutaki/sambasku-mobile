import 'package:fpdart/fpdart.dart';

import '../entities/search_miss.dart';
import '../failures/search_miss_failure.dart';
import '../repositories/search_miss_repository.dart';

class ListSearchMissesUseCase {
  const ListSearchMissesUseCase(this._repository);

  final SearchMissRepository _repository;

  Future<Either<SearchMissFailure, List<SearchMiss>>> call(
    ListSearchMissesParams params,
  ) {
    final limit = params.limit < 1
        ? 1
        : params.limit > 100
        ? 100
        : params.limit;
    return _repository.listSearchMisses(limit: limit);
  }
}

class ListSearchMissesParams {
  const ListSearchMissesParams({this.limit = 10});

  /// Di-backend max 100 baris. Default 10 = cukup untuk 1 row scroll
  /// horizontal di layar mobile.
  final int limit;
}
