import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../dev_tool_inspector.dart';
import '../cache_source_copy.dart';
import '../data/models/network_request_record.dart';
import '../network_monitor_registry.dart';
import 'network_request_detail_page.dart';

class NetworkMonitorInspector extends DevToolInspector {
  @override
  Color get color => const Color(0xFF1A73E8);

  @override
  String get description => 'Rekam dan inspect request API';

  @override
  IconData get icon => FLucideIcons.wifi;

  @override
  String get name => 'Network Monitor';

  @override
  List<Widget> get appBarActions => [
    IconButton(
      tooltip: 'Clear',
      icon: const Icon(FLucideIcons.trash2),
      onPressed: NetworkMonitorRegistry.clearRecords.call,
    ),
  ];

  @override
  Widget buildPage(BuildContext context) => const NetworkMonitorPage();
}

class NetworkMonitorPage extends StatelessWidget {
  const NetworkMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<NetworkRequestRecord>>(
            stream: NetworkMonitorRegistry.observeRecords(),
            builder: (context, snapshot) {
              final records = snapshot.data ?? const <NetworkRequestRecord>[];

              if (records.isEmpty) {
                return const _EmptyNetworkMonitorState();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                itemCount: records.length,
                separatorBuilder: (_, _) => const Gap(8),
                itemBuilder: (context, index) {
                  final record = records[index];

                  return _NetworkRecordCard(
                    record: record,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            NetworkRequestDetailPage(record: record),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NetworkRecordCard extends StatelessWidget {
  const _NetworkRecordCard({required this.record, required this.onTap});

  final NetworkRequestRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final statusText = record.statusCode?.toString() ?? '...';
    final durationText = record.cacheSource != null
        ? 'cache'
        : (record.durationMs == null ? '-' : '${record.durationMs} ms');
    final host = Uri.tryParse(record.url)?.host ?? '';
    final statusColors = _statusColors(theme, record);
    final cacheSource = record.cacheSource;

    return Material(
      color: theme.colors.secondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Path penuh dulu — jangan diperebutkan badge.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      record.path,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.xs.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const Gap(10),
                  Text(
                    durationText,
                    style: theme.typography.xs.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              // Badge di baris sendiri, boleh wrap.
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Badge(
                    label: record.method,
                    textColor: theme.colors.primaryForeground,
                    backgroundColor: theme.colors.primary,
                  ),
                  _Badge(
                    label: statusText,
                    textColor: statusColors.$1,
                    backgroundColor: statusColors.$2,
                  ),
                  if (cacheSource != null)
                    _Badge(
                      label: cacheSource,
                      textColor: _cacheBadgeColors(theme, cacheSource).$1,
                      backgroundColor: _cacheBadgeColors(theme, cacheSource).$2,
                      tooltip: cacheSourcePlainExplanation(cacheSource),
                    ),
                ],
              ),
              if (host.isNotEmpty) ...[
                const Gap(8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                    Icon(
                      FLucideIcons.chevronRight,
                      size: 14,
                      color: theme.colors.mutedForeground,
                    ),
                  ],
                ),
              ],
              if (record.errorMessage != null) ...[
                const Gap(6),
                Text(
                  record.errorMessage!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xs.copyWith(
                    color: theme.colors.destructive,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// `(text, background)` untuk badge status.
  (Color, Color) _statusColors(FThemeData theme, NetworkRequestRecord record) {
    if (record.statusCode == null) {
      return (theme.colors.mutedForeground, theme.colors.muted);
    }
    if (record.isError || (record.statusCode ?? 0) >= 400) {
      return (
        theme.colors.destructive,
        theme.colors.destructive.withValues(alpha: 0.12),
      );
    }
    // ponytail: Forui tak punya success token; pakai primary tint.
    return (
      theme.colors.primary,
      theme.colors.primary.withValues(alpha: 0.12),
    );
  }
}

(Color, Color) _cacheBadgeColors(FThemeData theme, String source) {
  switch (source) {
    case 'HIT':
      return (
        const Color(0xFF0F766E),
        const Color(0xFF0D9488).withValues(alpha: 0.16),
      );
    case 'STALE':
      return (
        const Color(0xFFB45309),
        const Color(0xFFF59E0B).withValues(alpha: 0.18),
      );
    case 'DEGRADED':
      return (
        theme.colors.destructive,
        theme.colors.destructive.withValues(alpha: 0.12),
      );
    default:
      return (theme.colors.mutedForeground, theme.colors.muted);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.tooltip,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );

    final tip = tooltip;
    if (tip == null || tip.isEmpty) return badge;

    return Tooltip(
      message: tip,
      waitDuration: const Duration(milliseconds: 400),
      showDuration: const Duration(seconds: 6),
      triggerMode: TooltipTriggerMode.tap,
      child: badge,
    );
  }
}

class _EmptyNetworkMonitorState extends StatelessWidget {
  const _EmptyNetworkMonitorState();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Belum ada request yang direkam.',
          textAlign: TextAlign.center,
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
