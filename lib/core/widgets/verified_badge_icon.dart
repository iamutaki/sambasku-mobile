import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../theme/f_colors_x.dart';

/// Ikon `badgeCheck` untuk kata/akun terverifikasi.
/// Warna [FColorsX.success] menyesuaikan light/dark.
class VerifiedBadgeIcon extends StatelessWidget {
  const VerifiedBadgeIcon({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      FLucideIcons.badgeCheck,
      size: size,
      color: context.theme.colors.success,
    );
  }
}
