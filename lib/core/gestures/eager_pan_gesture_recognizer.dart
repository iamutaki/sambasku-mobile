import 'package:flutter/gestures.dart';

/// [PanGestureRecognizer] that wins the arena against competing scrollables.
///
/// Needed when a swipe card sits inside a [ListView]/[CustomScrollView]: the
/// parent vertical drag otherwise cancels the card pan before axis-lock can
/// engage (horizontal still works; swipe-up does not).
class EagerPanGestureRecognizer extends PanGestureRecognizer {
  EagerPanGestureRecognizer({super.debugOwner, super.supportedDevices});

  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
