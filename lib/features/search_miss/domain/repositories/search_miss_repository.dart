import 'package:fpdart/fpdart.dart';

import '../entities/search_miss.dart';
import '../failures/search_miss_failure.dart';

/// Ambil daftar "kata yang paling banyak dicari tapi tidak ketemu".
/// Dipakai untuk banner CTA horizontal di home (Ayo kontribusikan!).
abstract interface class SearchMissRepository {
  Future<Either<SearchMissFailure, List<SearchMiss>>> listSearchMisses({
    required int limit,
  });
}
