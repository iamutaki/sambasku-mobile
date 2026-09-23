import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../theme/f_colors_x.dart';

/// Ikon `badgeAlert` untuk kata yang masih menunggu pengecekan.
/// Warna [FColorsX.warning] menyesuaikan light/dark.
class PendingReviewBadgeIcon extends StatelessWidget {
  const PendingReviewBadgeIcon({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      FLucideIcons.badgeAlert,
      size: size,
      color: context.theme.colors.warning,
    );
  }
}

/// Penjelasan status — dipanggil saat ikon di-tap (bukan teks permanen).
void showPendingReviewInfo(BuildContext context) {
  showFToast(
    context: context,
    title: const Text('Menunggu pengecekan'),
    description: const Text(
      'Kata ini belum diperiksa tim Sambasku. Artinya atau terjemahannya bisa saja kurang tepat.',
    ),
  );
}
