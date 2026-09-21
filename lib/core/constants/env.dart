import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';

import '../../flavors.dart';

part 'env.g.dart';

// Env compile-time via envied (Section 8) - host dipilih per flavor,
// TIDAK ADA host hardcode di datasource.
@Envied(path: '.env')
abstract final class Env {
  @EnviedField(varName: 'SAMBASKU_API_HOST_STAGING')
  static const String apiHostStaging = _Env.apiHostStaging;

  @EnviedField(varName: 'SAMBASKU_API_HOST_PRODUCTION', optional: true)
  static const String? apiHostProduction = _Env.apiHostProduction;

  /// Web OAuth client ID per env (sama dengan API `GOOGLE_CLIENT_ID`
  /// di wrangler/`.env` yang matching). Dipakai sebagai `serverClientId`.
  @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID_STAGING', optional: true)
  static const String? googleWebClientIdStaging = _Env.googleWebClientIdStaging;

  @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID_PRODUCTION', optional: true)
  static const String? googleWebClientIdProduction =
      _Env.googleWebClientIdProduction;

  /// Facebook App ID per env (sama dengan API `FACEBOOK_APP_ID`).
  /// Dipakai untuk menampilkan tombol; App Secret tidak pernah di app.
  @EnviedField(varName: 'FACEBOOK_APP_ID_STAGING', optional: true)
  static const String? facebookAppIdStaging = _Env.facebookAppIdStaging;

  @EnviedField(varName: 'FACEBOOK_APP_ID_PRODUCTION', optional: true)
  static const String? facebookAppIdProduction = _Env.facebookAppIdProduction;

  /// Base URL API sesuai flavor aktif
  static String get apiHost {
    if (kDebugMode && F.appFlavor == Flavor.production) {
      // production host kosong = belum rilis - jangan crash diam-diam
      return apiHostStaging;
    }
    return F.isStaging || apiHostProduction == null
        ? apiHostStaging
        : apiHostProduction!;
  }

  /// Client ID Google mengikuti backend yang sedang dihubungi (`apiHost`).
  static String? get googleWebClientId {
    if (kDebugMode && F.appFlavor == Flavor.production) {
      return _nonEmpty(googleWebClientIdStaging);
    }
    if (F.isStaging || apiHostProduction == null) {
      return _nonEmpty(googleWebClientIdStaging);
    }
    return _nonEmpty(googleWebClientIdProduction) ??
        _nonEmpty(googleWebClientIdStaging);
  }

  /// App ID Facebook mengikuti backend yang sedang dihubungi (`apiHost`).
  static String? get facebookAppId {
    if (kDebugMode && F.appFlavor == Flavor.production) {
      return _nonEmpty(facebookAppIdStaging);
    }
    if (F.isStaging || apiHostProduction == null) {
      return _nonEmpty(facebookAppIdStaging);
    }
    return _nonEmpty(facebookAppIdProduction) ?? _nonEmpty(facebookAppIdStaging);
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
