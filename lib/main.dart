import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/network/auth_token_storage.dart';
import 'core/network/network_providers.dart';
import 'core/services/device_id_service.dart';
import 'core/services/device_registration_holder.dart';
import 'core/services/device_registration_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/forui_palette_controller.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/device/data/datasources/device_remote_datasource.dart';
import 'features/device/data/repositories/device_repository_impl.dart';
import 'features/onboarding/data/onboarding_prefs.dart';
import 'flavors.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

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
  await OnboardingPrefs.preload(prefs);

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Izin notifikasi diminta di onboarding slide 3, bukan di cold start.
  await NotificationService.init();

  final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
  debugPrint('FCM token: ${fcmToken.isEmpty ? "(empty)" : "${fcmToken.substring(0, 12)}..."}');

  // Container agar device repo memakai Dio yang sama (dengan AuthInterceptor).
  final container = ProviderContainer(
    retry: (_, _) => null,
  );
  final dio = container.read(dioProvider);
  final registrationService = DeviceRegistrationService(
    repository: DeviceRepositoryImpl(DeviceRemoteDatasource(dio)),
    tokenStorage: AuthTokenStorage.instance,
    deviceIdService: DeviceIdService(prefs: prefs),
    initialFcmToken: fcmToken,
  );
  DeviceRegistrationHolder.instance = registrationService;
  await registrationService.start();

  // retry: null = matikan auto-retry Riverpod 3 (default: 10x backoff ~47s).
  // Failure 4xx tidak transient - retry manual via tombol "Coba lagi" di UI;
  // satu-satunya retry bermakna (401 -> refresh sekali) sudah di AuthInterceptor.
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
