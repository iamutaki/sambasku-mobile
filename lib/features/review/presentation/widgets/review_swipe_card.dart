import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import '../../../../core/theme/f_colors_x.dart';

/// Arah keputusan setelah swipe melewati ambang.
enum ReviewSwipeDirection { approve, reject }

/// Kartu tinjau dengan swipe horizontal (kanan = setuju, kiri = tolak).
///
/// [onSwiped] dipanggil setelah kartu animasi keluar. Return `true` agar kartu
/// tetap tersembunyi (lanjut item berikutnya); `false` mengembalikan kartu ke
/// tengah (batal alasan / error yang bisa diulang).
///
/// Gestur memakai `onHorizontalDrag*` supaya arena Flutter menyerahkan scroll
/// vertikal ke [ListView] di dalam kartu (axis-lock alami).
class ReviewSwipeCard extends StatefulWidget {
  const ReviewSwipeCard({
    super.key,
    required this.itemKey,
    required this.enabled,
    required this.onSwiped,
    required this.child,
  });

  /// Ganti nilai ini saat item antrean berganti agar posisi drag di-reset.
  final Object itemKey;

  /// Nonaktif saat request in-flight atau item bukan pending.
  final bool enabled;

  /// Dipanggil setelah fly-out. `true` = tetap keluar; `false` = spring back.
  final Future<bool> Function(ReviewSwipeDirection direction) onSwiped;

  final Widget child;

  @override
  State<ReviewSwipeCard> createState() => _ReviewSwipeCardState();
}

class _ReviewSwipeCardState extends State<ReviewSwipeCard>
    with SingleTickerProviderStateMixin {
  static const _thresholdFraction = 0.28;
  static const _flingVelocity = 700.0;
  static const _overlayMaxOpacity = 0.75;
  static const _overlayMinScale = 0.72;
  static const _overlayMaxScale = 1.08;
  static const _overlayVisibleFloor = 0.05;

  late final AnimationController _anim;
  double _dx = 0;
  double _width = 1;
  bool _busyGesture = false;
  bool _hapticFired = false;
  Animation<double>? _tween;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        final t = _tween;
        if (t == null) return;
        setState(() => _dx = t.value);
      });
  }

  @override
  void didUpdateWidget(covariant ReviewSwipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemKey != widget.itemKey) {
      _anim.stop();
      _tween = null;
      _dx = 0;
      _busyGesture = false;
      _hapticFired = false;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  double get _progress {
    final denom = _width * _thresholdFraction;
    if (denom <= 0) return 0;
    return (_dx / denom).clamp(-1.5, 1.5);
  }

  Future<void> _animateTo(double target, {Duration? duration}) async {
    _anim.duration = duration ?? const Duration(milliseconds: 220);
    _tween = Tween<double>(begin: _dx, end: target).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
    _anim.reset();
    await _anim.forward();
  }

  Future<void> _springBack() async {
    await _animateTo(0, duration: const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() {
      _busyGesture = false;
      _hapticFired = false;
    });
  }

  Future<void> _commit(ReviewSwipeDirection direction) async {
    if (_busyGesture) return;
    setState(() => _busyGesture = true);

    final target = direction == ReviewSwipeDirection.approve
        ? _width * 1.35
        : -_width * 1.35;
    await _animateTo(target, duration: const Duration(milliseconds: 200));
    if (!mounted) return;

    final keepDismissed = await widget.onSwiped(direction);
    if (!mounted) return;
    if (keepDismissed) {
      // Item berikutnya akan ganti [itemKey] dan mereset posisi.
      setState(() => _busyGesture = false);
      return;
    }
    await _springBack();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _busyGesture) return;
    setState(() {
      _dx += details.delta.dx;
      final crossed = _progress.abs() >= 1.0;
      if (crossed && !_hapticFired) {
        _hapticFired = true;
        HapticFeedback.selectionClick();
      } else if (!crossed) {
        _hapticFired = false;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!widget.enabled || _busyGesture) return;
    final threshold = _width * _thresholdFraction;
    final vx = details.primaryVelocity ?? 0;
    final approve =
        _dx > threshold || (_dx > 0 && vx > _flingVelocity);
    final reject =
        _dx < -threshold || (_dx < 0 && vx < -_flingVelocity);

    if (approve) {
      _commit(ReviewSwipeDirection.approve);
    } else if (reject) {
      _commit(ReviewSwipeDirection.reject);
    } else {
      _springBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolved =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
        if (resolved != _width) {
          _width = resolved;
        }

        final progress = _progress;
        final approveT = progress.clamp(0.0, 1.0);
        final rejectT = (-progress).clamp(0.0, 1.0);
        final angle = (_dx / _width) * 0.22;

        return GestureDetector(
          onHorizontalDragUpdate:
              widget.enabled && !_busyGesture ? _onHorizontalDragUpdate : null,
          onHorizontalDragEnd:
              widget.enabled && !_busyGesture ? _onHorizontalDragEnd : null,
          behavior: HitTestBehavior.translucent,
          child: Transform.translate(
            offset: Offset(_dx, 0),
            child: Transform.rotate(
              angle: angle,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      widget.child,
                      _SwipeDecisionOverlay(
                        t: approveT,
                        icon: FLucideIcons.check,
                        color: theme.colors.success,
                        semanticsLabel: 'Setujui',
                        maxOpacity: _overlayMaxOpacity,
                        minScale: _overlayMinScale,
                        maxScale: _overlayMaxScale,
                        visibleFloor: _overlayVisibleFloor,
                      ),
                      _SwipeDecisionOverlay(
                        t: rejectT,
                        icon: FLucideIcons.x,
                        color: theme.colors.destructive,
                        semanticsLabel: 'Tolak',
                        maxOpacity: _overlayMaxOpacity,
                        minScale: _overlayMinScale,
                        maxScale: _overlayMaxScale,
                        visibleFloor: _overlayVisibleFloor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Ikon keputusan di tengah kartu — fade + scale mengikuti progress swipe.
///
/// [IgnorePointer] menjaga scroll vertikal [ListView] di dalam kartu.
class _SwipeDecisionOverlay extends StatelessWidget {
  const _SwipeDecisionOverlay({
    required this.t,
    required this.icon,
    required this.color,
    required this.semanticsLabel,
    required this.maxOpacity,
    required this.minScale,
    required this.maxScale,
    required this.visibleFloor,
  });

  /// 0..1 dari progress arah (approve atau reject).
  final double t;
  final IconData icon;
  final Color color;
  final String semanticsLabel;
  final double maxOpacity;
  final double minScale;
  final double maxScale;
  final double visibleFloor;

  @override
  Widget build(BuildContext context) {
    final opacity = t * maxOpacity;
    if (opacity < visibleFloor) {
      return const SizedBox.shrink();
    }

    final scale = lerpDouble(minScale, maxScale, t)!;

    return Positioned.fill(
      child: IgnorePointer(
        child: Semantics(
          label: semanticsLabel,
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Icon(icon, size: 96, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
