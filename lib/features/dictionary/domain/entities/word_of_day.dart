import 'word_detail.dart';

/// Kata hari ini: detail reuse + tanggal WIB seed + chip mingguan.
class WordOfDay {
  const WordOfDay({
    required this.word,
    required this.date,
    required this.isNewThisWeek,
  });

  final WordDetail word;
  final String date;
  final bool isNewThisWeek;

  /// Arti pertama (definition), fallback terjemahan pertama.
  String get firstSense {
    if (word.meanings.isEmpty) return '';
    final meaning = word.meanings.first;
    final definition = meaning.definition?.trim();
    if (definition != null && definition.isNotEmpty) return definition;
    if (meaning.translations.isEmpty) return '';
    return meaning.translations.first.text.trim();
  }
}
