import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../core/network/failover/api_host_resolver.dart';
import '../../../core/network/failover/api_tier.dart';
import '../dev_tool_inspector.dart';

class ApiHostInspector extends DevToolInspector {
  @override
  Color get color => const Color(0xFF16A34A);

  @override
  String get description => 'Paksa tier API + status circuit breaker';

  @override
  IconData get icon => FLucideIcons.server;

  @override
  String get name => 'API Host';

  @override
  Widget buildPage(BuildContext context) => const _ApiHostPage();
}

class _ApiHostPage extends StatefulWidget {
  const _ApiHostPage();

  @override
  State<_ApiHostPage> createState() => _ApiHostPageState();
}

class _ApiHostPageState extends State<_ApiHostPage> {
  final _resolver = ApiHostResolver.instance;

  /// Ticker 1 detik: hitung-mundur pin berjalan tanpa notifikasi dari resolver,
  /// karena kedaluwarsa pin memang dihitung murni saat dibaca (tanpa timer).
  Timer? _ticker;

  /// host → hasil ping terakhir.
  final Map<String, String> _probeResults = {};
  bool _probing = false;
  CancelToken? _probeToken;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _resolver.pinRemaining == null) return;
      setState(() {});
    });
    _resolver.addListener(_onResolverChanged);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _probeToken?.cancel();
    _resolver.removeListener(_onResolverChanged);
    super.dispose();
  }

  void _onResolverChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _setMode(int? index) async {
    _probeToken?.cancel();
    await _resolver.setForcedTier(index);
  }

  Future<void> _probeAll() async {
    _probeToken?.cancel();
    _probeToken = CancelToken();
    final token = _probeToken!;
    setState(() {
      _probing = true;
      _probeResults.clear();
    });
    // Dio bersih + timeout PENDEK: jangan pakai 75s milik tier 3. Ping
    // beruntun dengan timeout itu menumpuk HttpClient native dan memicu
    // ANR di ColorOS saat host di-tap berulang.
    final dio = Dio(
      BaseOptions(
        connectTimeout: kHealthProbeTimeout,
        receiveTimeout: kHealthProbeTimeout,
        sendTimeout: kHealthProbeTimeout,
      ),
    );
    try {
      for (final tier in _resolver.tiers) {
        if (!mounted || token.isCancelled) return;
        final started = DateTime.now();
        String result;
        try {
          final res = await dio.get<void>(
            '${tier.host}/health',
            cancelToken: token,
            options: Options(validateStatus: (_) => true),
          );
          final ms = DateTime.now().difference(started).inMilliseconds;
          result = 'HTTP ${res.statusCode} - ${ms}ms';
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) return;
          final ms = DateTime.now().difference(started).inMilliseconds;
          result = 'GAGAL setelah ${ms}ms';
        } catch (_) {
          final ms = DateTime.now().difference(started).inMilliseconds;
          result = 'GAGAL setelah ${ms}ms';
        }
        if (!mounted || token.isCancelled) return;
        setState(() => _probeResults[tier.host] = result);
      }
    } finally {
      dio.close(force: true);
      if (mounted) setState(() => _probing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiers = _resolver.tiers;
    if (!_resolver.hasFallbacks) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Flavor ini hanya punya satu host, jadi tidak ada tier cadangan '
            'dan circuit breaker diam.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final active = _resolver.activeTier;
    final remaining = _resolver.pinRemaining;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatusCard(
          active: active,
          remaining: remaining,
          forced: _resolver.forcedTierIndex != null,
        ),
        const Gap(16),
        Row(
          children: [
            FButton(
              size: FButtonSizeVariant.xs,
              onPress: remaining == null ? null : _resolver.resetToPrimary,
              child: const Text('Lepas pin'),
            ),
            const Gap(8),
            FButton(
              size: FButtonSizeVariant.xs,
              onPress: _probing ? null : _probeAll,
              child: Text(_probing ? 'Menguji...' : 'Uji semua host'),
            ),
          ],
        ),
        const Gap(8),
        const Text(
          'Ping memakai timeout 8 detik. Render yang tidur mungkin gagal '
          'di tap pertama - itu normal, instance sudah mulai bangun.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const Gap(20),
        const Text(
          'MODE',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        _ModeTile(
          label: 'Otomatis',
          subtitle: 'Mulai di tier 1, pindah hanya saat gagal',
          selected: _resolver.forcedTierIndex == null,
          onTap: () => _setMode(null),
        ),
        for (final tier in tiers)
          _ModeTile(
            label: 'Tier ${tier.number}',
            subtitle: tier.host,
            selected: _resolver.forcedTierIndex == tier.index,
            onTap: () => _setMode(tier.index),
          ),
        const Gap(20),
        const Text(
          'TIER',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        for (final tier in tiers)
          _TierTile(
            tier: tier,
            isActive: tier.index == active.index,
            probeResult: _probeResults[tier.host],
          ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.active,
    required this.remaining,
    required this.forced,
  });

  final ApiTier active;
  final Duration? remaining;
  final bool forced;

  @override
  Widget build(BuildContext context) {
    final onPrimary = active.index == 0;
    final left = remaining;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (onPrimary ? Colors.green : Colors.orange).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (onPrimary ? Colors.green : Colors.orange).withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktif: ${active.label}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const Gap(4),
          Text(
            active.host,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Gap(4),
          Text(
            'Timeout ${active.timeout.inSeconds}s',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Gap(8),
          Text(
            forced
                ? 'Dipaksa dari dev tool - breaker diabaikan.'
                : left == null
                ? 'Tidak ada pin aktif.'
                : 'Pin tersisa ${left.inMinutes}m ${left.inSeconds % 60}s, '
                      'lalu tier 1 dicoba lagi.',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? Colors.green : Colors.grey,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierTile extends StatelessWidget {
  const _TierTile({
    required this.tier,
    required this.isActive,
    this.probeResult,
  });

  final ApiTier tier;
  final bool isActive;
  final String? probeResult;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.grey.shade400,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tier ${tier.number} - timeout ${tier.timeout.inSeconds}s',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  tier.host,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (probeResult != null)
                  Text(
                    probeResult!,
                    style: const TextStyle(fontSize: 11, color: Colors.blue),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
