import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/failover/api_host_resolver.dart';
import 'package:sambasku_mobile/core/network/failover/api_tier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiHostResolver resolver;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    resolver = ApiHostResolver.instance;
    resolver.onWarmUp = null;
    resolver.pinDuration = kTierPinDuration;
    await resolver.setForcedTier(null);
    resolver.configure(
      primaryHost: 'https://t1.test',
      fallbackHosts: const ['https://t2.test', 'https://t3.test'],
    );
  });

  test('mulai di tier 1 tanpa pin', () {
    expect(resolver.activeHost, 'https://t1.test');
    expect(resolver.isOnPrimary, isTrue);
    expect(resolver.pinRemaining, isNull);
  });

  test('tier terakhir memakai timeout cold start, sisanya default', () {
    expect(resolver.tiers[0].timeout, kDefaultTierTimeout);
    expect(resolver.tiers[1].timeout, kDefaultTierTimeout);
    expect(resolver.tiers[2].timeout, kColdStartTierTimeout);
  });

  test('naik SATU tier per kegagalan, tidak langsung ke tier terakhir', () {
    expect(resolver.advanceTier()?.host, 'https://t2.test');
    expect(resolver.activeHost, 'https://t2.test');

    expect(resolver.advanceTier()?.host, 'https://t3.test');
    expect(resolver.activeHost, 'https://t3.test');
  });

  test('tier terakhir terminal - advanceTier null, tidak ada host keempat', () {
    resolver.advanceTier();
    resolver.advanceTier();
    expect(resolver.advanceTier(), isNull);
    expect(resolver.activeHost, 'https://t3.test');
  });

  test('pin habis → kembali ke tier 1, BUKAN ke tier antara', () async {
    resolver.pinDuration = const Duration(milliseconds: 60);
    resolver.advanceTier();
    resolver.advanceTier();
    expect(resolver.activeHost, 'https://t3.test');

    await Future<void>.delayed(const Duration(milliseconds: 120));

    // Langsung tier 1 - primer yang sudah pulih dipakai lagi seketika, tanpa
    // mampir ke tier 2 dulu.
    expect(resolver.activeHost, 'https://t1.test');
    expect(resolver.pinRemaining, isNull);
  });

  test('tombol lepas pin mengembalikan ke tier 1', () {
    resolver.advanceTier();
    expect(resolver.activeHost, 'https://t2.test');
    resolver.resetToPrimary();
    expect(resolver.activeHost, 'https://t1.test');
  });

  test('warm-up membangunkan tier SETELAH yang di-pin, sekali per pin', () {
    final warmed = <ApiTier>[];
    resolver.onWarmUp = warmed.add;

    resolver.advanceTier(); // pin tier 2 → hangatkan tier 3
    expect(warmed.map((t) => t.host), ['https://t3.test']);

    resolver.advanceTier(); // pin tier 3 → tidak ada tier 4
    expect(warmed.length, 1);
  });

  test('tanpa cadangan (staging) breaker tidak punya tujuan', () {
    resolver.configure(primaryHost: 'https://only.test', fallbackHosts: const []);
    expect(resolver.hasFallbacks, isFalse);
    expect(resolver.advanceTier(), isNull);
    expect(resolver.tiers.single.timeout, kDefaultTierTimeout);
  });

  test('saat host dipaksa, breaker tidak cascade ke tier berikutnya', () async {
    await resolver.setForcedTier(0);
    expect(resolver.advanceTier(), isNull);
    expect(resolver.activeHost, 'https://t1.test');
  });

  test('paksa tier mengabaikan pin dan tersimpan di prefs', () async {
    resolver.advanceTier();
    expect(resolver.activeHost, 'https://t2.test');

    await resolver.setForcedTier(2);
    expect(resolver.activeHost, 'https://t3.test');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('devToolForcedApiTier'), 2);

    await resolver.setForcedTier(null);
    expect(prefs.getInt('devToolForcedApiTier'), -1);
  });
}
