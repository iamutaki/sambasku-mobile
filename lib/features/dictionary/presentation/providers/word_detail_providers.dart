import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/word_detail.dart';
import '../../domain/providers/dictionary_domain_providers.dart';

part 'word_detail_providers.g.dart';

/// Load detail kata; error object = [DictionaryFailure] (termasuk 404).
///
/// keepAlive: family per `wordId` tetap di cache saat pop detail → buka
/// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch.
/// Pull-to-refresh di halaman detail memanggil `invalidate` + await
/// `.future` supaya data segar.
@Riverpod(keepAlive: true)
Future<WordDetail> wordDetail(Ref ref, String wordId) async {
  final result = await ref.watch(getWordByIdUseCaseProvider)(wordId);
  return result.match(
    (failure) => throw failure,
    (detail) => detail,
  );
}
