import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'flavors.dart';

/// Entry utama. Flavor dari:
/// - `--flavor staging|production` → inject FLUTTER_APP_FLAVOR
/// - atau `--dart-define=FLAVOR=...` (fallback lokal)
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const flutterFlavor = String.fromEnvironment('FLUTTER_APP_FLAVOR');
  const dartFlavor = String.fromEnvironment('FLAVOR', defaultValue: 'staging');
  final flavorName = flutterFlavor.isNotEmpty ? flutterFlavor : dartFlavor;

  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == flavorName,
    orElse: () => Flavor.staging,
  );

  runApp(const ProviderScope(child: App()));
}
