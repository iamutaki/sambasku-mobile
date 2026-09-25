import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_key.dart';
import '../../../core/cache/cached_json_client.dart';
import '../domain/translation_help_models.dart';

class TranslationHelpRepository {
  TranslationHelpRepository(this._dio, {CachedJsonClient? cache})
    : _cache = cache;

  final Dio _dio;
  final CachedJsonClient? _cache;

  static const _base = '/api/v1/translation-helps';

  Future<TranslationHelpUploadCredentials> getUploadToken() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_base/upload-token',
        queryParameters: {'folder': '/translation-helps'},
      );
      final data = res.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: res.requestOptions,
          message: 'Kredensial upload tidak lengkap',
        );
      }
      return TranslationHelpUploadCredentials.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        final code = (e.response?.data is Map)
            ? (e.response!.data as Map)['error_code']
            : null;
        if (code == 'IMAGE_UPLOAD_UNAVAILABLE') {
          throw const ImageUploadUnavailable();
        }
      }
      rethrow;
    }
  }

  Future<TranslationHelpSubmitResult> create({
    String? body,
    required List<TranslationHelpImageRef> images,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _base,
      data: {
        if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
        'images': images.map((e) => e.toJson()).toList(),
      },
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Response bantuan tidak lengkap',
      );
    }
    return TranslationHelpSubmitResult.fromJson(data);
  }

  Future<Either<TranslationHelpFailure, TranslationHelpPage>> listPublished({
    int limit = 20,
    String? cursor,
    String sort = 'latest',
    bool forceRefresh = false,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit,
        'sort': sort,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };
      final cache = _cache;
      Map<String, dynamic>? envelope;
      if (cache != null) {
        final key = buildCacheKey(
          method: 'GET',
          path: _base,
          query: query,
        );
        envelope = await cache.getOrFetch(
          key: key,
          cacheClass: CacheClass.socialPublic,
          forceRefresh: forceRefresh && (cursor == null || cursor.isEmpty),
          fetch: () async {
            final res = await _dio.get<Map<String, dynamic>>(
              _base,
              queryParameters: query,
            );
            final data = res.data;
            if (data == null) {
              throw StateError('Envelope translation-help kosong');
            }
            return data;
          },
        );
      } else {
        final res = await _dio.get<Map<String, dynamic>>(
          _base,
          queryParameters: query,
        );
        envelope = res.data;
      }
      return Either.right(_parsePage(envelope));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal memuat bantuan terjemahan'));
    } catch (e) {
      return Either.left(TranslationHelpFailure(e.toString()));
    }
  }

  Future<Either<TranslationHelpFailure, TranslationHelpPage>> listMine({
    int limit = 20,
    String? cursor,
    String? status,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_base/my',
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      return Either.right(_parsePage(res.data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal memuat riwayat bantuan'));
    } catch (e) {
      return Either.left(TranslationHelpFailure(e.toString()));
    }
  }

  Future<Either<TranslationHelpFailure, TranslationHelpItem>> getDetail(
    String id, {
    bool forceRefresh = false,
  }) async {
    try {
      final cache = _cache;
      Map<String, dynamic>? data;
      if (cache != null) {
        final key = buildCacheKey(
          method: 'GET',
          path: '$_base/$id',
        );
        final envelope = await cache.getOrFetch(
          key: key,
          cacheClass: CacheClass.socialPublic,
          forceRefresh: forceRefresh,
          fetch: () async {
            final res = await _dio.get<Map<String, dynamic>>('$_base/$id');
            final body = res.data;
            if (body == null) {
              throw StateError('Envelope detail bantuan kosong');
            }
            return body;
          },
        );
        final raw = envelope['data'];
        if (raw is Map) data = Map<String, dynamic>.from(raw);
      } else {
        final res = await _dio.get<Map<String, dynamic>>('$_base/$id');
        final raw = res.data?['data'];
        if (raw is Map) data = Map<String, dynamic>.from(raw);
      }
      if (data == null) {
        return Either.left(
          const TranslationHelpFailure('Detail bantuan tidak lengkap'),
        );
      }
      return Either.right(TranslationHelpItem.fromJson(data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal memuat detail bantuan'));
    } catch (e) {
      return Either.left(TranslationHelpFailure(e.toString()));
    }
  }

  Future<Either<TranslationHelpFailure, TranslationHelpReply>> createReply({
    required String helpId,
    required String body,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '$_base/$helpId/replies',
        data: {'body': body.trim()},
      );
      final data = res.data?['data'];
      if (data is! Map) {
        return Either.left(
          const TranslationHelpFailure('Balasan tidak lengkap'),
        );
      }
      return Either.right(
        TranslationHelpReply.fromJson(Map<String, dynamic>.from(data)),
      );
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal mengirim balasan'));
    } catch (e) {
      return Either.left(TranslationHelpFailure(e.toString()));
    }
  }

  Future<Either<TranslationHelpFailure, Unit>> deleteReply(String replyId) async {
    try {
      await _dio.delete<Map<String, dynamic>>('$_base/replies/$replyId');
      return Either.right(unit);
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal menghapus balasan'));
    } catch (e) {
      return Either.left(TranslationHelpFailure(e.toString()));
    }
  }

  TranslationHelpPage _parsePage(Map<String, dynamic>? body) {
    final data = body?['data'];
    final meta = body?['meta'];
    final items = <TranslationHelpItem>[];
    if (data is List) {
      for (final raw in data.whereType<Map>()) {
        items.add(
          TranslationHelpItem.fromJson(Map<String, dynamic>.from(raw)),
        );
      }
    }
    return TranslationHelpPage(
      items: items,
      nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
      hasMore: meta is Map && meta['has_more'] == true,
    );
  }

  TranslationHelpFailure _mapDio(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map) {
      var message = data['message']?.toString() ?? fallback;
      if (error.response?.statusCode == 429) {
        final retry = error.response?.headers.value('retry-after');
        if (retry != null && retry.isNotEmpty) {
          message = '$message Coba lagi dalam $retry detik.';
        }
      }
      return TranslationHelpFailure(
        message,
        errorCode: data['error_code']?.toString(),
      );
    }
    return TranslationHelpFailure(switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Koneksi lambat, coba lagi',
      DioExceptionType.connectionError => 'Tidak ada koneksi internet',
      _ => fallback,
    });
  }
}
