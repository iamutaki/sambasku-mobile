import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../dictionary_router.dart';
import '../../domain/entities/word_of_day.dart';
import '../providers/word_of_day_providers.dart';

/// Kartu Kata Hari Ini. Soft-fail: loading = shimmer; null/error = hilang.
class WordOfDayCard extends ConsumerWidget {
  const WordOfDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wordOfDayProvider);

    return async.when(
      loading: () => const _WordOfDaySkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (item) {
        if (item == null) return const SizedBox.shrink();
        return _WordOfDayBody(item: item);
      },
    );
  }
}

class _WordOfDayBody extends StatelessWidget {
  const _WordOfDayBody({required this.item});

  final WordOfDay item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final sense = item.firstSense;
    final dateLabel = formatDateYmd(item.date);

    final accent = theme.colors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colors.secondary,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accent.withValues(alpha: 0.35)),
        ),
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context.push(
              DictionaryRouter.detail.path.replaceFirst(':id', item.word.id),
            );
          },
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColoredBox(color: accent, child: const SizedBox(width: 4)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  FLucideIcons.sun,
                                  size: 14,
                                  color: accent,
                                ),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                'Kata hari ini',
                                style: theme.typography.xs.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                            if (dateLabel.isNotEmpty)
                              Text(
                                dateLabel,
                                style: theme.typography.xs.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                          ],
                        ),
                        const Gap(6),
                        Text(
                          item.word.lemma,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.lg.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: theme.colors.foreground,
                          ),
                        ),
                        if (sense.isNotEmpty) ...[
                          const Gap(2),
                          Text(
                            sense,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                        const Gap(4),
                        Text(
                          item.isNewThisWeek
                              ? 'Ditampilkan hari ini · baru minggu ini'
                              : 'Ditampilkan hari ini, berganti setiap hari',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WordOfDaySkeleton extends StatelessWidget {
  const _WordOfDaySkeleton();

  @override
  Widget build(BuildContext context) {
    final materialBrightness = Theme.of(context).brightness;
    final isDark = materialBrightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    final shimmer = ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    final accent = context.theme.colors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SkeletonizerConfig(
        data: SkeletonizerConfigData(effect: shimmer),
        child: IgnorePointer(
          child: Skeletonizer(
            enabled: true,
            child: Material(
              color: context.theme.colors.secondary,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: accent.withValues(alpha: 0.35)),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(14, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kata hari ini'),
                    Gap(6),
                    Text('lemma contoh'),
                    Gap(2),
                    Text('arti pertama satu baris'),
                    Gap(4),
                    Text('Ditampilkan hari ini, berganti setiap hari'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
