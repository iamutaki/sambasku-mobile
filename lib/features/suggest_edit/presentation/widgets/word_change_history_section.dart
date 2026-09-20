import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/utils/format_datetime.dart';

class ChangeHistoryFieldDiff {
  const ChangeHistoryFieldDiff({
    required this.entity,
    required this.field,
    required this.displayOld,
    required this.displayNew,
  });

  final String entity;
  final String field;
  final String displayOld;
  final String displayNew;
}

class ChangeHistoryItem {
  const ChangeHistoryItem({
    required this.id,
    required this.timestamp,
    required this.actorUsername,
    required this.type,
    required this.changes,
    this.reason,
    this.suggestedByUsername,
    this.reviewComment,
  });

  final String id;
  final String timestamp;
  final String? actorUsername;
  final String type;
  final List<ChangeHistoryFieldDiff> changes;
  final String? reason;
  final String? suggestedByUsername;
  final String? reviewComment;

  bool get isSuggestEdit => type == 'suggest_edit';
}

final changeHistoryProvider =
    FutureProvider.autoDispose.family<List<ChangeHistoryItem>, String>((
  ref,
  wordId,
) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get<Map<String, dynamic>>(
    '/api/v1/words/$wordId/change-history',
    // ponytail: full page tanpa pagination dulu; naikkan / cursor kalau
    // antrean history mulai panjang.
    queryParameters: {'limit': 50},
  );
  final data = res.data?['data'];
  if (data is! List) return const [];
  return data.whereType<Map>().map((raw) {
    final map = Map<String, dynamic>.from(raw);
    final actor = map['actor'];
    final source = map['source'];
    final changesRaw = map['changes'];
    final changes = <ChangeHistoryFieldDiff>[];
    if (changesRaw is List) {
      for (final c in changesRaw.whereType<Map>()) {
        final cm = Map<String, dynamic>.from(c);
        changes.add(
          ChangeHistoryFieldDiff(
            entity: cm['entity']?.toString() ?? '',
            field: cm['field']?.toString() ?? '',
            displayOld: cm['display_old']?.toString() ?? '',
            displayNew: cm['display_new']?.toString() ?? '',
          ),
        );
      }
    }
    return ChangeHistoryItem(
      id: map['id']?.toString() ?? '',
      timestamp: map['timestamp']?.toString() ?? '',
      actorUsername: actor is Map ? actor['username']?.toString() : null,
      type: map['type']?.toString() ?? 'direct_edit',
      changes: changes,
      reason: source is Map ? source['reason']?.toString() : null,
      suggestedByUsername: source is Map
          ? (source['suggested_by'] is Map
              ? (source['suggested_by'] as Map)['username']?.toString()
              : null)
          : null,
      reviewComment:
          source is Map ? source['review_comment']?.toString() : null,
    );
  }).toList(growable: false);
});

/// Daftar riwayat perubahan kata (halaman penuh via AppBar detail).
class WordChangeHistorySection extends ConsumerWidget {
  const WordChangeHistorySection({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(changeHistoryProvider(wordId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: FCircularProgress()),
      ),
      error: (e, _) {
        if (e is DioException && e.response?.statusCode == 404) {
          return _EmptyState(
            icon: FLucideIcons.searchX,
            title: 'Kata tidak ditemukan',
            subtitle: 'Riwayat tidak tersedia untuk entri ini.',
          );
        }
        return Column(
          children: [
            _EmptyState(
              icon: FLucideIcons.circleAlert,
              title: 'Gagal memuat riwayat',
              subtitle: 'Coba lagi sebentar.',
            ),
            const Gap(12),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => ref.invalidate(changeHistoryProvider(wordId)),
              child: const Text('Coba lagi'),
            ),
          ],
        );
      },
      data: (items) {
        if (items.isEmpty) {
          return const _EmptyState(
            icon: FLucideIcons.history,
            title: 'Belum ada riwayat',
            subtitle: 'Perubahan yang diterapkan ke kata ini akan muncul di sini.',
          );
        }
        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Gap(10),
              _HistoryEntryCard(item: items[i]),
            ],
          ],
        );
      },
    );
  }
}

class _HistoryEntryCard extends StatelessWidget {
  const _HistoryEntryCard({required this.item});

  final ChangeHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final when = item.timestamp.isNotEmpty
        ? formatDateTimeIso(item.timestamp)
        : null;
    final who = (item.actorUsername != null && item.actorUsername!.isNotEmpty)
        ? item.actorUsername!
        : 'Sistem';
    final kind = item.isSuggestEdit ? 'Dari usulan' : 'Edit langsung';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.isSuggestEdit
                      ? FLucideIcons.gitPullRequestArrow
                      : FLucideIcons.penLine,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    kind,
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (when != null)
                  Text(
                    when,
                    style: theme.typography.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
              ],
            ),
            const Gap(4),
            Text(
              who,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            if (item.suggestedByUsername != null &&
                item.suggestedByUsername!.isNotEmpty) ...[
              const Gap(2),
              Text(
                'Diusulkan oleh ${item.suggestedByUsername}',
                style: theme.typography.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
            if (item.reason != null && item.reason!.trim().isNotEmpty) ...[
              const Gap(8),
              Text(
                item.reason!.trim(),
                style: theme.typography.sm.copyWith(height: 1.35),
              ),
            ],
            if (item.changes.isNotEmpty) ...[
              const Gap(10),
              for (var i = 0; i < item.changes.length; i++) ...[
                if (i > 0) const Gap(8),
                _FieldDiffRow(diff: item.changes[i]),
              ],
            ],
            if (item.reviewComment != null &&
                item.reviewComment!.trim().isNotEmpty) ...[
              const Gap(8),
              Text(
                'Catatan reviewer: ${item.reviewComment!.trim()}',
                style: theme.typography.xs.copyWith(
                  color: theme.colors.mutedForeground,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldDiffRow extends StatelessWidget {
  const _FieldDiffRow({required this.diff});

  final ChangeHistoryFieldDiff diff;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final label = [
      if (diff.entity.isNotEmpty) diff.entity,
      if (diff.field.isNotEmpty) diff.field,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: theme.typography.xs.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colors.mutedForeground,
            ),
          ),
        if (label.isNotEmpty) const Gap(4),
        if (diff.displayOld.isNotEmpty)
          Text(
            diff.displayOld,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
              decoration: TextDecoration.lineThrough,
              height: 1.35,
            ),
          ),
        Text(
          diff.displayNew.isEmpty ? '(kosong)' : diff.displayNew,
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 36, color: theme.colors.mutedForeground),
          const Gap(12),
          Text(
            title,
            style: theme.typography.md.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const Gap(6),
          Text(
            subtitle,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
