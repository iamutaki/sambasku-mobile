import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:skeletonizer/skeletonizer.dart';

ShimmerEffect shareShimmerEffect(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final muted = context.theme.colors.muted;
  return ShimmerEffect(
    baseColor: isDark
        ? muted.withValues(alpha: 0.35)
        : const Color(0xFFE7E7EA),
    highlightColor: isDark
        ? muted.withValues(alpha: 0.55)
        : const Color(0xFFF4F4F5),
    duration: const Duration(milliseconds: 1500),
  );
}

/// Skeletonizer + shimmer baku fitur share (pola Home / detail kata).
class ShareSkeleton extends StatelessWidget {
  const ShareSkeleton({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shareShimmerEffect(context)),
      child: IgnorePointer(
        child: Skeletonizer(enabled: true, child: child),
      ),
    );
  }
}
