import 'package:fpdart/fpdart.dart';

import '../entities/word_summary.dart';
import '../failures/dictionary_failure.dart';
import '../repositories/dictionary_repository.dart';

/// Daftar semua kata A-Z (18-api-list-words.md) - browsing, bukan
/// pencarian: TIDAK ada rekaman search-miss di jalur ini.
class ListWordsUseCase {
  const ListWordsUseCase(this._repository);

  final DictionaryRepository _repository;

  Future<Either<DictionaryFailure, WordSearchPage>> call(
    ListWordsParams params,
  ) {
    return _repository.listWords(
      q: params.q.trim(),
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

class ListWordsParams {
  const ListWordsParams({
    required this.q,
    this.limit = 20,
    this.cursor,
  });

  final String q;
  final int limit;
  final String? cursor;
}
