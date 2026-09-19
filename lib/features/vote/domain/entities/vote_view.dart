import 'vote_target.dart';

/// Jumlah vote per target + vote milik user login (state render tombol).
class VoteView {
  const VoteView({
    required this.target,
    this.upvotes = 0,
    this.downvotes = 0,
    this.myVote,
  });

  final VoteTarget target;
  final int upvotes;
  final int downvotes;

  /// 1 = upvote, -1 = downvote, null = belum/batal memilih. Hanya terisi
  /// saat user login (anonim lihat counts saja).
  final int? myVote;

  bool get hasVoted => myVote != null;
  bool get isUpvoted => myVote == 1;
  bool get isDownvoted => myVote == -1;
  int get score => upvotes - downvotes;

  VoteView copyWith({
    int? upvotes,
    int? downvotes,
    Object? myVote = _unset,
  }) {
    return VoteView(
      target: target,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      myVote: identical(myVote, _unset) ? this.myVote : myVote as int?,
    );
  }

  static const Object _unset = Object();
}

/// Jumlah vote mentah per target (upvote/downvote) dari
/// GET /api/v1/votes/counts.
class VoteCounts {
  const VoteCounts({this.upvotes = 0, this.downvotes = 0});

  final int upvotes;
  final int downvotes;
}