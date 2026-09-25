import 'dart:async';

import 'package:flutter/foundation.dart';

/// Maksimum request bersamaan ke host cold-start (tier terakhir).
///
/// 2 = satu request UI + satu replay/warm-up, tanpa 8 socket × 75s yang
/// memicu ANR di ColorOS. Request berikutnya mengantri, bukan dibatalkan,
/// jadi alur (search, detail, retry) tetap selesai.
const kColdHostMaxInFlight = 2;

/// Semaphore async sederhana. Sengaja bukan isolate: Dio hidup di isolate UI,
/// antrian di sini hanya menunda `handler.next` / `fetch`, tidak memblokir
/// frame.
class ColdHostGate {
  ColdHostGate({this.maxInFlight = kColdHostMaxInFlight});

  final int maxInFlight;
  int _inFlight = 0;
  final List<Completer<void>> _waiters = [];

  @visibleForTesting
  int get inFlight => _inFlight;

  @visibleForTesting
  int get waiting => _waiters.length;

  Future<void> acquire() async {
    if (_inFlight < maxInFlight) {
      _inFlight++;
      return;
    }
    final waiter = Completer<void>();
    _waiters.add(waiter);
    await waiter.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      // Slot pindah ke antrian: _inFlight tetap.
      _waiters.removeAt(0).complete();
      return;
    }
    if (_inFlight > 0) _inFlight--;
  }
}
