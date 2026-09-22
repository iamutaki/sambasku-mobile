import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/word_of_day.dart';
import '../../domain/providers/dictionary_domain_providers.dart';

part 'word_of_day_providers.g.dart';

/// Kata hari ini. Null = korpus kosong ATAU gagal (soft-fail: kartu hilang).
@riverpod
Future<WordOfDay?> wordOfDay(Ref ref) async {
  final result = await ref.watch(getWordOfDayUseCaseProvider)();
  return result.match((_) => null, (value) => value);
}
