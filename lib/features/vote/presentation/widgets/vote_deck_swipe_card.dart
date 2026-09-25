import 'package:flutter/material.dart';

import '../../../../core/widgets/swipe_decision_card.dart';

/// Arah aksi deck: kanan = masuk akal, kiri = kurang pas, atas = lewati.
enum VoteDeckSwipeDirection { agree, disagree, skip }

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

class VoteDeckSwipeCardState extends State<VoteDeckSwipeCard> {
  final _cardKey = GlobalKey<SwipeDecisionCardState>();

  Future<void> swipeAway(VoteDeckSwipeDirection direction) {
    final mapped = switch (direction) {
      VoteDeckSwipeDirection.agree => SwipeDecisionDirection.positive,
      VoteDeckSwipeDirection.disagree => SwipeDecisionDirection.negative,
      VoteDeckSwipeDirection.skip => SwipeDecisionDirection.skip,
    };
    return _cardKey.currentState?.swipeAway(mapped) ?? Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeDecisionCard(
      key: _cardKey,
      itemKey: widget.itemKey,
      enabled: widget.enabled,
      // Deck di dalam ListView Kontribusi — klaim swipe-atas vs scroll parent.
      allowNestedVerticalScroll: false,
      fallbackHeight: 240,
      positiveLabel: 'Masuk akal',
      negativeLabel: 'Kurang pas',
      skipLabel: 'Lewati',
      overlayStyle: SwipeDecisionOverlayStyle.label,
      onSwiped: (direction) => widget.onSwiped(switch (direction) {
        SwipeDecisionDirection.positive => VoteDeckSwipeDirection.agree,
        SwipeDecisionDirection.negative => VoteDeckSwipeDirection.disagree,
        SwipeDecisionDirection.skip => VoteDeckSwipeDirection.skip,
      }),
      child: widget.child,
    );
  }
}
