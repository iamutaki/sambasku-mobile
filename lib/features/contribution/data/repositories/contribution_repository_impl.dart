import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/api_response.dart';
import '../../domain/entities/submit_word_result.dart';
import '../../domain/failures/contribution_failure.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../datasources/contribution_remote_datasource.dart';
import '../models/create_word_request_dto.dart';

class ContributionRepositoryImpl implements ContributionRepository {
  ContributionRepositoryImpl(this._remoteDatasource);

  final ContributionRemoteDatasource _remoteDatasource;

  @override
  Future<Either<ContributionFailure, SubmitWordResult>> submitAnon({
    required String lemma,
    required String languageId,
    required String wordClassId,
    required String definition,
    String? dialectId,
    required List<String> translationTexts,
    List<String> categoryIds = const [],
    String? notes,
  }) async {
    try {
      final body = CreateWordRequestDto(
        lemma: lemma,
        languageId: languageId,
        wordClassId: wordClassId,
        definition: definition,
        dialectId: dialectId,
        translationTexts: translationTexts,
        categoryIds: categoryIds,
        notes: notes,
      );

      final response = await _remoteDatasource.submitWord(body);

      if (response.success == false) {
        return Either.left(
          ContributionFailure(
            response.message ?? 'Gagal mengirim usulan kata',
            errorCode: response.errorCode,
            details: response.details ?? const <ApiErrorDetail>[],
          ),
        );
      }

      final data = response.data;
      if (data == null) {
        return Either.left(
          ContributionFailure(
            response.message ?? 'Gagal mengirim usulan kata',
            errorCode: response.errorCode,
          ),
        );
      }

      final wordId = data.wordId;
      final status = data.status;

      if (wordId.isEmpty) {
        return Either.left(
          const ContributionFailure(
            'Server tidak mengembalikan word_id, coba lagi nanti',
            errorCode: 'INTERNAL_ERROR',
          ),
        );
      }

      return Either.right(
        SubmitWordResult(
          wordId: wordId,
          status: status,
          message: response.message,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(ContributionFailure(error.toString()));
    }
  }

  ContributionFailure _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['error_code'] as String?;
      final message = data['message'];
      final rawDetails = data['details'];
      final details = rawDetails is List
          ? rawDetails
                .whereType<Map<String, dynamic>>()
                .map(ApiErrorDetail.fromJson)
                .toList(growable: false)
          : const <ApiErrorDetail>[];

      if (message is String && message.isNotEmpty) {
        return ContributionFailure(message, errorCode: code, details: details);
      }
      return ContributionFailure(
        _fallbackForStatus(error.response?.statusCode, code),
        errorCode: code,
        details: details,
      );
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ContributionFailure('Koneksi lambat, coba lagi nanti');
      case DioExceptionType.connectionError:
        return const ContributionFailure('Tidak ada koneksi internet');
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
      default:
        return ContributionFailure(
          _fallbackForStatus(error.response?.statusCode, null),
        );
    }
  }

  String _fallbackForStatus(int? statusCode, String? errorCode) {
    if (statusCode == 429 || errorCode == 'RATE_LIMITED') {
      return 'Kirim terlalu sering. Coba lagi 1 jam lagi (limit 5 per jam).';
    }
    if (statusCode == 400) {
      return 'Periksa kembali input Anda (beberapa kolom invalid).';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang gangguan. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan saat mengirim usulan, coba lagi';
  }
}
