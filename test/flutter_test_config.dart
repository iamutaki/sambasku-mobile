import 'dart:async';

import 'package:sambasku_mobile/flavors.dart';

/// Flavor wajib sebelum widget yang baca `Env.*` / `F.logoAsset`.
/// Tanpa ini, Login/Register men-crash di `F.appFlavor` (late).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  F.appFlavor = Flavor.staging;
  await testMain();
}
