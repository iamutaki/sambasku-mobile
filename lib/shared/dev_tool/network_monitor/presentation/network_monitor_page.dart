import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../dev_tool_inspector.dart';
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
    final durationText = record.durationMs == null
        ? '-'
        : '${record.durationMs} ms';
    final host = Uri.tryParse(record.url)?.host ?? '';
    final statusColors = _statusColors(theme, record);

    return Material(
      color: theme.colors.secondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Badge(
                    label: record.method,
                    textColor: theme.colors.primaryForeground,
                    backgroundColor: theme.colors.primary,
                  ),
                  const Gap(6),
                  _Badge(
                    label: statusText,
                    textColor: statusColors.$1,
                    backgroundColor: statusColors.$2,
                  ),
                  const Gap(6),
                  Expanded(
                    child: Text(
                      record.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.foreground,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    durationText,
                    style: theme.typography.xs.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
              const Gap(6),
              Row(
                children: [
                  if (host.isNotEmpty) ...[
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
                  ] else
                    const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: theme.colors.mutedForeground,
                  ),
                ],
              ),
              if (record.errorMessage != null) ...[
                const Gap(6),
                Text(
                  record.errorMessage!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xs.copyWith(
                    color: theme.colors.destructive,
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

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
