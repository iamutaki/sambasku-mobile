import 'package:dio/dio.dart';

import '../auth_token_storage.dart';
import '../failover/api_host_resolver.dart';

/// Key di [RequestOptions.extra] untuk melewati refresh+retry pada 401.
const kSkipAuthRefreshExtra = 'skipAuthRefresh';

/// Interceptor auth (pola jnn_mobile, varian sambasku):
/// - onRequest: sisipkan Bearer access token
/// - onError 401: refresh SEKALI (queue via `_refreshFuture`), lalu retry;
///   gagal refresh → clear token saja (tanpa revoke FCM — revoke butuh
///   Bearer valid dan akan loop jika dipanggil di sini)
///
/// Path yang di-skip (tidak trigger refresh):
/// - `/auth/login|google|facebook|refresh|register|verify-email|resend-otp`
///   401 di login sosial adalah token penyedia ditolak, bukan sesi kedaluwarsa.
/// - `/device/revoke` (detach FCM; 401 di sini tidak boleh memicu refresh)
/// - request dengan `extra[kSkipAuthRefreshExtra] == true`
///
/// Refresh memakai varian mobile (`docs/api/00-api-auth.md`):
/// `POST /api/v1/auth/refresh` body `{ refresh_token }`
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required AuthTokenStorage tokenStorage,
    required ApiHostResolver hostResolver,
    Dio? refreshDio,
  }) : _tokenStorage = tokenStorage,
       _hostResolver = hostResolver,
       _refreshDio =
           refreshDio ??
           Dio(
             BaseOptions(
               baseUrl: hostResolver.activeHost,
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

  /// Dibaca ULANG tiap refresh. `_refreshDio` tidak punya interceptor, jadi
  /// `baseUrl`-nya tidak ikut ditulis FailoverInterceptor; kalau host aktif
  /// tidak disalin lagi di sini, pencarian pindah tier sementara refresh token
  /// tetap menembak tier 1 yang sedang mati.
  final ApiHostResolver _hostResolver;
  final Dio _refreshDio;
  Future<bool>? _refreshFuture;
  bool _clearingSession = false;

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
    if (err.response?.statusCode != 401 || _shouldSkipAuthRefresh(err.requestOptions)) {
      return handler.next(err);
    }

    try {
      final refreshed = await _refreshToken();
      if (!refreshed) {
        await _clearSession();
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
      await _clearSession();
      return handler.next(e);
    } catch (_) {
      return handler.next(err);
    }
  }

  bool _shouldSkipAuthRefresh(RequestOptions options) {
    if (options.extra[kSkipAuthRefreshExtra] == true) return true;
    final path = options.path;
    return path.contains('/auth/login') ||
        path.contains('/auth/google') ||
        path.contains('/auth/facebook') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/register') ||
        path.contains('/auth/verify-email') ||
        path.contains('/auth/resend-otp') ||
        path.contains('/device/revoke');
  }

  /// Hapus sesi lokal. Tidak memanggil revoke FCM: endpoint revoke wajib
  /// Bearer valid, jadi memanggilnya di sini (access/refresh sudah mati)
  /// memicu 401 → refresh → revoke → infinite loop.
  /// Detach FCM tetap di logout eksplisit ([AuthStatusNotifier.logout]).
  Future<void> _clearSession() async {
    if (_clearingSession) return;
    _clearingSession = true;
    try {
      await _tokenStorage.clearTokens();
    } finally {
      _clearingSession = false;
    }
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
      final tier = _hostResolver.activeTier;
      _refreshDio.options.baseUrl = tier.host;
      // Refresh tidak boleh menunggu cold start 75s - session recovery
      // yang menggantung main isolate terasa sebagai ANR.
      _refreshDio.options.connectTimeout = kDefaultTierTimeout;
      _refreshDio.options.receiveTimeout = kDefaultTierTimeout;
      _refreshDio.options.sendTimeout = kDefaultTierTimeout;
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
