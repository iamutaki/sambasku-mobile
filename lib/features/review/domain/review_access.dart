/// Peran yang boleh membuka antrean review. `editor` tidak termasuk:
/// mereka hanya menandai karya sendiri, bukan meninjau usulan orang lain.
bool canReviewQueue(String? role) =>
    role == 'admin' || role == 'root' || role == 'reviewer';

const reviewEntityLabels = <String, String>{
  'word': 'Kata',
  'pronunciation': 'Pelafalan',
  'word_image': 'Gambar',
  'word_audio': 'Audio',
  'example': 'Contoh kalimat',
  'meaning': 'Makna',
};

String reviewEntityLabel(String entityType) =>
    reviewEntityLabels[entityType] ?? entityType;
