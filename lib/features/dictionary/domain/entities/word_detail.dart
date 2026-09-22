/// Detail kata lengkap (domain) - hasil GET /api/v1/words/:id.
class WordDetail {
  const WordDetail({
    required this.id,
    required this.lemma,
    required this.languageId,
    required this.wordType,
    required this.status,
    required this.isVerified,
    required this.isCorrected,
    this.selfVerified = false,
    this.notes,
    this.verifiedAt,
    this.verifiedBy,
    this.meanings = const [],
    this.categories = const [],
    this.pronunciations = const [],
    this.audios = const [],
    this.images = const [],
    this.relatedWords = const [],
    this.appearsIn = const [],
    this.variants = const [],
  });

  final String id;
  final String lemma;
  final String languageId;
  final String? notes;
  final String wordType;
  final String status;
  final bool isVerified;
  final bool isCorrected;
  final bool selfVerified;
  final String? verifiedAt;
  final WordVerifier? verifiedBy;
  final List<WordMeaning> meanings;
  final List<WordCategory> categories;
  final List<WordPronunciation> pronunciations;
  final List<WordAudio> audios;
  final List<WordImage> images;
  final List<RelatedWord> relatedWords;
  final List<RelatedWord> appearsIn;
  final List<WordVariant> variants;

  String get wordTypeLabel => switch (wordType) {
    'idiom' => 'Idiom',
    'peribahasa' => 'Peribahasa',
    'ungkapan' => 'Ungkapan',
    _ => 'Kata',
  };

  String get verifierAttributionLabel {
    final username = verifiedBy?.username;
    if (username == null || username.isEmpty) {
      return 'Verifikator tidak diketahui';
    }
    return selfVerified
        ? 'Dibuat dan diverifikasi oleh $username'
        : 'Diverifikasi oleh $username';
  }
}

class WordVerifier {
  const WordVerifier({required this.username, required this.role});

  final String username;
  final String role;
}

class WordMeaning {
  const WordMeaning({
    required this.id,
    this.wordClassId,
    this.wordClassCode,
    this.wordClassName,
    this.definition,
    required this.orderIndex,
    this.translations = const [],
    this.examples = const [],
  });

  final String id;
  final String? wordClassId;

  /// Kode singkat kelas kata dari API (`n`, `v`, `adj`, …) untuk format `[n]`.
  final String? wordClassCode;
  final String? wordClassName;
  final String? definition;
  final int orderIndex;
  final List<WordTranslation> translations;
  final List<WordExample> examples;

  /// Label bracket kamus, mis. `[n]`. Kosong jika kode tidak ada.
  String? get wordClassBracket {
    final code = wordClassCode?.trim();
    if (code == null || code.isEmpty) return null;
    return '[${code.toLowerCase()}]';
  }
}

class WordTranslation {
  const WordTranslation({
    required this.text,
    required this.type,
    this.languageId,
  });

  final String text;
  final String type;
  final String? languageId;

  String get typeLabel => switch (type) {
    'descriptive' => 'deskriptif',
    'idiomatic' => 'idiomatis',
    _ => 'langsung',
  };
}

class WordExample {
  const WordExample({
    required this.id,
    required this.sourceSentence,
    this.targetSentence,
    this.audios = const [],
  });

  final String id;
  final String sourceSentence;

  /// Null bila contoh belum punya terjemahan kalimat (`target_sentence`).
  final String? targetSentence;
  final List<WordAudio> audios;
}

/// Audio pelafalan (kata atau contoh kalimat).
class WordAudio {
  const WordAudio({
    required this.id,
    required this.url,
    this.dialectId,
    this.speakerName,
    this.durationMs,
    this.isPrimary = false,
    this.mimeType,
  });

  final String id;
  final String url;
  final String? dialectId;
  final String? speakerName;
  final int? durationMs;
  final bool isPrimary;
  final String? mimeType;

  String get displaySpeaker {
    final name = speakerName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Anonim';
  }

  String? get formattedDuration {
    final ms = durationMs;
    if (ms == null || ms <= 0) return null;
    final totalSec = (ms / 1000).round();
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

/// Urutkan: primary dulu, sisanya urutan API.
List<WordAudio> sortWordAudios(List<WordAudio> audios) {
  if (audios.length <= 1) return audios;
  final primary = audios.where((a) => a.isPrimary).toList(growable: false);
  final rest = audios.where((a) => !a.isPrimary).toList(growable: false);
  return [...primary, ...rest];
}

class WordCategory {
  const WordCategory({required this.id, required this.name});

  final String id;
  final String name;
}

class WordPronunciation {
  const WordPronunciation({required this.notation, required this.value});

  final String notation;
  final String value;
}

class WordImage {
  const WordImage({
    required this.id,
    required this.url,
    this.altText,
    required this.isPrimary,
  });

  final String id;
  final String url;
  final String? altText;
  final bool isPrimary;
}

class RelatedWord {
  const RelatedWord({
    required this.wordId,
    required this.lemma,
    required this.relationType,
  });

  final String wordId;
  final String lemma;
  final String relationType;

  String get relationLabel => switch (relationType) {
    'synonym' => 'Sinonim',
    'antonym' => 'Antonim',
    'has_component' => 'Komponen',
    'see_also' => 'Lihat juga',
    'derived_from' => 'Diturunkan dari',
    _ => relationType,
  };
}

class WordVariant {
  const WordVariant({
    required this.form,
    required this.variantType,
    this.affixType,
    this.affixValue,
    this.notes,
  });

  final String form;
  final String variantType;
  final String? affixType;
  final String? affixValue;
  final String? notes;

  String get variantTypeLabel => switch (variantType) {
    'alternative' => 'Variasi penulisan',
    'inflection' => 'Fleksi',
    'derivation' => 'Derivasi',
    'reduplication' => 'Reduplikasi',
    _ => variantType,
  };

  bool get isSpellingVariant => variantType == 'alternative';
}
