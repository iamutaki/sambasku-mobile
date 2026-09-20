import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forui_palettes.dart';

part 'forui_palette_controller.g.dart';

/// Palet warna forui pilihan user: persist ke SharedPreferences.
///
/// [preload] di main sebelum runApp - sama seperti ThemeModeController,
/// supaya frame pertama tidak flash ke [defaultPalette].
@Riverpod(keepAlive: true)
class ForuiPaletteController extends _$ForuiPaletteController {
  static const prefKey = 'foruiPalette';

  static String initial = defaultPalette;

  static Future<void> preload([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final raw = p.getString(prefKey);
    if (raw != null && foruiPalettes.containsKey(raw)) {
      initial = raw;
    } else {
      initial = defaultPalette;
    }
  }

  @override
  String build() => initial;

  Future<void> set(String name) async {
    if (!foruiPalettes.containsKey(name)) return;
    state = name;
    initial = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, name);
  }
}
