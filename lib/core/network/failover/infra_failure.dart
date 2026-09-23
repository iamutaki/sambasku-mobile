import 'package:dio/dio.dart';

/// Apakah [err] adalah kegagalan INFRASTRUKTUR, yaitu server belum menjawab
/// sebagai aplikasi.
///
/// Pembedaan ini yang menjaga breaker tidak salah pindah:
/// - 401 tetap urusan `AuthInterceptor`
/// - 429 `RATE_LIMITED` tidak dipindahkan, karena pindah host justru akan
///   menembus rate limit lewat ember kedua
/// - JSON 500 `INTERNAL_ERROR` adalah bug aplikasi; ia sama saja di semua tier
///
/// Satu-satunya 5xx yang dianggap layak pindah adalah yang menandakan
/// infrastruktur, termasuk `UPSTREAM_CAPACITY` (batas subrequest Workers) yang
/// sengaja dibuat API supaya kegagalan itu bisa dikenali dari luar.
bool isInfraFailure(DioException err) {
  switch (err.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
      return false;
    // Transform respons kelamaan = batas di sisi klien, bukan server. Pindah
    // tier tidak memperbaikinya.
    case DioExceptionType.transformTimeout:
      return false;
    case DioExceptionType.unknown:
      // Dio memakai `unknown` untuk kegagalan socket/DNS yang tidak terbungkus.
      return err.response == null;
    case DioExceptionType.badResponse:
      break;
  }

  final response = err.response;
  if (response == null) return true;

  final status = response.statusCode ?? 0;
  if (status == 502 || status == 503 || status == 504) {
    // 503 bisa datang dari aplikasi juga (mis. provider mati). Hanya
    // UPSTREAM_CAPACITY dan 503 tanpa envelope JSON yang berarti kapasitas.
    if (status == 503) return _isCapacityEnvelope(response.data);
    return true;
  }

  // Halaman error HTML Cloudflare (1015, 1027, 1101, 1102) datang dengan status
  // apa pun dan BUKAN JSON. Body non-JSON = permintaan tidak pernah sampai ke
  // aplikasi kita.
  if (status >= 500 && !_looksLikeJsonEnvelope(response.data)) return true;

  return false;
}

/// 503 dari aplikasi membawa envelope JSON dengan `error_code`. Yang menandakan
/// kapasitas hanya `UPSTREAM_CAPACITY`; sisanya (mis.
/// `GOOGLE_AUTH_UNAVAILABLE`) adalah konfigurasi dan akan sama di tier lain.
bool _isCapacityEnvelope(Object? data) {
  if (!_looksLikeJsonEnvelope(data)) return true; // 503 tanpa JSON = infra
  final code = (data as Map)['error_code'];
  return code == 'UPSTREAM_CAPACITY';
}

bool _looksLikeJsonEnvelope(Object? data) =>
    data is Map && data.containsKey('success');

/// Boleh diulang otomatis? Hanya metode idempoten.
///
/// POST/PATCH/PUT/DELETE tidak diulang walau host sudah pindah: timeout terima
/// respons bisa berarti server SUDAH menyimpan, jadi mengulang bisa membuat
/// kata, usulan, atau vote ganda. Tier baru tetap di-pin, sehingga percobaan
/// ulang dari pengguna sendiri sudah mendarat di tier yang benar.
bool isReplayableMethod(String method) {
  final m = method.toUpperCase();
  return m == 'GET' || m == 'HEAD';
}
