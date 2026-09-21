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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context.push(
              DictionaryRouter.detail.path.replaceFirst(':id', item.word.id),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Kata Hari Ini',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    if (dateLabel.isNotEmpty) ...[
                      const Gap(8),
                      Expanded(
                        child: Text(
                          dateLabel,
                          textAlign: TextAlign.end,
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Gap(6),
                Text(
                  item.word.lemma,
                  style: theme.typography.xl.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colors.foreground,
                  ),
                ),
                if (sense.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    sense,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
                if (item.isNewThisWeek) ...[
                  const Gap(8),
                  FBadge(
                    variant: FBadgeVariant.secondary,
                    child: const Text('Kata baru minggu ini'),
                  ),
                ],
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SkeletonizerConfig(
        data: SkeletonizerConfigData(effect: shimmer),
        child: IgnorePointer(
          child: Skeletonizer(
            enabled: true,
            child: Material(
              color: context.theme.colors.secondary,
              borderRadius: BorderRadius.circular(14),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kata Hari Ini  21 Sep 2026'),
                    Gap(6),
                    Text('lemma contoh panjang'),
                    Gap(4),
                    Text('arti pertama satu baris skeleton'),
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
