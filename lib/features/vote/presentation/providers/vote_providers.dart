import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/vote_target.dart';
import '../../domain/entities/vote_view.dart';
import '../../domain/failures/vote_failure.dart';
import '../../domain/providers/vote_domain_providers.dart';

part 'vote_providers.g.dart';

/// State vote per target (1 keluarga = 1 VoteTarget). Load counts (publik)
/// + my_vote (kalau login), lalu toggle memutakhirkan state in-place
/// memakai response server (count + my_vote final).
@riverpod
class VoteController extends _$VoteController {
  @override
  Future<VoteView> build(VoteTarget target) async {
    final counts = await ref.watch(getVoteCountsUseCaseProvider)([target]);

    var upvotes = 0;
    var downvotes = 0;
    counts.match(
      (failure) => throw failure,
      (map) {
        final value = map[target.key];
        upvotes = value?.upvotes ?? 0;
        downvotes = value?.downvotes ?? 0;
      },
    );

    int? myVote;
    final auth = await ref.watch(authStatusProvider.future);
    if (auth.isAuth) {
      final mine = await ref.watch(getMyVotesUseCaseProvider)([target]);
      mine.match(
        (failure) {
          // 401 (UNAUTHORIZED/TOKEN_EXPIRED) = flag isAuth stale-true saat
          // secure store ter-wipe - degrade ke tampilan anonim, counts
          // publik tetap tampil. Failure lain tetap fatal.
          final staleSession =
              failure.errorCode == 'UNAUTHORIZED' ||
              failure.errorCode == 'TOKEN_EXPIRED';
          if (!staleSession) throw failure;
        },
        (map) => myVote = map[target.key],
      );
    }

    return VoteView(
      target: target,
      upvotes: upvotes,
      downvotes: downvotes,
      myVote: myVote,
    );
  }

  /// Toggle vote [value] (1 | -1). Kembalikan `VoteFailure?` (null = sukses)
  /// supaya caller bisa menampilkan toast; state di-update hanya saat sukses
  /// (state lama tetap utuh saat gagal, bukan berubah jadi error).
  Future<VoteFailure?> toggle(int value) async {
    final result =
        await ref.watch(toggleVoteUseCaseProvider)(target: target, value: value);
    return result.match(
      (failure) => failure,
      (view) {
        state = AsyncData(view);
        return null;
      },
    );
  }
}