import '../../../vote/domain/entities/vote_target.dart';

/// Komentar pada lemma (09-api-comment.md). Sudah memuat vote counts per
/// komentar (list endpoint mengembalikannya) + my_vote yang di-seed
/// controller dari GET /votes/my.
class WordComment {
  const WordComment({
    required this.id,
    required this.wordId,
    required this.userId,
    this.username,
    required this.body,
    this.createdAt,
    this.status,
    this.upvotes = 0,
    this.downvotes = 0,
    this.myVote,
  });

  final String id;
  final String wordId;
  final String userId;

  /// Nama penulis; null kalau penulis dihapus (client tampilkan
  /// "pengguna terhapus").
  final String? username;
  final String body;

  /// ISO-8601 dari server (diformat saat render).
  final String? createdAt;

  /// pending_review | published | rejected (hanya komentar sendiri).
  final String? status;
  final int upvotes;
  final int downvotes;

  /// 1 | -1 | null (milik user login; null = belum memilih).
  final int? myVote;

  VoteTarget get voteTarget => VoteTarget(type: 'comment', id: id);

  bool isOwner(String? actorId) => actorId != null && actorId == userId;

  WordComment copyWith({
    String? body,
    String? status,
    int? upvotes,
    int? downvotes,
    Object? myVote = _unset,
  }) {
    return WordComment(
      id: id,
      wordId: wordId,
      userId: userId,
      username: username,
      body: body ?? this.body,
      createdAt: createdAt,
      status: status ?? this.status,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      myVote: identical(myVote, _unset) ? this.myVote : myVote as int?,
    );
  }

  static const Object _unset = Object();
}