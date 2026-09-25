import 'package:flutter/material.dart';

import '../../../../core/widgets/swipe_decision_card.dart';

/// Arah keputusan setelah swipe melewati ambang.
enum ReviewSwipeDirection { approve, reject, skip }

/// Kartu tinjau: kanan = setuju, kiri = tolak, atas = lewati.
///
/// [onSwiped] dipanggil setelah kartu animasi keluar. Return `true` agar kartu
/// tetap tersembunyi; `false` mengembalikan kartu ke tengah.
///
/// Isi kartu boleh di-scroll; swipe-atas skip hanya diklaim saat scroll di puncak.
/// Lewati juga lewat tombol panah di action bar.
class ReviewSwipeCard extends StatelessWidget {
  const ReviewSwipeCard({
    super.key,
    required this.itemKey,
    required this.enabled,
    required this.onSwiped,
    required this.child,
  });

  final Object itemKey;
  final bool enabled;
  final Future<bool> Function(ReviewSwipeDirection direction) onSwiped;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SwipeDecisionCard(
      itemKey: itemKey,
      enabled: enabled,
      allowNestedVerticalScroll: true,
      fallbackHeight: MediaQuery.sizeOf(context).height * 0.6,
      positiveLabel: 'Setujui',
      negativeLabel: 'Tolak',
      skipLabel: 'Lewati',
      overlayStyle: SwipeDecisionOverlayStyle.icon,
      onSwiped: (direction) => onSwiped(switch (direction) {
        SwipeDecisionDirection.positive => ReviewSwipeDirection.approve,
        SwipeDecisionDirection.negative => ReviewSwipeDirection.reject,
        SwipeDecisionDirection.skip => ReviewSwipeDirection.skip,
      }),
      child: child,
    );
  }
}
