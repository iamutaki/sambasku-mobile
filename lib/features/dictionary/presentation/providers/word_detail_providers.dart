import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/word_detail.dart';
import '../../domain/providers/dictionary_domain_providers.dart';

part 'word_detail_providers.g.dart';

/// Load detail kata; error object = [DictionaryFailure] (termasuk 404).
@riverpod
Future<WordDetail> wordDetail(Ref ref, String wordId) async {
  final result = await ref.watch(getWordByIdUseCaseProvider)(wordId);
  return result.match(
    (failure) => throw failure,
    (detail) => detail,
  );
}
