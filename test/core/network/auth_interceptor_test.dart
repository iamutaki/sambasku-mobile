import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthTokenStorage storage;
  late _RecordingAdapter adapter;
  late Dio dio;
  late Dio refreshDio;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'stale-access',
      'refreshToken': 'stale-refresh',
    });
    SharedPreferences.setMockInitialValues({'isAuth': true});
    storage = AuthTokenStorage();
    await storage.setIsAuth(true);

    adapter = _RecordingAdapter();
    refreshDio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    refreshDio.httpClientAdapter = adapter;

    dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: storage,
        baseUrl: 'https://api.test',
        refreshDio: refreshDio,
      ),
    );
  });

  test(
    '401 + refresh gagal → clearTokens sekali, tidak panggil /device/revoke',
    () async {
      var refreshHits = 0;
      adapter.handler = (options) {
        if (options.path.contains('/auth/refresh')) {
          refreshHits++;
          return _json(401, {
            'success': false,
            'error': {'code': 'UNAUTHORIZED'},
          });
        }
        if (options.path.contains('/device/revoke')) {
          fail(
            'Interceptor tidak boleh memanggil /device/revoke saat session-death',
          );
        }
        return _json(401, {
          'success': false,
          'error': {'code': 'UNAUTHORIZED'},
        });
      };

      await expectLater(
        () => dio.get('/api/v1/words/w1'),
        throwsA(isA<DioException>()),
      );

      expect(refreshHits, 1);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(await storage.getIsAuth(), isFalse);
    },
  );

  test('401 pada /device/revoke tidak memicu POST /auth/refresh', () async {
    var refreshHits = 0;
    var revokeHits = 0;
    adapter.handler = (options) {
      if (options.path.contains('/auth/refresh')) {
        refreshHits++;
        return _json(200, {
          'success': true,
          'data': {
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          },
        });
      }
      if (options.path.contains('/device/revoke')) {
        revokeHits++;
        return _json(401, {
          'success': false,
          'error': {'code': 'UNAUTHORIZED'},
        });
      }
      return _json(500, {'success': false});
    };

    await expectLater(
      () => dio.patch('/api/v1/device/revoke', data: {'udid': 'dev-1'}),
      throwsA(isA<DioException>()),
    );

    expect(revokeHits, 1);
    expect(refreshHits, 0);
    expect(await storage.getAccessToken(), 'stale-access');
  });

  test('401 + extra skipAuthRefresh tidak memicu refresh', () async {
    var refreshHits = 0;
    adapter.handler = (options) {
      if (options.path.contains('/auth/refresh')) {
        refreshHits++;
        return _json(200, {
          'success': true,
          'data': {
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          },
        });
      }
      return _json(401, {'success': false});
    };

    await expectLater(
      () => dio.get(
        '/api/v1/words/w1',
        options: Options(extra: {kSkipAuthRefreshExtra: true}),
      ),
      throwsA(isA<DioException>()),
    );

    expect(refreshHits, 0);
    expect(await storage.getAccessToken(), 'stale-access');
  });

  test('401 + refresh sukses → retry request asli sekali', () async {
    var refreshHits = 0;
    var wordHits = 0;
    adapter.handler = (options) {
      if (options.path.contains('/auth/refresh')) {
        refreshHits++;
        return _json(200, {
          'success': true,
          'data': {
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          },
        });
      }
      if (options.path.contains('/words/w1')) {
        wordHits++;
        if (wordHits == 1) {
          return _json(401, {'success': false});
        }
        return _json(200, {
          'success': true,
          'data': {'id': 'w1'},
        });
      }
      return _json(500, {'success': false});
    };

    final res = await dio.get('/api/v1/words/w1');
    expect(res.statusCode, 200);
    expect(refreshHits, 1);
    expect(wordHits, 2);
    expect(await storage.getAccessToken(), 'new-access');
    expect(await storage.getRefreshToken(), 'new-refresh');
  });
}

ResponseBody _json(int status, Map<String, Object?> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

typedef _AdapterHandler = ResponseBody Function(RequestOptions options);

class _RecordingAdapter implements HttpClientAdapter {
  _AdapterHandler? handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final h = handler;
    if (h == null) {
      return _json(500, {'success': false});
    }
    return h(options);
  }
}
