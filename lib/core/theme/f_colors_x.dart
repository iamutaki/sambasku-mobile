import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Token semantik yang tidak ada di [FColors] Forui 0.22.
extension FColorsX on FColors {
  /// Hijau success adaptif — ikon/status terverifikasi.
  ///
  /// Light: Tailwind green-600 (`#16A34A`) ~4.5:1 di atas kartu putih.
  /// Dark: Tailwind green-400 (`#4ADE80`) ~8:1 di atas kartu zinc `#18181B`.
  /// Tidak mengikuti palet primary supaya tetap kebaca saat tema Zinc/Slate
  /// (primary hampir abu) maupun palet berwarna.
  Color get success => brightness == Brightness.dark
      ? const Color(0xFF4ADE80)
      : const Color(0xFF16A34A);
}
