import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_mode_controller.dart';
import 'flavors.dart';
import 'shared/dev_tool/dev_tool.dart';
import 'shared/dev_tool/storage_inspector/secure_storage_inspector.dart';
import 'shared/dev_tool/storage_inspector/shared_pref_inspector.dart';
import 'shared/widgets/staging_flavor_banner.dart';

class App extends ConsumerWidget {
  const App({super.key});

  // zinc - light/dark + override user (SharedPreferences)
  static final _light = FThemes.zinc.light.touch;
  static final _dark = FThemes.zinc.dark.touch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: F.title,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _light.toApproximateMaterialTheme(),
      darkTheme: _dark.toApproximateMaterialTheme(),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      builder: (context, child) {
        // Forui tidak auto-switch brightness - pilih variant dari Theme Material
        final fTheme = Theme.of(context).brightness == Brightness.dark
            ? _dark
            : _light;

        return FTheme(
          data: fTheme,
          child: FToaster(
            child: StagingFlavorBanner(
              child: DevToolOverlay(
                inspectors: [
                  NetworkMonitorInspector(),
                  SharedPrefInspector(),
                  SecureStorageInspector(),
                ],
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
      routerConfig: AppRouter.router,
    );
  }
}
