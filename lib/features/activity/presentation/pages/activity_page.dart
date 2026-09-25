import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../search_miss/search_miss_router.dart';
import '../../../translation_help/translation_help_router.dart';
import '../../../vote/presentation/providers/vote_deck_providers.dart';
import '../../../vote/presentation/widgets/vote_deck_section.dart';

/// Tab KONTRIBUSI: menu usul + deck nilai kata.
class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(voteDeckControllerProvider.notifier).refresh(),
      ref.refresh(voteDeckGuestSamplesProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    return Column(
      children: [
        const FHeader(
          title: Text('Kontribusi'),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            // CustomScrollView + SliverFillRemaining(hasScrollBody: false)
            // supaya deck swipe-atas tidak bentrok dengan ListView parent.
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ContributeMenus(theme: theme),
                        const Gap(20),
                      ],
                    ),
                  ),
                ),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 32),
                    child: VoteDeckSection(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContributeMenus extends StatelessWidget {
  const _ContributeMenus({required this.theme});

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
        FTile(
          prefix: Icon(FLucideIcons.search, color: theme.colors.primary),
          title: const Text('Kata yang sering dicari'),
          subtitle: const Text('Pilih kata yang warga cari tapi belum ada'),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => context.push(SearchMissRouter.list.path),
        ),
        FTile(
          prefix: Icon(FLucideIcons.languages, color: theme.colors.primary),
          title: const Text('Bantuan Terjemahan'),
          subtitle: const Text('Minta bantuan teks atau foto'),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => context.push(TranslationHelpRouter.feed.path),
        ),
      ],
    );
  }
}
