import 'package:fpdart/fpdart.dart';

import '../entities/vote_target.dart';
import '../entities/vote_view.dart';
import '../failures/vote_failure.dart';
import '../repositories/vote_repository.dart';

/// Batch jumlah vote per target (publik, tanpa login).
///
/// Hasil SELALU berisi semua target input: target yang TIDAK punya vote
/// dilengkapi 0/0 (backend hanya mengembalikan target yang punya vote).
/// Duplikat input di-dedupe oleh key "type:id".
class GetVoteCountsUseCase {
  const GetVoteCountsUseCase(this._repository);

  final VoteRepository _repository;

  Future<Either<VoteFailure, Map<String, VoteCounts>>> call(
    List<VoteTarget> targets,
  ) async {
    final deduped = _dedupe(targets);
    final result = await _repository.countMany(deduped);

    return result.match(
      (failure) => Either.left(failure),
      (counts) {
        final filled = Map<String, VoteCounts>.from(counts);
        for (final target in deduped) {
          filled.putIfAbsent(target.key, () => const VoteCounts());
        }
        return Either.right(filled);
      },
    );
  }

  /// Buang target duplikat pakai set key, pertahankan urutan input.
  static List<VoteTarget> _dedupe(List<VoteTarget> targets) {
    final seen = <String>{};
    final out = <VoteTarget>[];
    for (final t in targets) {
      if (seen.add(t.key)) out.add(t);
    }
    return out;
  }
}