import 'package:flutter/material.dart';

import '../../flavors.dart';

/// Wordmark horizontal (perisai + SambasKu). Email OTP, bukan login.
const kBrandWordmarkAsset = 'assets/icons/logo_horizontal.webp';

/// Logo persegi per flavor (`logo.png` / `logo.staging.png`), radius 15.
/// Login, onboarding, about. Staging: pita STG di aset.
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

/// Wordmark landscape. Tanpa ClipRRect persegi — rasio 734×212.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.frameBuilder});

  final ImageFrameBuilder? frameBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      kBrandWordmarkAsset,
      fit: BoxFit.contain,
      frameBuilder: frameBuilder,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.menu_book_rounded,
        size: 48,
        color: Colors.grey.shade400,
      ),
    );
  }
}
