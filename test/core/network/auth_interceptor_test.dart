import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/interceptors/auth_interceptor.dart';

/// Adapter antri respons JSON (tanpa package mock tambahan).
class _QueuedAdapter implements HttpClientAdapter {
  final List<ResponseBody Function(RequestOptions)> _handlers = [];
  final List<RequestOptions> requests = [];

  void enqueue(int status, Object? data) {
    _handlers.add((_) {
      final body = data == null ? '' : jsonEncode(data);
      return ResponseBody.fromString(
        body,
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_handlers.isEmpty) {
      throw StateError('Tidak ada response antrian untuk ${options.uri}');
    }
    return _handlers.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}
}

class _MemoryTokenStorage extends AuthTokenStorage {
  String? _access;
  String? _refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw ArgumentError('token kosong');
    }
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async =>
      (_access == null || _access!.isEmpty) ? null : _access;

  @override
  Future<String?> getRefreshToken() async =>
      (_refresh == null || _refresh!.isEmpty) ? null : _refresh;

  @override
  Future<void> clearTokens() async {
    _access = null;
    _refresh = null;
  }

  @override
  Future<bool> getIsAuth() async => _access != null;

  @override
  Future<void> setIsAuth(bool value) async {}
}

void main() {
  late Dio api;
  late Dio refreshDio;
  late _QueuedAdapter apiAdapter;
  late _QueuedAdapter refreshAdapter;
  late _MemoryTokenStorage storage;

  setUp(() async {
    storage = _MemoryTokenStorage();
    await storage.saveTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
    );

    apiAdapter = _QueuedAdapter();
    refreshAdapter = _QueuedAdapter();

    api = Dio(BaseOptions(baseUrl: 'https://example.test'));
    api.httpClientAdapter = apiAdapter;

    refreshDio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    refreshDio.httpClientAdapter = refreshAdapter;

    api.interceptors.add(
      AuthInterceptor(
        tokenStorage: storage,
        baseUrl: 'https://example.test',
        refreshDio: refreshDio,
      ),
    );
  });

  test('401 → refresh → retry dengan access token baru', () async {
    // request protected pertama: 401
    apiAdapter.enqueue(401, {
      'success': false,
      'error_code': 'TOKEN_EXPIRED',
      'message': 'expired',
    });
    // refresh
    refreshAdapter.enqueue(200, {
      'success': true,
      'data': {
        'access_token': 'new-access',
        'expires_in': 900,
        'refresh_token': 'new-refresh',
      },
    });
    // retry via refreshDio.fetch(original options)
    refreshAdapter.enqueue(200, {'success': true, 'data': []});

    final response = await api.get('/api/v1/words/search');

    expect(response.statusCode, 200);
    expect(await storage.getAccessToken(), 'new-access');
    expect(await storage.getRefreshToken(), 'new-refresh');

    final refreshReq = refreshAdapter.requests.first;
    expect(refreshReq.path, '/api/v1/auth/refresh');
    expect(refreshReq.data, {'refresh_token': 'old-refresh'});
  });

  test('401 + refresh gagal → clear tokens', () async {
    apiAdapter.enqueue(401, {
      'success': false,
      'error_code': 'UNAUTHORIZED',
      'message': 'nope',
    });
    refreshAdapter.enqueue(401, {
      'success': false,
      'error_code': 'UNAUTHORIZED',
      'message': 'refresh mati',
    });

    await expectLater(
      () => api.get('/api/v1/words/search'),
      throwsA(isA<DioException>()),
    );

    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
  });
}
