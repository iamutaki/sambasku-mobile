import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/failover/infra_failure.dart';

DioException _err({
  DioExceptionType type = DioExceptionType.badResponse,
  int? status,
  Object? data,
}) {
  final options = RequestOptions(path: '/api/v1/words');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response<Object?>(
            requestOptions: options,
            statusCode: status,
            data: data,
          ),
  );
}

void main() {
  group('isInfraFailure - MEMINDAHKAN tier', () {
    test('timeout dan koneksi putus', () {
      expect(isInfraFailure(_err(type: DioExceptionType.connectionTimeout)), isTrue);
      expect(isInfraFailure(_err(type: DioExceptionType.receiveTimeout)), isTrue);
      expect(isInfraFailure(_err(type: DioExceptionType.connectionError)), isTrue);
      expect(isInfraFailure(_err(type: DioExceptionType.unknown)), isTrue);
    });

    test('502 dan 504', () {
      expect(isInfraFailure(_err(status: 502)), isTrue);
      expect(isInfraFailure(_err(status: 504)), isTrue);
    });

    test('503 UPSTREAM_CAPACITY - batas subrequest Workers', () {
      expect(
        isInfraFailure(
          _err(status: 503, data: {'success': false, 'error_code': 'UPSTREAM_CAPACITY'}),
        ),
        isTrue,
      );
    });

    test('body HTML - halaman error Cloudflare, bukan aplikasi kita', () {
      expect(
        isInfraFailure(_err(status: 502, data: '<html>error 1101</html>')),
        isTrue,
      );
      expect(
        isInfraFailure(_err(status: 500, data: '<html>error 1102</html>')),
        isTrue,
      );
    });
  });

  group('isInfraFailure - TIDAK memindahkan tier', () {
    test('401 tetap urusan AuthInterceptor', () {
      expect(isInfraFailure(_err(status: 401, data: {'success': false})), isFalse);
    });

    test('429 RATE_LIMITED - pindah host justru menembus rate limit', () {
      expect(
        isInfraFailure(
          _err(status: 429, data: {'success': false, 'error_code': 'RATE_LIMITED'}),
        ),
        isFalse,
      );
    });

    test('JSON 500 INTERNAL_ERROR adalah bug aplikasi - sama di semua tier', () {
      expect(
        isInfraFailure(
          _err(status: 500, data: {'success': false, 'error_code': 'INTERNAL_ERROR'}),
        ),
        isFalse,
      );
    });

    test('503 konfigurasi (provider mati) bukan soal kapasitas', () {
      expect(
        isInfraFailure(
          _err(
            status: 503,
            data: {'success': false, 'error_code': 'GOOGLE_AUTH_UNAVAILABLE'},
          ),
        ),
        isFalse,
      );
    });

    test('400/404/409 dan cancel', () {
      expect(isInfraFailure(_err(status: 400, data: {'success': false})), isFalse);
      expect(isInfraFailure(_err(status: 404, data: {'success': false})), isFalse);
      expect(isInfraFailure(_err(status: 409, data: {'success': false})), isFalse);
      expect(isInfraFailure(_err(type: DioExceptionType.cancel)), isFalse);
    });
  });

  group('isReplayableMethod', () {
    test('hanya GET/HEAD - mutasi tidak boleh dobel', () {
      expect(isReplayableMethod('get'), isTrue);
      expect(isReplayableMethod('HEAD'), isTrue);
      expect(isReplayableMethod('POST'), isFalse);
      expect(isReplayableMethod('PATCH'), isFalse);
      expect(isReplayableMethod('PUT'), isFalse);
      expect(isReplayableMethod('DELETE'), isFalse);
    });
  });
}
