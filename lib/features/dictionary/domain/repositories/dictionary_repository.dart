import 'package:fpdart/fpdart.dart';

import '../entities/word_detail.dart';
import '../entities/word_of_day.dart';
import '../entities/word_summary.dart';
import '../failures/dictionary_failure.dart';

abstract interface class DictionaryRepository {
  /// Pencarian kata (cursor-based). [searchIn] 'lemma' = Sambas->Indonesia
  /// (default), 'translation' = Indonesia->Sambas (reverse).
  Future<Either<DictionaryFailure, WordSearchPage>> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String searchIn = 'lemma',
  });

  /// Detail kata by id. 404 WORD_NOT_FOUND → Failure.
  Future<Either<DictionaryFailure, WordDetail>> getWordById(String id);

  /// Detail kata published by lemma (URL publik web / deep link).
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(String lemma);

  /// Kata hari ini. Right(null) = korpus published kosong (bukan error).
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay();

  /// Daftar semua kata A-Z (18-api-list-words.md). Cursor komposit
  /// opaque; [q] = filter server-side (bukan pencarian - tanpa
  /// search-miss).
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? cursor,
  });

  /// Feed beranda: kata published urut waktu persetujuan.
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
  });
}
