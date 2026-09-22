import 'package:fpdart/fpdart.dart';

import '../entities/word_summary.dart';
import '../failures/dictionary_failure.dart';
import '../repositories/dictionary_repository.dart';

/// Feed beranda (GET /api/v1/words/latest) - kata yang sudah disetujui,
/// bukan pencarian dan bukan daftar A-Z.
class ListLatestWordsUseCase {
  const ListLatestWordsUseCase(this._repository);

  final DictionaryRepository _repository;

  Future<Either<DictionaryFailure, WordSearchPage>> call(
    ListLatestWordsParams params,
  ) {
    return _repository.listLatest(
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

class ListLatestWordsParams {
  const ListLatestWordsParams({
    this.limit = 20,
    this.cursor,
  });

  final int limit;
  final String? cursor;
}
