import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/word_detail.dart';
import '../../domain/entities/word_of_day.dart';
import '../../domain/entities/word_summary.dart';
import '../../domain/failures/dictionary_failure.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../datasources/dictionary_remote_datasource.dart';
import '../models/word_audio_dto.dart';
import '../models/word_detail_dto.dart';

class DictionaryRepositoryImpl implements DictionaryRepository {
  DictionaryRepositoryImpl(this._remoteDatasource);

  final DictionaryRemoteDatasource _remoteDatasource;

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String searchIn = 'lemma',
  }) async {
    try {
      final response = await _remoteDatasource.searchWords({
        'q': query,
        'limit': limit,
        'cursor': ?cursor,
        'search_in': searchIn,
      });

      if (response.success == false) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Pencarian gagal',
            errorCode: response.errorCode,
          ),
        );
      }

      final items = response.data;
      if (items == null) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Pencarian gagal',
            errorCode: response.errorCode,
          ),
        );
      }

      final meta = response.meta;
      return Either.right(
        WordSearchPage(
          items: items
              .map(
                (dto) => WordSummary(
                  id: dto.id,
                  lemma: dto.lemma,
                  languageCode: dto.languageCode,
                  wordType: dto.wordType,
                  status: dto.status,
                  isVerified: dto.isVerified,
                  matchedTranslation: dto.matchedTranslation,
                ),
              )
              .toList(),
          nextCursor: meta?['next_cursor'] as String?,
          hasMore: meta?['has_more'] as bool? ?? false,
        ),
      );
    } on DioException catch (error) {
      return Either.left(
        _mapDio(error, fallback: 'Pencarian gagal, periksa koneksi'),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? cursor,
  }) async {
    try {
      final response = await _remoteDatasource.listWords({
        'q': q,
        'limit': limit,
        'cursor': ?cursor,
      });

      if (response.success == false) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Daftar kata gagal dimuat',
            errorCode: response.errorCode,
          ),
        );
      }

      final items = response.data;
      if (items == null) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Daftar kata gagal dimuat',
            errorCode: response.errorCode,
          ),
        );
      }

      final meta = response.meta;
      return Either.right(
        WordSearchPage(
          items: items
              .map(
                (dto) => WordSummary(
                  id: dto.id,
                  lemma: dto.lemma,
                  languageCode: dto.languageCode,
                  wordType: dto.wordType,
                  status: dto.status,
                  isVerified: dto.isVerified,
                  sense: dto.sense,
                ),
              )
              .toList(),
          nextCursor: meta?['next_cursor'] as String?,
          hasMore: meta?['has_more'] as bool? ?? false,
        ),
      );
    } on DioException catch (error) {
      return Either.left(
        _mapDio(error, fallback: 'Daftar kata gagal dimuat, periksa koneksi'),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
  }) async {
    try {
      final response = await _remoteDatasource.listLatestWords({
        'limit': limit,
        'cursor': ?cursor,
      });

      if (response.success == false) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Feed gagal dimuat',
            errorCode: response.errorCode,
          ),
        );
      }

      final items = response.data;
      if (items == null) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Feed gagal dimuat',
            errorCode: response.errorCode,
          ),
        );
      }

      final meta = response.meta;
      return Either.right(
        WordSearchPage(
          items: items
              .map(
                (dto) => WordSummary(
                  id: dto.id,
                  lemma: dto.lemma,
                  languageCode: dto.languageCode,
                  wordType: dto.wordType,
                  status: dto.status,
                  isVerified: dto.isVerified,
                  sense: dto.sense,
                  approvedAt: dto.approvedAt == null
                      ? null
                      : DateTime.tryParse(dto.approvedAt!),
                ),
              )
              .toList(),
          nextCursor: meta?['next_cursor'] as String?,
          hasMore: meta?['has_more'] as bool? ?? false,
        ),
      );
    } on DioException catch (error) {
      return Either.left(
        _mapDio(error, fallback: 'Feed gagal dimuat, periksa koneksi'),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(String id) async {
    try {
      final response = await _remoteDatasource.getWordById(id);

      if (response.success == false) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Kata tidak ditemukan',
            errorCode: response.errorCode,
          ),
        );
      }

      final dto = response.data;
      if (dto == null) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Kata tidak ditemukan',
            errorCode: response.errorCode ?? 'WORD_NOT_FOUND',
          ),
        );
      }

      return Either.right(_mapDetail(dto));
    } on DioException catch (error) {
      return Either.left(
        _mapDio(
          error,
          fallback: 'Gagal memuat detail kata',
          notFoundMessage: 'Kata tidak ditemukan',
        ),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay() async {
    try {
      final response = await _remoteDatasource.getWordOfDay();

      if (response.success == false) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Gagal memuat kata hari ini',
            errorCode: response.errorCode,
          ),
        );
      }

      final dto = response.data;
      if (dto == null) return Either.right(null);

      return Either.right(
        WordOfDay(
          word: _mapDetail(dto),
          date: dto.date ?? '',
          isNewThisWeek: dto.isNewThisWeek,
        ),
      );
    } on DioException catch (error) {
      return Either.left(
        _mapDio(error, fallback: 'Gagal memuat kata hari ini'),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  WordDetail _mapDetail(WordDetailDto dto) => WordDetail(
    id: dto.id,
    lemma: dto.lemma,
    languageId: dto.languageId,
    notes: dto.notes,
    wordType: dto.wordType,
    status: dto.status,
    isVerified: dto.isVerified,
    isCorrected: dto.isCorrected,
    selfVerified: dto.selfVerified,
    verifiedAt: dto.verifiedAt,
    verifiedBy: dto.verifiedBy == null
        ? null
        : WordVerifier(
            username: dto.verifiedBy!.username,
            role: dto.verifiedBy!.role,
          ),
    meanings: dto.meanings
        .map(
          (m) => WordMeaning(
            id: m.id,
            wordClassId: m.wordClass?.id,
            // ponytail: format di mapper biar UI cukup pakai wordClassName
            wordClassName: m.wordClass == null
                ? null
                : (m.wordClass!.alias == null || m.wordClass!.alias!.isEmpty)
                ? m.wordClass!.name
                : '${m.wordClass!.name} (${m.wordClass!.alias})',
            definition: m.definition,
            orderIndex: m.orderIndex,
            translations: m.translations
                .map(
                  (t) => WordTranslation(
                    text: t.translationText,
                    type: t.translationType,
                    languageId: t.languageId,
                  ),
                )
                .toList(),
            examples: m.examples
                .map(
                  (e) => WordExample(
                    id: e.id,
                    sourceSentence: e.sourceSentence,
                    targetSentence: e.targetSentence,
                    audios: e.audios.map(_mapAudio).toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList(),
    categories: dto.categories
        .map((c) => WordCategory(id: c.id, name: c.name))
        .toList(),
    pronunciations: dto.pronunciations
        .map((p) => WordPronunciation(notation: p.notation, value: p.value))
        .toList(),
    audios: sortWordAudios(dto.audios.map(_mapAudio).toList()),
    images: dto.images
        .map(
          (i) => WordImage(
            id: i.id,
            url: i.url,
            altText: i.altText,
            isPrimary: i.isPrimary,
          ),
        )
        .toList(),
    relatedWords: dto.relatedWords
        .map(
          (r) => RelatedWord(
            wordId: r.wordId,
            lemma: r.lemma,
            relationType: r.relationType,
          ),
        )
        .toList(),
    appearsIn: dto.appearsIn
        .map(
          (r) => RelatedWord(
            wordId: r.wordId,
            lemma: r.lemma,
            relationType: r.relationType,
          ),
        )
        .toList(),
    variants: dto.variants
        .map(
          (v) => WordVariant(
            form: v.form,
            variantType: v.variantType,
            affixType: v.affixType,
            affixValue: v.affixValue,
            notes: v.notes,
          ),
        )
        .toList(),
  );

  WordAudio _mapAudio(WordAudioDto dto) => WordAudio(
    id: dto.id,
    url: dto.url,
    dialectId: dto.dialectId,
    speakerName: dto.speakerName,
    durationMs: dto.durationMs,
    isPrimary: dto.isPrimary,
    mimeType: dto.mimeType,
  );

  DictionaryFailure _mapDio(
    DioException error, {
    required String fallback,
    String? notFoundMessage,
  }) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['error_code'] as String?;
      final message = data['message'];
      if (error.response?.statusCode == 404) {
        return DictionaryFailure(
          message is String && message.isNotEmpty
              ? message
              : (notFoundMessage ?? 'Tidak ditemukan'),
          errorCode: code ?? 'WORD_NOT_FOUND',
        );
      }
      if (message is String && message.isNotEmpty) {
        return DictionaryFailure(message, errorCode: code);
      }
    }
    return DictionaryFailure(fallback);
  }
}
