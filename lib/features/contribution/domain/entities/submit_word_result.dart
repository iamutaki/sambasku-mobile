/// Hasil submit kata via POST /api/v1/contributions/words.
///
/// Semua submit anonim selalu `status = 'pending_review'` (tidak
/// langsung tayang). `wordId` = ULID 26 huruf kata baru di tabel
/// `words`, status masih `pending_review` → di-antrean review admin.
class SubmitWordResult {
  const SubmitWordResult({
    required this.wordId,
    required this.status,
    this.message,
  });

  final String wordId;
  final String status;
  final String? message;

  bool get isPendingReview => status == 'pending_review';
}
