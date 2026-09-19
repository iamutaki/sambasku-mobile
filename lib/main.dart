import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/theme/forui_palette_controller.dart';
import 'core/theme/theme_mode_controller.dart';
import 'flavors.dart';

/// Entry utama. Flavor dari:
/// - `--flavor staging|production` → inject FLUTTER_APP_FLAVOR
/// - atau `--dart-define=FLAVOR=...` (fallback lokal)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const flutterFlavor = String.fromEnvironment('FLUTTER_APP_FLAVOR');
  const dartFlavor = String.fromEnvironment('FLAVOR', defaultValue: 'staging');
  final flavorName = flutterFlavor.isNotEmpty ? flutterFlavor : dartFlavor;

  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == flavorName,
    orElse: () => Flavor.staging,
  );

  // Prefs sebelum runApp: frame pertama = preferensi tersimpan, bukan
  // ThemeMode.system (ikut device) yang lalu jump setelah hydrate async.
  final prefs = await SharedPreferences.getInstance();
  await ThemeModeController.preload(prefs);
  await ForuiPaletteController.preload(prefs);

  // retry: null = matikan auto-retry Riverpod 3 (default: 10x backoff ~47s).
  // Failure 4xx tidak transient - retry manual via tombol "Coba lagi" di UI;
  // satu-satunya retry bermakna (401 -> refresh sekali) sudah di AuthInterceptor.
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      child: const App(),
    ),
  );
}
