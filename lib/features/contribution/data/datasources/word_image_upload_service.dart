import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/failures/contribution_failure.dart';
import '../models/create_word_image_dto.dart';

/// Upload gambar kata lewat API (GitHub) — POST /api/v1/images.
/// 503 PUBLIC_IMAGE_UPLOAD_UNAVAILABLE → Left (UI sembunyikan field).
class WordImageUploadService {
  WordImageUploadService(this._dio);

  final Dio _dio;

  Future<Either<ContributionFailure, CreateWordImageDto>> uploadFile(
    File file, {
    bool isPrimary = false,
    String? altText,
  }) async {
    try {
      final fileName = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'image.jpg';
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/images',
        queryParameters: {'purpose': 'word'},
        data: form,
      );

      final body = res.data;
      if (body == null || body['success'] != true || body['data'] is! Map) {
        return Either.left(
          const ContributionFailure('Gagal mengunggah gambar, coba lagi'),
        );
      }
      final data = body['data'] as Map<String, dynamic>;
      final url = data['url'] as String?;
      final providerFileId = data['provider_file_id'] as String?;
      final sha = data['sha'] as String?;
      if (url == null || providerFileId == null) {
        return Either.left(
          const ContributionFailure('Gagal mengunggah gambar, coba lagi'),
        );
      }

      return Either.right(
        CreateWordImageDto(
          url: url,
          providerFileId: providerFileId,
          sha: sha,
          altText: altText,
          isPrimary: isPrimary,
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final code = data['error_code'] as String?;
        final message = data['message'];
        if (code == 'PUBLIC_IMAGE_UPLOAD_UNAVAILABLE' ||
            code == 'IMAGE_UPLOAD_UNAVAILABLE' ||
            e.response?.statusCode == 503) {
          return Either.left(
            ContributionFailure(
              message is String && message.isNotEmpty
                  ? message
                  : 'Penyimpanan gambar belum tersedia',
              errorCode: 'PUBLIC_IMAGE_UPLOAD_UNAVAILABLE',
            ),
          );
        }
        if (message is String && message.isNotEmpty) {
          return Either.left(ContributionFailure(message, errorCode: code));
        }
      }
      return Either.left(
        const ContributionFailure('Gagal mengunggah gambar, coba lagi'),
      );
    } catch (_) {
      return Either.left(
        const ContributionFailure('Gagal mengunggah gambar, coba lagi'),
      );
    }
  }
}
