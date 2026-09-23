import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../search_miss/domain/entities/search_miss.dart';
import '../../../search_miss/presentation/providers/search_miss_list_providers.dart';
import '../../../search_miss/presentation/widgets/search_miss_skeleton_list.dart';

/// Tab KONTRIBUSI: CTA usul kosong + daftar search-miss untuk dipilih.
class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  static const _limit = 30;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(searchMissListProvider(_limit));
    await ref.read(searchMissListProvider(_limit).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final missesAsync = ref.watch(searchMissListProvider(_limit));

    return Column(
      children: [
        const FHeader(
          title: Text('Kontribusi'),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: missesAsync.when(
              loading: () => SearchMissSkeletonList(
                itemCount: 8,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                header: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BlankContributeTile(theme: theme),
                    const Gap(14),
                    Text(
                      'Kata yang sering dicari tapi belum ada',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'Sedang dicari warga - pilih satu untuk mengisi form usulan.',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              error: (_, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _BlankContributeTile(theme: theme),
                  const Gap(14),
                  FAlert(
                    variant: FAlertVariant.destructive,
                    title: const Text('Gagal memuat daftar pencarian'),
                    icon: const Icon(FLucideIcons.circleAlert),
                  ),
                ],
              ),
              data: (items) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _BlankContributeTile(theme: theme),
                  const Gap(14),
                  // Header "sedang dicari" hanya saat ada item - empty state
                  // jangan klaim warga sedang mencari (copy bentrok).
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Belum ada antrian dari pencarian warga. Usul kata baru lewat tombol di atas, atau coba lagi nanti.',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      'Kata yang sering dicari tapi belum ada',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'Sedang dicari warga - pilih satu untuk mengisi form usulan.',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const Gap(8),
                    FTileGroup(
                      children: [
                        for (final item in items)
                          FTile(
                            title: Text(item.term),
                            subtitle: Text(_missSubtitle(item)),
                            suffix: Icon(
                              FLucideIcons.chevronRight,
                              color: theme.colors.mutedForeground,
                            ),
                            onPress: () {
                              AnalyticsService.instance.log(
                                AnalyticsEvents.searchMissTap,
                                params: {'miss_id': item.id},
                              );
                              AnalyticsService.instance.log(
                                AnalyticsEvents.contributeStart,
                                params: {
                                  'guest': 1,
                                  'from': 'search_miss',
                                },
                              );
                              final q = Uri(
                                queryParameters: <String, String>{
                                  'lemma': item.term,
                                  'search_in': item.searchIn,
                                  'miss_id': item.id,
                                },
                              ).query;
                              context.push('/contribute?$q');
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _missSubtitle(SearchMiss item) {
    final direction = item.searchIn == 'translation'
        ? 'Indonesia → Sambas'
        : 'Sambas → Indonesia';
    final hits = item.hitCount > 99 ? '99×' : '${item.hitCount}×';
    return '$direction · $hits dicari';
  }
}

class _BlankContributeTile extends StatelessWidget {
  const _BlankContributeTile({required this.theme});

  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
      children: [
        FTile(
          prefix: Icon(FLucideIcons.plusCircle, color: theme.colors.primary),
          title: const Text('Usul kata baru'),
          subtitle: const Text('Isi form kosong dari awal'),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () {
            AnalyticsService.instance.log(
              AnalyticsEvents.contributeStart,
              params: {'from': 'blank'},
            );
            context.push('/contribute');
          },
        ),
      ],
    );
  }
}
