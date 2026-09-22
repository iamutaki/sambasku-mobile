import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Tombol Google (Forui). Login dan register memakai widget yang sama.
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.label,
    required this.onPress,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPress;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FButton(
      onPress: isLoading ? null : onPress,
      prefix: isLoading
          ? const FCircularProgress()
          : const _GoogleMark(size: 18),
      child: Text(label),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF4285F4),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'G',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleAuthDivider extends StatelessWidget {
  const GoogleAuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final muted = theme.colors.mutedForeground.withValues(alpha: 0.25);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: muted)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: muted)),
      ],
    );
  }
}
