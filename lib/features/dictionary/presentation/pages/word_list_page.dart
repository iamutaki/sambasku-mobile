import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../dictionary_router.dart';
import '../../domain/entities/word_summary.dart';
import '../models/word_list_state.dart';
import '../providers/word_list_providers.dart';

/// Daftar semua kata A-Z (GET /api/v1/words, 18-api-list-words.md).
/// Browsing dengan filter q server-side (bukan pencarian - tanpa
/// search-miss). Urutan dari server: lower(lemma) ASC (case-insensitive).
class WordListPage extends HookConsumerWidget {
  const WordListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wordListProvider);
    final notifier = ref.read(wordListProvider.notifier);
    final controller = useTextEditingController(text: state.q);
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

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Daftar Kata A-Z'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 2),
            child: FTextField(
              control: FTextFieldControl.managed(
                controller: controller,
                onChange: (value) => notifier.onQueryChanged(value.text),
              ),
              hint: 'Saring daftar kata...',
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
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              child: FAlert(
                variant: FAlertVariant.destructive,
                title: Text(state.errorMessage!),
              ),
            ),
          Expanded(child: _buildBody(context, ref, theme, state, scroll)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    WordListState state,
    ScrollController scroll,
  ) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    // Row compact ~52–56px; hitung skeleton agar penuh viewport.
    final skeletonPerPage = (viewportHeight ~/ 56) + 2;

    if (state.isLoading) {
      return _ListSkeleton(itemCount: skeletonPerPage);
    }

    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.list,
                size: 40,
                color: theme.colors.mutedForeground,
              ),
              const Gap(8),
              Text(
                state.q.trim().isEmpty
                    ? 'Belum ada kata terbit.'
                    : 'Tidak ada kata untuk "${state.q}"',
                textAlign: TextAlign.center,
                style: theme.typography.md.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
              if (state.q.trim().isNotEmpty) ...[
                const Gap(4),
                Text(
                  'Hapus saringan untuk melihat semua kata.',
                  textAlign: TextAlign.center,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
              const Gap(12),
              FButton(
                onPress: () => ref.invalidate(wordListProvider),
                variant: FButtonVariant.outline,
                prefix: const Icon(FLucideIcons.rotateCcw),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(wordListProvider);
      },
      // List normal urut server (lemma ASC, id ASC - urutan kamus
      // en_US.utf8: apostrof/kapital diabaikan level primer). TANPA
      // grouping header huruf: client tidak boleh mengurutkan ulang
      // (pagination keyset), grouping dari karakter pertama mentah
      // justru berosilasi ('#, A, #, B') untuk lemma ber-apostrof.
      child: ListView.separated(
        controller: scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 20),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 1),
        itemBuilder: (ctx, index) {
          if (index >= state.items.length) {
            return const _LoadingMoreFooter();
          }
          return _WordTile(item: state.items[index]);
        },
      ),
    );
  }
}

/// Tile padat satu baris — list bisa ribuan kata.
/// Padding FTile default (~14.5) diperkecil lewat style.delta.
class _WordTile extends StatelessWidget {
  const _WordTile({required this.item});

  final WordSummary item;

  static const _compactStyle = FItemStyleDelta.delta(
    contentStyle: FItemContentStyleDelta.delta(
      suffixedPadding: EdgeInsetsGeometryDelta.value(
        EdgeInsets.fromLTRB(12, 7, 10, 7),
      ),
      unsuffixedPadding: EdgeInsetsGeometryDelta.value(
        EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      ),
      prefixIconSpacing: 8,
      suffixIconSpacing: 4,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FTile(
      style: _compactStyle,
      title: Row(
        children: [
          Flexible(
            child: Text(
              item.lemma,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.sm.copyWith(
                color: theme.colors.foreground,
                height: 1.2,
              ),
            ),
          ),
          if (item.wordType != 'word') ...[
            const Gap(6),
            Text(
              item.wordTypeLabel,
              style: theme.typography.xs.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
      suffix: item.isVerified
          ? Icon(FLucideIcons.badgeCheck, size: 14, color: theme.colors.primary)
          : null,
      onPress: () {
        FocusManager.instance.primaryFocus?.unfocus();
        context.push(DictionaryRouter.detail.path.replaceFirst(':id', item.id));
      },
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton({required this.itemCount});

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
            // Tanpa horizontal: FScaffold(childPad) sudah memberi inset.
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 20),
            itemCount: itemCount,
            separatorBuilder: (_, _) => const SizedBox(height: 1),
            itemBuilder: (_, _) => FTile(
              style: _WordTile._compactStyle,
              title: const Text('kata Sambas contoh'),
            ),
          ),
        ),
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
