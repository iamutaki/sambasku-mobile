import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/failover/cold_host_gate.dart';

void main() {
  test('dua slot langsung, ketiga mengantri', () async {
    final gate = ColdHostGate(maxInFlight: 2);

    await gate.acquire();
    await gate.acquire();
    expect(gate.inFlight, 2);
    expect(gate.waiting, 0);

    var thirdEntered = false;
    final third = gate.acquire().then((_) => thirdEntered = true);
    await Future<void>.delayed(Duration.zero);
    expect(thirdEntered, isFalse);
    expect(gate.waiting, 1);

    gate.release();
    await third;
    expect(thirdEntered, isTrue);
    expect(gate.inFlight, 2);
    expect(gate.waiting, 0);

    gate.release();
    gate.release();
    expect(gate.inFlight, 0);
  });

  test('release tanpa waiter menurunkan inFlight', () async {
    final gate = ColdHostGate(maxInFlight: 2);
    await gate.acquire();
    expect(gate.inFlight, 1);
    gate.release();
    expect(gate.inFlight, 0);
  });

  test('acquire bersamaan tidak melebihi max (transfer slot, bukan increment ganda)',
      () async {
    final gate = ColdHostGate(maxInFlight: 2);
    await gate.acquire();
    await gate.acquire();

    final late = <int>[];
    final a = gate.acquire().then((_) => late.add(1));
    final b = gate.acquire().then((_) => late.add(2));
    await Future<void>.delayed(Duration.zero);
    expect(gate.waiting, 2);

    gate.release();
    await a;
    expect(gate.inFlight, 2);
    expect(late, [1]);

    // acquire baru di tengah: harus mengantri, jangan curi slot waiter B.
    var sneaked = false;
    final sneak = gate.acquire().then((_) => sneaked = true);
    await Future<void>.delayed(Duration.zero);
    expect(sneaked, isFalse);
    expect(gate.inFlight, 2);

    gate.release();
    await b;
    expect(sneaked, isFalse);
    expect(gate.inFlight, 2);

    gate.release();
    await sneak;
    expect(sneaked, isTrue);
    expect(gate.inFlight, 2);

    gate.release();
    gate.release();
    expect(gate.inFlight, 0);
  });
}
