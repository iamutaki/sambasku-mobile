import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/utils/format_datetime.dart';

class ChangeHistoryItem {
  const ChangeHistoryItem({
    required this.id,
    required this.timestamp,
    required this.actorUsername,
    required this.type,
    required this.summary,
  });

  final String id;
  final String timestamp;
  final String? actorUsername;
  final String type;
  final String summary;
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
    final changes = map['changes'];
    var summary = map['type']?.toString() ?? 'edit';
    if (changes is List && changes.isNotEmpty) {
      final first = changes.first;
      if (first is Map) {
        final field = first['field']?.toString() ?? '';
        final displayNew = first['display_new']?.toString() ?? '';
        summary = field.isEmpty ? summary : '$field → $displayNew';
      }
    }
    return ChangeHistoryItem(
      id: map['id']?.toString() ?? '',
      timestamp: map['timestamp']?.toString() ?? '',
      actorUsername: actor is Map ? actor['username']?.toString() : null,
      type: map['type']?.toString() ?? 'direct_edit',
      summary: summary,
    );
  }).toList(growable: false);
});

/// Daftar riwayat perubahan kata (dipakai halaman penuh).
class WordChangeHistorySection extends ConsumerWidget {
  const WordChangeHistorySection({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(changeHistoryProvider(wordId));
    final theme = context.theme;

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: FCircularProgress()),
      ),
      error: (e, _) {
        if (e is DioException && e.response?.statusCode == 404) {
          return const SizedBox.shrink();
        }
        return Text(
          'Riwayat belum tersedia',
          style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
        );
      },
      data: (items) {
        if (items.isEmpty) {
          return Text(
            'Belum ada riwayat perubahan.',
            style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
          );
        }
        return Column(
          children: [
            for (final item in items) ...[
              FTile(
                title: Text(item.summary),
                subtitle: Text(
                  [
                    if (item.actorUsername != null && item.actorUsername!.isNotEmpty)
                      item.actorUsername!,
                    item.type == 'suggest_edit' ? 'dari usulan' : 'edit langsung',
                    if (item.timestamp.isNotEmpty)
                      formatDateTimeIso(item.timestamp),
                  ].join(' · '),
                ),
              ),
              const Gap(4),
            ],
          ],
        );
      },
    );
  }
}
