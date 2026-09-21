import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../../core/widgets/verified_badge_icon.dart';
import '../../../search_miss/domain/entities/search_miss.dart';
import '../../../search_miss/presentation/providers/search_miss_list_providers.dart';
import '../../../search_miss/presentation/widgets/search_miss_skeleton_list.dart';
import '../../dictionary_router.dart';
import '../../domain/entities/word_summary.dart';
import '../models/dictionary_search_state.dart';
import '../providers/dictionary_search_providers.dart';
import '../providers/word_of_day_providers.dart';
import '../widgets/word_of_day_card.dart';

/// Tab HOME: pencarian kosakata publik (GET /api/v1/words/search).
/// Idle: daftar search-miss sebagai konten utama (bukan chip kecil).
/// search_in=lemma → Sambas→Indonesia; translation → Indonesia→Sambas
/// (matched_translation → lemma).
class HomeSearchPage extends HookConsumerWidget {
  const HomeSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dictionarySearchProvider);
    final notifier = ref.read(dictionarySearchProvider.notifier);
    final controller = useTextEditingController(text: state.query);
    final scroll = useScrollController();

    useEffect(() {
      void listener() {
        if (scroll.position.pixels >= scroll.position.maxScrollExtent - 200) {
          notifier.loadMore();
        }
      }

      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll]);

    final theme = context.theme;
    final isLemma = state.searchIn == 'lemma';
    // Prefetch + keep-alive selama tab Home hidup (kartu unmount saat mengetik).
    ref.watch(wordOfDayProvider);

    return Column(
      children: [
        const FHeader(
          title: Text('Kamus Sambas'),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
          child: FTextField(
            control: FTextFieldControl.managed(
              controller: controller,
              onChange: (value) => notifier.onQueryChanged(value.text),
            ),
            hint: isLemma ? 'Cari kata Sambas...' : 'Cari kata Indonesia...',
            clearable: (value) => value.text.isNotEmpty,
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const Icon(FLucideIcons.search),
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: FButton(
                  variant: isLemma
                      ? FButtonVariant.primary
                      : FButtonVariant.outline,
                  onPress: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    notifier.onSearchInChanged('lemma');
                  },
                  child: const Text('Sambas'),
                ),
              ),
              const Gap(6),
              Expanded(
                child: FButton(
                  variant: !isLemma
                      ? FButtonVariant.primary
                      : FButtonVariant.outline,
                  onPress: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    notifier.onSearchInChanged('translation');
                  },
                  child: const Text('Indonesia'),
                ),
              ),
            ],
          ),
        ),
        // Entry Daftar Kosakata A-Z — tile penuh + subtitle (07-mobile-list-words).
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: FTileGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.listOrdered),
                title: const Text('Daftar Kosakata A–Z'),
                subtitle: const Text('Telusuri semua kata dari A sampai Z'),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  context.push(DictionaryRouter.list.path);
                },
              ),
            ],
          ),
        ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: FAlert(
              variant: FAlertVariant.destructive,
              title: Text(state.errorMessage!),
            ),
          ),
        Expanded(child: _buildBody(context, ref, theme, state, scroll)),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    DictionarySearchState state,
    ScrollController scroll,
  ) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final skeletonPerPage = (viewportHeight ~/ 80) + 2;

    if (state.isLoading) {
      return _WordSkeletonList(itemCount: skeletonPerPage);
    }

    // Idle: miss list = isi beranda (satu komposisi). Hilang saat user mencari.
    if (!state.hasSearched) {
      return _HomeIdleMisses(
        misses: ref.watch(searchMissListProvider(_HomeIdleMisses._limit)),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.searchX,
                size: 40,
                color: theme.colors.mutedForeground,
              ),
              const Gap(8),
              Text(
                'Tidak ada hasil untuk "${state.query}"',
                textAlign: TextAlign.center,
                style: theme.typography.md.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
              const Gap(4),
              Text(
                'Usulkan kata ini untuk membantu warga lain.',
                textAlign: TextAlign.center,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(12),
              FButton(
                onPress: () {
                  final q = Uri(
                    queryParameters: <String, String>{
                      if (state.query.isNotEmpty) 'lemma': state.query,
                      'search_in': state.searchIn,
                    },
                  ).query;
                  context.push('/contribute${q.isNotEmpty ? '?$q' : ''}');
                },
                variant: FButtonVariant.primary,
                prefix: const Icon(FLucideIcons.plusCircle),
                child: const Text('Usul Kata Ini'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      controller: scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        FTileGroup(
          children: [
            for (final item in state.items) _wordResultTile(context, item),
          ],
        ),
        if (state.isLoadingMore) const _LoadingMoreFooter(),
      ],
    );
  }
}

class _WordSkeletonList extends StatelessWidget {
  const _WordSkeletonList({required this.itemCount});

  final int itemCount;

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

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shimmer),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            children: [
              FTileGroup(
                children: [
                  for (var i = 0; i < itemCount; i++) const _SkeletonTile(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget with FTileMixin {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return FTile(
      title: const Text('kata Sambas panjang contoh'),
      subtitle: const Text('Nomina · SBS'),
      suffix: Icon(
        FLucideIcons.badgeCheck,
        size: 18,
        color: context.theme.colors.mutedForeground,
      ),
    );
  }
}

class _LoadingMoreFooter extends StatelessWidget {
  const _LoadingMoreFooter();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12, width: 12, child: FCircularProgress()),
            const Gap(8),
            Text(
              'Memuat...',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

FTile _wordResultTile(BuildContext context, WordSummary item) {
  final matched = item.matchedTranslation;
  final title = matched != null ? '$matched → ${item.lemma}' : item.lemma;

  return FTile(
    title: Text(title),
    subtitle: Text('${item.wordTypeLabel} · ${item.languageCode}'),
    suffix: item.isVerified ? const VerifiedBadgeIcon() : null,
    onPress: () {
      FocusManager.instance.primaryFocus?.unfocus();
      context.push(DictionaryRouter.detail.path.replaceFirst(':id', item.id));
    },
  );
}

/// Idle beranda: daftar miss sebagai konten utama (bukan chip + empty-state).
class _HomeIdleMisses extends ConsumerWidget {
  const _HomeIdleMisses({required this.misses});

  final AsyncValue<List<SearchMiss>> misses;

  static const _limit = 8;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(searchMissListProvider(_limit));
    ref.invalidate(wordOfDayProvider);
    await Future.wait([
      ref.read(searchMissListProvider(_limit).future),
      ref.read(wordOfDayProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: WordOfDayCard(),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: misses.when(
              loading: () => SearchMissSkeletonList(
                itemCount: _limit,
                header: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sedang dicari warga',
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'Belum ada di kamus - ketuk untuk mengusulkan arti.',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              error: (_, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.45,
                    child: _IdleSearchHint(theme: theme),
                  ),
                ],
              ),
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.45,
                        child: _IdleSearchHint(theme: theme),
                      ),
                    ],
                  );
                }

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  children: [
                    Text(
                      'Sedang dicari warga',
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'Belum ada di kamus - ketuk untuk mengusulkan arti.',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const Gap(10),
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
                              FocusManager.instance.primaryFocus?.unfocus();
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
                    const Gap(12),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.go('/action');
                      },
                      child: const Text('Lihat semua di Kontribusi'),
                    ),
                  ],
                );
              },
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

class _IdleSearchHint extends StatelessWidget {
  const _IdleSearchHint({required this.theme});

  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.search,
              size: 36,
              color: theme.colors.mutedForeground,
            ),
            const Gap(6),
            Text(
              'Ketik untuk mencari',
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
