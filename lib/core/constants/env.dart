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
}
