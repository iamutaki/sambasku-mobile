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
    this.notes,
    this.verifiedAt,
    this.meanings = const [],
    this.categories = const [],
    this.pronunciations = const [],
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
  final String? verifiedAt;
  final List<WordMeaning> meanings;
  final List<WordCategory> categories;
  final List<WordPronunciation> pronunciations;
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
}

class WordMeaning {
  const WordMeaning({
    required this.id,
    this.wordClassName,
    this.definition,
    required this.orderIndex,
    this.translations = const [],
    this.examples = const [],
  });

  final String id;
  final String? wordClassName;
  final String? definition;
  final int orderIndex;
  final List<WordTranslation> translations;
  final List<WordExample> examples;
}

class WordTranslation {
  const WordTranslation({
    required this.text,
    required this.type,
  });

  final String text;
  final String type;

  String get typeLabel => switch (type) {
        'descriptive' => 'deskriptif',
        'idiomatic' => 'idiomatis',
        _ => 'langsung',
      };
}

class WordExample {
  const WordExample({
    required this.sourceSentence,
    required this.targetSentence,
  });

  final String sourceSentence;
  final String targetSentence;
}

class WordCategory {
  const WordCategory({required this.id, required this.name});

  final String id;
  final String name;
}

class WordPronunciation {
  const WordPronunciation({
    required this.notation,
    required this.value,
  });

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
