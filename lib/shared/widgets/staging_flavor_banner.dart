import 'package:flutter/material.dart';

import '../../flavors.dart';

/// Badge staging di dalam safe area (kanan atas).
/// `Banner` Flutter menempel pojok absolut → sering ketutup notch/status bar.
class StagingFlavorBanner extends StatelessWidget {
  const StagingFlavorBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!F.isStaging) return child;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        // IgnorePointer: jangan blok tombol/status bar di bawahnya
        const Positioned(
          top: 0,
          right: 0,
          child: IgnorePointer(
            child: SafeArea(
              // cukup inset atas + kanan (notch / camera cutout)
              left: false,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(top: 4, right: 8),
                child: _StgBadge(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StgBadge extends StatelessWidget {
  const _StgBadge();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAB308),
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(4),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          'STG',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            height: 1.2,
            color: Color(0xFF18181B),
          ),
        ),
      ),
    );
  }
}
