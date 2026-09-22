import 'package:shared_preferences/shared_preferences.dart';

/// Flag onboarding first-install. Hilang saat uninstall = muncul lagi.
class OnboardingPrefs {
  OnboardingPrefs._();

  static const prefKey = 'sambasku_onboarding_done';

  /// Seed dari [preload] - default false (belum selesai) jika preload belum jalan.
  static bool done = false;

  static Future<void> preload([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    done = p.getBool(prefKey) ?? false;
  }

  static Future<bool> isDone([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    return p.getBool(prefKey) ?? false;
  }

  static Future<void> markDone([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setBool(prefKey, true);
    done = true;
  }
}
