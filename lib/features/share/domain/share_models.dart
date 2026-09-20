import 'package:flutter/material.dart';

/// Kandidat foto latar dari GET /api/v1/share/backgrounds.
class ShareBackground {
  const ShareBackground({
    required this.id,
    required this.url,
    required this.photographer,
    required this.username,
    required this.attributionUrl,
    this.provider = 'unsplash',
  });

  final String id;
  final String url;
  final String photographer;
  final String username;
  final String attributionUrl;
  final String provider;

  /// Alias lama.
  String get unsplashUrl => attributionUrl;
}

class ShareBackgroundsResult {
  const ShareBackgroundsResult({
    required this.items,
    required this.page,
    required this.degraded,
    this.provider = 'unsplash',
  });

  final List<ShareBackground> items;
  final int page;
  final bool degraded;
  final String provider;
}

/// Sumber latar kartu (terpisah dari gaya template).
enum ShareBgSource { unsplash, device, wordImage, none }

/// Data teks yang digambar ke kartu share.
class ShareCardData {
  const ShareCardData({
    required this.lemma,
    this.wordClassName,
    this.definition,
    this.padanan,
    this.exampleSentence,
    this.photographer,
  });

  final String lemma;
  final String? wordClassName;
  final String? definition;
  final String? padanan;
  final String? exampleSentence;
  final String? photographer;

  String get caption {
    final pad = (padanan != null && padanan!.isNotEmpty) ? padanan! : lemma;
    return '"$lemma" — $pad · kamus bahasa Sambas #SambasKu';
  }

  String get copyText {
    final buf = StringBuffer(lemma);
    if (wordClassName != null && wordClassName!.isNotEmpty) {
      buf.write(' ($wordClassName)');
    }
    if (definition != null && definition!.isNotEmpty) {
      buf.write('\n$definition');
    }
    if (padanan != null && padanan!.isNotEmpty) {
      buf.write('\n→ $padanan');
    }
    if (exampleSentence != null && exampleSentence!.isNotEmpty) {
      buf.write('\n"$exampleSentence"');
    }
    buf.write('\n\n#SambasKu');
    return buf.toString();
  }
}

enum ShareFontPair { classic, editorial, modern }

extension ShareFontPairX on ShareFontPair {
  String get label => switch (this) {
    ShareFontPair.classic => 'Klasik',
    ShareFontPair.editorial => 'Editorial',
    ShareFontPair.modern => 'Modern',
  };
}

enum ShareTextColorId { putih, krem, tinta, terracotta, sky }

extension ShareTextColorIdX on ShareTextColorId {
  String get label => switch (this) {
    ShareTextColorId.putih => 'Putih',
    ShareTextColorId.krem => 'Krem',
    ShareTextColorId.tinta => 'Tinta',
    ShareTextColorId.terracotta => 'Terracotta',
    ShareTextColorId.sky => 'Sky',
  };

  Color get lemma => switch (this) {
    ShareTextColorId.putih => const Color(0xFFFFFFFF),
    ShareTextColorId.krem => const Color(0xFFFFF7ED),
    ShareTextColorId.tinta => const Color(0xFF1C1917),
    ShareTextColorId.terracotta => const Color(0xFFFDBA74),
    ShareTextColorId.sky => const Color(0xFFBAE6FD),
  };

  Color get body => switch (this) {
    ShareTextColorId.putih => const Color(0xFFFFFFFF).withValues(alpha: 0.92),
    ShareTextColorId.krem => const Color(0xFFFFEDD5),
    ShareTextColorId.tinta => const Color(0xFF44403C),
    ShareTextColorId.terracotta => const Color(0xFFFED7AA),
    ShareTextColorId.sky => const Color(0xFFE0F2FE),
  };

  /// Surface gelap (editorial/polaroid) jika teks terang.
  bool get prefersDarkSurface => this != ShareTextColorId.tinta;
}

enum ShareGradientId { senja, laut, hutan, pasir, charcoal }

extension ShareGradientIdX on ShareGradientId {
  String get label => switch (this) {
    ShareGradientId.senja => 'Senja',
    ShareGradientId.laut => 'Laut',
    ShareGradientId.hutan => 'Hutan',
    ShareGradientId.pasir => 'Pasir',
    ShareGradientId.charcoal => 'Charcoal',
  };

  List<Color> get colors => switch (this) {
    ShareGradientId.senja => const [
      Color(0xFF1B3A4B),
      Color(0xFFC45C26),
      Color(0xFF2A1810),
    ],
    ShareGradientId.laut => const [
      Color(0xFF0F172A),
      Color(0xFF1E3A5F),
      Color(0xFF0EA5E9),
    ],
    ShareGradientId.hutan => const [
      Color(0xFF14532D),
      Color(0xFF3F6212),
      Color(0xFFD9F99D),
    ],
    ShareGradientId.pasir => const [
      Color(0xFFF5E6D3),
      Color(0xFFC45C26),
      Color(0xFFA16207),
    ],
    ShareGradientId.charcoal => const [
      Color(0xFF292524),
      Color(0xFF57534E),
      Color(0xFFA8A29E),
    ],
  };
}

enum ShareTextElementId { lemma, padanan, definition, example, wordClass }

extension ShareTextElementIdX on ShareTextElementId {
  String get label => switch (this) {
    ShareTextElementId.lemma => 'Lemma',
    ShareTextElementId.padanan => 'Padanan',
    ShareTextElementId.definition => 'Definisi',
    ShareTextElementId.example => 'Contoh',
    ShareTextElementId.wordClass => 'Kelas kata',
  };
}

/// Offset + rotasi relatif terhadap posisi default (koordinat canvas).
class ShareTextLayout {
  const ShareTextLayout({
    this.offset = Offset.zero,
    this.rotationDeg = 0,
  });

  final Offset offset;
  final double rotationDeg;

  static const zero = ShareTextLayout();

  ShareTextLayout copyWith({Offset? offset, double? rotationDeg}) {
    return ShareTextLayout(
      offset: offset ?? this.offset,
      rotationDeg: rotationDeg ?? this.rotationDeg,
    );
  }
}

/// Kontrol editor praktis (bukan Canva).
class ShareEditorSettings {
  const ShareEditorSettings({
    this.lemmaFontScale = 1.0,
    this.bodyFontScale = 1.0,
    this.overlayStrength = 0.75,
    this.fontPair = ShareFontPair.classic,
    this.textColorId = ShareTextColorId.putih,
    this.gradientId = ShareGradientId.senja,
    this.showWordClass = true,
    this.showPadanan = true,
    this.showDefinition = true,
    this.showExample = false,
    this.showWatermark = true,
    this.lemmaLayout = ShareTextLayout.zero,
    this.padananLayout = ShareTextLayout.zero,
    this.definitionLayout = ShareTextLayout.zero,
    this.exampleLayout = ShareTextLayout.zero,
    this.wordClassLayout = ShareTextLayout.zero,
  });

  final double lemmaFontScale;
  final double bodyFontScale;
  final double overlayStrength;
  final ShareFontPair fontPair;
  final ShareTextColorId textColorId;
  final ShareGradientId gradientId;
  final bool showWordClass;
  final bool showPadanan;
  final bool showDefinition;
  final bool showExample;
  final bool showWatermark;
  final ShareTextLayout lemmaLayout;
  final ShareTextLayout padananLayout;
  final ShareTextLayout definitionLayout;
  final ShareTextLayout exampleLayout;
  final ShareTextLayout wordClassLayout;

  ShareTextLayout layoutFor(ShareTextElementId id) => switch (id) {
    ShareTextElementId.lemma => lemmaLayout,
    ShareTextElementId.padanan => padananLayout,
    ShareTextElementId.definition => definitionLayout,
    ShareTextElementId.example => exampleLayout,
    ShareTextElementId.wordClass => wordClassLayout,
  };

  ShareEditorSettings withLayout(ShareTextElementId id, ShareTextLayout layout) {
    return switch (id) {
      ShareTextElementId.lemma => copyWith(lemmaLayout: layout),
      ShareTextElementId.padanan => copyWith(padananLayout: layout),
      ShareTextElementId.definition => copyWith(definitionLayout: layout),
      ShareTextElementId.example => copyWith(exampleLayout: layout),
      ShareTextElementId.wordClass => copyWith(wordClassLayout: layout),
    };
  }

  ShareEditorSettings resetLayouts() {
    return copyWith(
      lemmaLayout: ShareTextLayout.zero,
      padananLayout: ShareTextLayout.zero,
      definitionLayout: ShareTextLayout.zero,
      exampleLayout: ShareTextLayout.zero,
      wordClassLayout: ShareTextLayout.zero,
    );
  }

  ShareEditorSettings copyWith({
    double? lemmaFontScale,
    double? bodyFontScale,
    double? overlayStrength,
    ShareFontPair? fontPair,
    ShareTextColorId? textColorId,
    ShareGradientId? gradientId,
    bool? showWordClass,
    bool? showPadanan,
    bool? showDefinition,
    bool? showExample,
    bool? showWatermark,
    ShareTextLayout? lemmaLayout,
    ShareTextLayout? padananLayout,
    ShareTextLayout? definitionLayout,
    ShareTextLayout? exampleLayout,
    ShareTextLayout? wordClassLayout,
  }) {
    return ShareEditorSettings(
      lemmaFontScale: lemmaFontScale ?? this.lemmaFontScale,
      bodyFontScale: bodyFontScale ?? this.bodyFontScale,
      overlayStrength: overlayStrength ?? this.overlayStrength,
      fontPair: fontPair ?? this.fontPair,
      textColorId: textColorId ?? this.textColorId,
      gradientId: gradientId ?? this.gradientId,
      showWordClass: showWordClass ?? this.showWordClass,
      showPadanan: showPadanan ?? this.showPadanan,
      showDefinition: showDefinition ?? this.showDefinition,
      showExample: showExample ?? this.showExample,
      showWatermark: showWatermark ?? this.showWatermark,
      lemmaLayout: lemmaLayout ?? this.lemmaLayout,
      padananLayout: padananLayout ?? this.padananLayout,
      definitionLayout: definitionLayout ?? this.definitionLayout,
      exampleLayout: exampleLayout ?? this.exampleLayout,
      wordClassLayout: wordClassLayout ?? this.wordClassLayout,
    );
  }
}

enum ShareTemplateId {
  unsplash,
  kamusEditorial,
  posterHuruf,
  polaroid,
}

enum ShareRatioId {
  story,
  post,
}

extension ShareRatioIdX on ShareRatioId {
  double get width => 1080;

  double get height => switch (this) {
    ShareRatioId.story => 1920,
    ShareRatioId.post => 1080,
  };

  String get label => switch (this) {
    ShareRatioId.story => '9:16',
    ShareRatioId.post => '1:1',
  };
}

extension ShareTemplateIdX on ShareTemplateId {
  String get label => switch (this) {
    ShareTemplateId.unsplash => 'Unsplash',
    ShareTemplateId.kamusEditorial => 'Editorial',
    ShareTemplateId.posterHuruf => 'Poster',
    ShareTemplateId.polaroid => 'Polaroid',
  };

  bool get forcesNoPhoto => this == ShareTemplateId.posterHuruf;
}
