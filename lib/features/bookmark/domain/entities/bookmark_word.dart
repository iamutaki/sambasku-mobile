/// Ringkasan kata pada item bookmark - subset minimal untuk list UI
/// (16-api-bookmark.md).
class BookmarkWord {
  const BookmarkWord({
    required this.id,
    required this.lemma,
    required this.wordType,
    this.isVerified = false,
  });

  final String id;
  final String lemma;
  final String wordType;
  final bool isVerified;

  String get wordTypeLabel => switch (wordType) {
        'idiom' => 'Idiom',
        'peribahasa' => 'Peribahasa',
        'ungkapan' => 'Ungkapan',
        _ => 'Kata',
      };
}
