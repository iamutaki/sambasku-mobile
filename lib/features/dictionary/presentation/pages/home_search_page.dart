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
        if (scroll.position.pixels >=
            scroll.position.maxScrollExtent - 200) {
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
        Expanded(
          child: _buildBody(theme, state, scroll),
        ),
      ],
    );
  }

  Widget _buildBody(
    FThemeData theme,
    DictionarySearchState state,
    ScrollController scroll,
  ) {
    if (state.isLoading) {
      return Skeletonizer(
        enabled: true,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: 6,
          separatorBuilder: (_, _) => const Gap(8),
          itemBuilder: (_, _) => FTile(
            title: const Text('memuat hasil pencarian'),
            subtitle: const Text('bahasa'),
          ),
        ),
      );
    }

    if (!state.hasSearched) {
      return Center(
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
                'Istilah ini tercatat sebagai peluang kontribusi\n'
                '(fitur usul kata menyusul)',
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

    return ListView.separated(
      controller: scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const Gap(8),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: FCircularProgress()),
          );
        }
        return _WordResultTile(item: state.items[index]);
      },
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
          ? Icon(
              FLucideIcons.badgeCheck,
              size: 18,
              color: theme.colors.primary,
            )
          : null,
      onPress: () {
        context.push(
          DictionaryRouter.detail.path.replaceFirst(':id', item.id),
        );
      },
    );
  }
}
