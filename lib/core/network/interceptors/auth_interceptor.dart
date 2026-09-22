import 'package:dio/dio.dart';

import '../auth_token_storage.dart';
import '../../services/device_registration_holder.dart';

/// Interceptor auth (pola jnn_mobile, varian sambasku):
/// - onRequest: sisipkan Bearer access token
/// - onError 401: refresh SEKALI (queue via `_refreshFuture`), lalu retry;
///   gagal refresh → best-effort revoke FCM lalu clear token
///
/// Refresh memakai varian mobile (`docs/api/00-api-auth.md`):
/// `POST /api/v1/auth/refresh` body `{ refresh_token }`
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required AuthTokenStorage tokenStorage,
    required String baseUrl,
    Dio? refreshDio,
  }) : _tokenStorage = tokenStorage,
       _refreshDio =
           refreshDio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 15),
               sendTimeout: const Duration(seconds: 15),
               responseType: ResponseType.json,
               headers: {
                 'Accept': 'application/json',
                 'Content-Type': 'application/json',
               },
             ),
           );

  final AuthTokenStorage _tokenStorage;
  final Dio _refreshDio;
  Future<bool>? _refreshFuture;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // lanjut tanpa header auth
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final isAuthEndpoint =
        path.contains('/auth/login') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/register') ||
        path.contains('/auth/verify-email') ||
        path.contains('/auth/resend-otp');
    if (err.response?.statusCode != 401 || isAuthEndpoint) {
      return handler.next(err);
    }

    try {
      final refreshed = await _refreshToken();
      if (!refreshed) {
        await _clearSessionWithDeviceDetach();
        return handler.next(err);
      }

      final options = err.requestOptions;
      final newToken = await _tokenStorage.getAccessToken();
      if (newToken != null) {
        options.headers['Authorization'] = 'Bearer $newToken';
      }

      final response = await _refreshDio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      await _clearSessionWithDeviceDetach();
      return handler.next(e);
    } catch (_) {
      return handler.next(err);
    }
  }

  Future<void> _clearSessionWithDeviceDetach() async {
    await DeviceRegistrationHolder.instance?.revokeBestEffort();
    await _tokenStorage.clearTokens();
  }

  /// Single-flight: beberapa 401 bersamaan berbagi satu panggilan refresh.
  Future<bool> _refreshToken() {
    return _refreshFuture ??= _doRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final raw = response.data;
      if (raw == null || raw['success'] != true) return false;

      final data = raw['data'];
      if (data is! Map) return false;

      final accessToken = data['access_token'] as String?;
      final rotatedRefresh = data['refresh_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) return false;

      // Rotasi wajib di backend mobile; fallback ke token lama hanya
      // jika body tidak mengirimkan (mis. bug server).
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: (rotatedRefresh != null && rotatedRefresh.isNotEmpty)
            ? rotatedRefresh
            : refreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
