import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Tombol Facebook (Forui). Login dan register memakai widget yang sama.
class FacebookAuthButton extends StatelessWidget {
  const FacebookAuthButton({
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
          : const _FacebookMark(size: 18),
      child: Text(label),
    );
  }
}

class _FacebookMark extends StatelessWidget {
  const _FacebookMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF1877F2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'f',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
