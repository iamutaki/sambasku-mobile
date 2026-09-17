import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_mode_controller.g.dart';

/// Preferensi tema: default system, toggle menyimpan light/dark ke SharedPreferences.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  static const prefKey = 'themeMode';

  @override
  ThemeMode build() {
    Future.microtask(_hydrate);
    return ThemeMode.system;
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(prefKey);
    if (raw == null || !ref.mounted) return;
    state = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Toggle berdasar brightness efektif saat ini → lawannya, lalu persist.
  Future<void> toggle(Brightness currentEffective) async {
    final next =
        currentEffective == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, next.name);
  }
}
