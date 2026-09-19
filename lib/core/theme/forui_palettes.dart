import 'package:forui/forui.dart';

/// Satu palet warna forui: label + varian light/dark (dipilih app sesuai brightness).
typedef ForuiPalette = ({
  String label,
  FPlatformThemeData light,
  FPlatformThemeData dark,
});

/// Katalog tema bawaan forui (FThemes) yang bisa dipilih pengguna.
final Map<String, ForuiPalette> foruiPalettes = {
  'neutral': (label: 'Netral', light: FThemes.neutral.light, dark: FThemes.neutral.dark),
  'zinc': (label: 'Zinc', light: FThemes.zinc.light, dark: FThemes.zinc.dark),
  'slate': (label: 'Slate', light: FThemes.slate.light, dark: FThemes.slate.dark),
  'blue': (label: 'Biru', light: FThemes.blue.light, dark: FThemes.blue.dark),
  'green': (label: 'Hijau', light: FThemes.green.light, dark: FThemes.green.dark),
  'orange': (label: 'Oranye', light: FThemes.orange.light, dark: FThemes.orange.dark),
  'red': (label: 'Merah', light: FThemes.red.light, dark: FThemes.red.dark),
  'rose': (label: 'Rose', light: FThemes.rose.light, dark: FThemes.rose.dark),
  'violet': (label: 'Violet', light: FThemes.violet.light, dark: FThemes.violet.dark),
  'yellow': (label: 'Kuning', light: FThemes.yellow.light, dark: FThemes.yellow.dark),
};

const defaultPalette = 'zinc';
