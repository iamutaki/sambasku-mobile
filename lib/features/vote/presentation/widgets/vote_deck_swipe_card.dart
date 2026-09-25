import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import '../../../../core/gestures/eager_pan_gesture_recognizer.dart';
import '../../../../core/theme/f_colors_x.dart';

/// Arah aksi deck: kanan = masuk akal, kiri = kurang pas, atas = lewati.
enum VoteDeckSwipeDirection { agree, disagree, skip }

enum _AxisLock { none, horizontal, vertical }

/// Kartu swipe untuk deck nilai kata (bukan sesi tinjau verifikator).
///
/// [onSwiped] return `true` = kartu tetap keluar; `false` = spring back.
class VoteDeckSwipeCard extends StatefulWidget {
  const VoteDeckSwipeCard({
    super.key,
    required this.itemKey,
    required this.enabled,
    required this.onSwiped,
    required this.child,
  });

  final Object itemKey;
  final bool enabled;
  final Future<bool> Function(VoteDeckSwipeDirection direction) onSwiped;
  final Widget child;

  @override
  State<VoteDeckSwipeCard> createState() => VoteDeckSwipeCardState();
}

class VoteDeckSwipeCardState extends State<VoteDeckSwipeCard>
    with SingleTickerProviderStateMixin {
  static const _thresholdFraction = 0.28;
  static const _flingVelocity = 700.0;
  static const _axisLockSlop = 12.0;
  static const _overlayMaxOpacity = 0.75;
  static const _overlayMinScale = 0.72;
  static const _overlayMaxScale = 1.08;
  static const _overlayVisibleFloor = 0.05;

  late final AnimationController _anim;
  double _dx = 0;
  double _dy = 0;
  double _width = 1;
  double _height = 1;
  _AxisLock _lock = _AxisLock.none;
  bool _busyGesture = false;
  bool _hapticFired = false;
  Animation<Offset>? _tween;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        final t = _tween;
        if (t == null) return;
        setState(() {
          _dx = t.value.dx;
          _dy = t.value.dy;
        });
      });
  }

  @override
  void didUpdateWidget(covariant VoteDeckSwipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemKey != widget.itemKey) {
      _anim.stop();
      _tween = null;
      _dx = 0;
      _dy = 0;
      _lock = _AxisLock.none;
      _busyGesture = false;
      _hapticFired = false;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> swipeAway(VoteDeckSwipeDirection direction) =>
      _commit(direction);

  double get _hProgress {
    final denom = _width * _thresholdFraction;
    if (denom <= 0) return 0;
    return (_dx / denom).clamp(-1.5, 1.5);
  }

  double get _vProgress {
    final denom = _height * _thresholdFraction;
    if (denom <= 0) return 0;
    // Atas = negatif dy → progress skip positif.
    return (-_dy / denom).clamp(0.0, 1.5);
  }

  Future<void> _animateTo(Offset target, {Duration? duration}) async {
    _anim.duration = duration ?? const Duration(milliseconds: 220);
    _tween = Tween<Offset>(begin: Offset(_dx, _dy), end: target).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
    _anim.reset();
    await _anim.forward();
  }

  Future<void> _springBack() async {
    await _animateTo(Offset.zero, duration: const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() {
      _busyGesture = false;
      _hapticFired = false;
      _lock = _AxisLock.none;
    });
  }

  Future<void> _commit(VoteDeckSwipeDirection direction) async {
    if (_busyGesture) return;
    if (!widget.enabled) return;
    setState(() => _busyGesture = true);

    final target = switch (direction) {
      VoteDeckSwipeDirection.agree => Offset(_width * 1.35, 0),
      VoteDeckSwipeDirection.disagree => Offset(-_width * 1.35, 0),
      VoteDeckSwipeDirection.skip => Offset(0, -_height * 1.35),
    };
    await _animateTo(target, duration: const Duration(milliseconds: 200));
    if (!mounted) return;

    final keepDismissed = await widget.onSwiped(direction);
    if (!mounted) return;
    if (keepDismissed) {
      setState(() => _busyGesture = false);
      return;
    }
    await _springBack();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _busyGesture) return;
    final d = details.delta;
    setState(() {
      if (_lock == _AxisLock.none) {
        // Akumulasi dulu — delta per-frame jarang > slop.
        _dx += d.dx;
        _dy += d.dy;
        final ax = _dx.abs();
        final ay = _dy.abs();
        if (ax > _axisLockSlop || ay > _axisLockSlop) {
          if (ax >= ay) {
            _lock = _AxisLock.horizontal;
            _dy = 0;
          } else {
            _lock = _AxisLock.vertical;
            _dx = 0;
            // Hanya atas = skip.
            if (_dy > 0) _dy = 0;
          }
        }
      } else if (_lock == _AxisLock.horizontal) {
        _dx += d.dx;
      } else {
        // Hanya izinkan geser ke atas (skip); ke bawah di-clamp.
        _dy = (_dy + d.dy).clamp(-_height * 1.5, 0);
      }

      final crossed = _lock == _AxisLock.horizontal
          ? _hProgress.abs() >= 1.0
          : _vProgress >= 1.0;
      if (crossed && !_hapticFired) {
        _hapticFired = true;
        HapticFeedback.selectionClick();
      } else if (!crossed) {
        _hapticFired = false;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled || _busyGesture) return;
    final vx = details.velocity.pixelsPerSecond.dx;
    final vy = details.velocity.pixelsPerSecond.dy;
    final hThresh = _width * _thresholdFraction;
    final vThresh = _height * _thresholdFraction;

    if (_lock == _AxisLock.horizontal) {
      final agree = _dx > hThresh || (_dx > 0 && vx > _flingVelocity);
      final disagree = _dx < -hThresh || (_dx < 0 && vx < -_flingVelocity);
      if (agree) {
        _commit(VoteDeckSwipeDirection.agree);
      } else if (disagree) {
        _commit(VoteDeckSwipeDirection.disagree);
      } else {
        _springBack();
      }
      return;
    }

    if (_lock == _AxisLock.vertical) {
      final skip = _dy < -vThresh || vy < -_flingVelocity;
      if (skip) {
        _commit(VoteDeckSwipeDirection.skip);
      } else {
        _springBack();
      }
      return;
    }

    _springBack();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : 240.0;
        if (w != _width) _width = w;
        if (h != _height) _height = h;

        final hProg = _hProgress;
        final agreeT = hProg.clamp(0.0, 1.0);
        final disagreeT = (-hProg).clamp(0.0, 1.0);
        final skipT = _vProgress.clamp(0.0, 1.0);
        final angle = (_dx / _width) * 0.22;

        final canPan = widget.enabled && !_busyGesture;
        return RawGestureDetector(
          gestures: {
            EagerPanGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<EagerPanGestureRecognizer>(
              EagerPanGestureRecognizer.new,
              (instance) {
                instance
                  ..onUpdate = canPan ? _onPanUpdate : null
                  ..onEnd = canPan ? _onPanEnd : null
                  ..onCancel = canPan ? () => _springBack() : null;
              },
            ),
          },
          behavior: HitTestBehavior.translucent,
          child: Transform.translate(
            offset: Offset(_dx, _dy),
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
                      _SwipeLabelOverlay(
                        t: agreeT,
                        label: 'Masuk akal',
                        color: theme.colors.success,
                        maxOpacity: _overlayMaxOpacity,
                        minScale: _overlayMinScale,
                        maxScale: _overlayMaxScale,
                        visibleFloor: _overlayVisibleFloor,
                      ),
                      _SwipeLabelOverlay(
                        t: disagreeT,
                        label: 'Kurang pas',
                        color: theme.colors.destructive,
                        maxOpacity: _overlayMaxOpacity,
                        minScale: _overlayMinScale,
                        maxScale: _overlayMaxScale,
                        visibleFloor: _overlayVisibleFloor,
                      ),
                      _SwipeLabelOverlay(
                        t: skipT,
                        label: 'Lewati',
                        color: theme.colors.mutedForeground,
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

class _SwipeLabelOverlay extends StatelessWidget {
  const _SwipeLabelOverlay({
    required this.t,
    required this.label,
    required this.color,
    required this.maxOpacity,
    required this.minScale,
    required this.maxScale,
    required this.visibleFloor,
  });

  final double t;
  final String label;
  final Color color;
  final double maxOpacity;
  final double minScale;
  final double maxScale;
  final double visibleFloor;

  @override
  Widget build(BuildContext context) {
    if (t < visibleFloor) return const SizedBox.shrink();
    final opacity = (t * maxOpacity).clamp(0.0, maxOpacity);
    final scale = lerpDouble(minScale, maxScale, t)!;
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: context.theme.typography.sm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
