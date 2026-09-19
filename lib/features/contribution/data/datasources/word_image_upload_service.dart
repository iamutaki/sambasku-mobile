import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/failures/contribution_failure.dart';
import '../datasources/image_remote_datasource.dart';
import '../datasources/imagekit_uploader.dart';
import '../models/create_word_image_dto.dart';

/// Token backend → upload CDN → DTO siap dikirim di images[].
/// 503 IMAGE_UPLOAD_UNAVAILABLE → Left dengan errorCode itu (UI sembunyikan
/// field). Token sekali pakai: satu getUploadToken per file.
class WordImageUploadService {
  WordImageUploadService(this._remote, this._uploader);

  final ImageRemoteDatasource _remote;
  final ImageKitUploader _uploader;

  Future<Either<ContributionFailure, CreateWordImageDto>> uploadFile(
    File file, {
    bool isPrimary = false,
    String? altText,
  }) async {
    try {
      final tokenRes = await _remote.getUploadToken();
      if (tokenRes.success == false || tokenRes.data == null) {
        return Either.left(
          ContributionFailure(
            tokenRes.message ?? 'Gagal mendapat token upload',
            errorCode: tokenRes.errorCode,
          ),
        );
      }

      final uploaded = await _uploader.upload(
        file: file,
        creds: tokenRes.data!,
      );

      return Either.right(
        CreateWordImageDto(
          url: uploaded.url,
          providerFileId: uploaded.fileId,
          altText: altText,
          isPrimary: isPrimary,
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final code = data['error_code'] as String?;
        final message = data['message'];
        if (code == 'IMAGE_UPLOAD_UNAVAILABLE' || e.response?.statusCode == 503) {
          return Either.left(
            ContributionFailure(
              message is String && message.isNotEmpty
                  ? message
                  : 'Penyimpanan gambar belum tersedia',
              errorCode: 'IMAGE_UPLOAD_UNAVAILABLE',
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
