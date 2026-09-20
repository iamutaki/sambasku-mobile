import 'package:flutter/material.dart';

import '../../flavors.dart';

/// Logo brand per flavor. Staging memakai pita STG, production bersih.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size,
    this.borderRadius = 15,
    this.frameBuilder,
  });

  final double? size;
  final double borderRadius;
  final ImageFrameBuilder? frameBuilder;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        F.logoAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        frameBuilder: frameBuilder,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size ?? 120,
          height: size ?? 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.grey.shade200,
          ),
          child: Icon(
            Icons.menu_book_rounded,
            size: (size ?? 120) * 0.4,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
