import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/word_detail.dart';
import '../../domain/entities/word_summary.dart';
import '../../domain/failures/dictionary_failure.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../datasources/dictionary_remote_datasource.dart';
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
        return Either.left(DictionaryFailure(
          response.message ?? 'Pencarian gagal',
          errorCode: response.errorCode,
        ));
      }

      final items = response.data;
      if (items == null) {
        return Either.left(DictionaryFailure(
          response.message ?? 'Pencarian gagal',
          errorCode: response.errorCode,
        ));
      }

      final meta = response.meta;
      return Either.right(WordSearchPage(
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
      ));
    } on DioException catch (error) {
      return Either.left(_mapDio(error, fallback: 'Pencarian gagal, periksa koneksi'));
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(String id) async {
    try {
      final response = await _remoteDatasource.getWordById(id);

      if (response.success == false) {
        return Either.left(DictionaryFailure(
          response.message ?? 'Kata tidak ditemukan',
          errorCode: response.errorCode,
        ));
      }

      final dto = response.data;
      if (dto == null) {
        return Either.left(DictionaryFailure(
          response.message ?? 'Kata tidak ditemukan',
          errorCode: response.errorCode ?? 'WORD_NOT_FOUND',
        ));
      }

      return Either.right(_mapDetail(dto));
    } on DioException catch (error) {
      return Either.left(_mapDio(
        error,
        fallback: 'Gagal memuat detail kata',
        notFoundMessage: 'Kata tidak ditemukan',
      ));
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
        verifiedAt: dto.verifiedAt,
        meanings: dto.meanings
            .map(
              (m) => WordMeaning(
                id: m.id,
                wordClassName: m.wordClass?.name,
                definition: m.definition,
                orderIndex: m.orderIndex,
                translations: m.translations
                    .map(
                      (t) => WordTranslation(
                        text: t.translationText,
                        type: t.translationType,
                      ),
                    )
                    .toList(),
                examples: m.examples
                    .map(
                      (e) => WordExample(
                        sourceSentence: e.sourceSentence,
                        targetSentence: e.targetSentence,
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
            .map(
              (p) => WordPronunciation(
                notation: p.notation,
                value: p.value,
              ),
            )
            .toList(),
        images: dto.images
            .map(
              (i) => WordImage(
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
