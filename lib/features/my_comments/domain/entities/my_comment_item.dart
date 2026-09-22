class MyCommentItem {
  const MyCommentItem({
    required this.id,
    required this.wordId,
    required this.wordLemma,
    required this.body,
    required this.status,
    required this.createdAt,
    required this.reviewedAt,
  });

  final String id;
  final String wordId;
  final String? wordLemma;
  final String body;
  final String status;
  final String createdAt;
  final String? reviewedAt;

  bool get canOpen => wordLemma != null && wordLemma!.isNotEmpty;

  String get title => canOpen ? wordLemma! : 'Kata tidak tersedia';

  String subtitle(String date) {
    final snippet = body.length <= 80 ? body : '${body.substring(0, 80)}…';
    return '${commentStatusLabel(status)} · $snippet · $date';
  }
}

String commentStatusLabel(String status) {
  return switch (status) {
    'published' => 'Tayang',
    'taken_down' => 'Diturunkan',
    'deleted_by_author' => 'Dihapus',
    _ => status,
  };
}

const commentStatusFilters = <(String?, String)>[
  (null, 'Semua'),
  ('published', 'Tayang'),
  ('taken_down', 'Diturunkan'),
  ('deleted_by_author', 'Dihapus'),
];
