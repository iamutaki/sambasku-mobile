import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/entities/word_summary.dart';
import '../models/dictionary_search_state.dart';
import '../providers/dictionary_search_providers.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../dictionary_router.dart';
import '../../../search_miss/domain/entities/search_miss.dart';
import '../../../search_miss/domain/usecases/list_search_misses_use_case.dart';
import '../../../search_miss/domain/providers/search_miss_domain_providers.dart';

/// Tab HOME: pencarian kosakata publik (GET /api/v1/words/search).
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

    return Column(
      children: [
        const FHeader(
          title: Text('Kamus Sambas'),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: FTextField(
            control: FTextFieldControl.managed(
              controller: controller,
              onChange: (value) => notifier.onQueryChanged(value.text),
            ),
            hint: isLemma
                ? 'Cari kata Sambas...'
                : 'Cari kata Indonesia (terjemahan)...',
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: FButton(
                  variant: isLemma
                      ? FButtonVariant.primary
                      : FButtonVariant.outline,
                  onPress: () => notifier.onSearchInChanged('lemma'),
                  prefix: const Icon(FLucideIcons.languages),
                  child: const Text('Sambas'),
                ),
              ),
              const Gap(8),
              Expanded(
                child: FButton(
                  variant: !isLemma
                      ? FButtonVariant.primary
                      : FButtonVariant.outline,
                  onPress: () => notifier.onSearchInChanged('translation'),
                  prefix: const Icon(FLucideIcons.arrowLeftRight),
                  child: const Text('Indonesia'),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
    final missesAsync = ref.watch(_homeSearchMissesProvider);

    if (state.isLoading) {
      return _WordSkeletonList(itemCount: skeletonPerPage);
    }

    if (!state.hasSearched) {
      return Column(
        children: [
          if (missesAsync is! AsyncLoading)
            _SearchMissBanner(
              misses: missesAsync,
              onDismiss: () => ref.invalidate(_homeSearchMissesProvider),
            ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FLucideIcons.search,
                    size: 56,
                    color: theme.colors.mutedForeground,
                  ),
                  const Gap(8),
                  Text(
                    'Mulai ketik untuk mencari kosakata',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                size: 56,
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
                'Ayo kontribusikan usul kata ini, bantu warga Sambas lain.',
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

    final items = <Widget>[
      if (missesAsync is! AsyncLoading)
        _SearchMissBanner(
          misses: missesAsync,
          onDismiss: () => ref.invalidate(_homeSearchMissesProvider),
        ),
      Expanded(
        child: ListView.separated(
          controller: scroll,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const Gap(8),
          itemBuilder: (ctx, index) {
            if (index >= state.items.length) {
              return const _LoadingMoreFooter();
            }
            return _WordResultTile(item: state.items[index]);
          },
        ),
      ),
    ];

    return Column(children: items);
  }
}

/// Skeleton list hasil pencarian. Dibungkus IgnorePointer supaya tidak
/// bisa di-scroll / di-tap saat loading (UX professional: skeleton
/// hanya visual, tidak interactive).
///
/// Setiap tile 1:1 mirror struktur [_WordResultTile]. Ini penting supaya
/// `skeletonizer` men-generate shimmer overlay yang bentuknya PERSIS
/// seperti hasil asli (tidak ada "keanehan bentuk").
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
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: itemCount,
            separatorBuilder: (_, _) => const Gap(8),
            itemBuilder: (_, _) => const _SkeletonTile(),
          ),
        ),
      ),
    );
  }
}

/// Satu baris skeleton, bentuk & hierarki 1:1 sama dengan [_WordResultTile]:
/// - `title`: panjang agak acak (3 kata via `Bone.text`)
/// - `subtitle`: 2 segmen dipisah titik tengah (wordType · languageCode)
/// - `suffix`: placeholder badgeCheck (icon verified muncul di tile asli)
///
/// `Bone` disediakan oleh package skeletonizer, Text biasa di dalam
/// Skeletonizer yang enabled=true memang akan di-paint-over, tapi
/// memakai widget Text dengan panjang yang mirip hasil asli membuat
/// shimmer overlay presisi.
class _SkeletonTile extends StatelessWidget {
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

/// Footer loadMore: skeleton tile 2 baris (kesan item sudah datang tapi
/// belum kontennya) + spinner mini di bawah sebagai indikator loading
/// aktif. Hanya tampil waktu `isLoadingMore=true` (saat infinite scroll
/// request halaman berikutnya).
class _LoadingMoreFooter extends StatelessWidget {
  const _LoadingMoreFooter();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final materialBrightness = Theme.of(context).brightness;
    final isDark = materialBrightness == Brightness.dark;
    final muted = theme.colors.muted;
    final shimmer = ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    return Column(
      children: [
        SkeletonizerConfig(
          data: SkeletonizerConfigData(effect: shimmer),
          child: IgnorePointer(
            child: Skeletonizer(
              enabled: true,
              child: Column(
                children: const [_SkeletonTile(), Gap(8), _SkeletonTile()],
              ),
            ),
          ),
        ),
        const Gap(12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12, width: 12, child: FCircularProgress()),
              const Gap(8),
              Text(
                'Memuat lebih banyak...',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
      ],
    );
  }
}

/// Satu baris hasil: lemma + relasi terjemahan (jika ada) + tipe/bahasa.
class _WordResultTile extends StatelessWidget {
  const _WordResultTile({required this.item});

  final WordSummary item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final matched = item.matchedTranslation;

    // reverse search: tampilkan relasi "makan → makatn"
    final title = matched != null ? '$matched → ${item.lemma}' : item.lemma;

    return FTile(
      title: Text(title),
      subtitle: Text('${item.wordTypeLabel} · ${item.languageCode}'),
      suffix: item.isVerified
          ? Icon(FLucideIcons.badgeCheck, size: 18, color: theme.colors.primary)
          : null,
      onPress: () {
        context.push(DictionaryRouter.detail.path.replaceFirst(':id', item.id));
      },
    );
  }
}

// =============================================================================
// Banner "Sedang Dicari" = horizontal list kata yang paling banyak dicari
// tapi tidak ketemu. Setiap kartu punya CTA "Kontribusikan" → navigate ke
// halaman /contribute dengan prefill lemma dan search_in.
// =============================================================================

final _homeSearchMissesProvider = FutureProvider<List<SearchMiss>>((ref) async {
  final usecase = ref.watch(listSearchMissesUseCaseProvider);
  final result = await usecase(const ListSearchMissesParams(limit: 10));
  return result.match((l) => <SearchMiss>[], (r) => r);
});

class _SearchMissBanner extends StatelessWidget {
  const _SearchMissBanner({required this.misses, required this.onDismiss});

  final AsyncValue<List<SearchMiss>> misses;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return misses.maybeWhen(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return _BannerList(items: items);
      },
      error: (_, _) => const SizedBox.shrink(),
      orElse: () => const SizedBox(
        height: 130,
        child: Center(child: FCircularProgress()),
      ),
    );
  }
}

class _BannerList extends StatelessWidget {
  const _BannerList({required this.items});
  final List<SearchMiss> items;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FLucideIcons.sparkles,
                size: 16,
                color: theme.colors.primary,
              ),
              const Gap(6),
              Text(
                'Sedang Dicari Warga Lain',
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colors.foreground,
                ),
              ),
              const Spacer(),
              Icon(
                FLucideIcons.info,
                size: 16,
                color: theme.colors.mutedForeground,
              ),
            ],
          ),
          const Gap(8),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, _) => const Gap(8),
              itemBuilder: (ctx, i) => _BannerCard(item: items[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.item});
  final SearchMiss item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final label = item.searchIn == 'translation'
        ? '🇮🇩 → Sambas'
        : '🇸🇧 → Indonesia';
    final hitLabel = item.hitCount > 99
        ? '99× dicari'
        : '${item.hitCount}× dicari';
    return SizedBox(
      width: 240,
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FBadge(child: Text(hitLabel)),
                  const Spacer(),
                  FBadge(variant: FBadgeVariant.secondary, child: Text(label)),
                ],
              ),
              const Gap(6),
              Text(
                item.term,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colors.foreground,
                ),
              ),
              const Spacer(),
              FButton(
                onPress: () {
                  final q = Uri(
                    queryParameters: <String, String>{
                      'lemma': item.term,
                      'search_in': item.searchIn,
                    },
                  ).query;
                  context.push('/contribute?$q');
                },
                prefix: const Icon(FLucideIcons.plus, size: 16),
                child: const Text('Ayo Kontribusi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
