import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../bookmark/presentation/providers/bookmark_providers.dart';
import '../../../bookmark/presentation/widgets/bookmark_button.dart';
import '../../../comment/presentation/widgets/word_comments_section.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../vote/domain/entities/vote_target.dart';
import '../../../vote/domain/failures/vote_failure.dart';
import '../../../vote/presentation/providers/vote_providers.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/entities/word_detail.dart';
import '../../domain/failures/dictionary_failure.dart';
import '../providers/word_detail_providers.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../user_profile/user_profile_router.dart';

/// Halaman detail kata publik - GET /api/v1/words/:id.
class WordDetailPage extends ConsumerWidget {
  const WordDetailPage({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wordDetailProvider(wordId));
    final theme = context.theme;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(
          async.maybeWhen(data: (d) => d.lemma, orElse: () => 'Detail kata'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.history),
            semanticsLabel: 'Riwayat perubahan',
            onPress: () => context.push('/words/$wordId/history'),
          ),
          _WordBookmarkHeaderAction(wordId: wordId),
        ],
      ),
      child: async.when(
        loading: () => const _DetailSkeleton(),
        error: (error, _) {
          final failure = error is DictionaryFailure
              ? error
              : DictionaryFailure(error.toString());
          final isNotFound = failure.errorCode == 'WORD_NOT_FOUND';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isNotFound
                        ? FLucideIcons.searchX
                        : FLucideIcons.circleAlert,
                    size: 40,
                    color: theme.colors.mutedForeground,
                  ),
                  const Gap(10),
                  Text(
                    isNotFound ? 'Kata tidak ditemukan' : 'Gagal memuat detail',
                    style: theme.typography.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(6),
                  Text(
                    failure.message,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(16),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => ref.invalidate(wordDetailProvider(wordId)),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (detail) => _DetailBody(detail: detail, wordId: wordId),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail, required this.wordId});

  final WordDetail detail;
  final String wordId;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final primaryImage =
        detail.images.where((i) => i.isPrimary).firstOrNull ??
        detail.images.firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        // Header compact: thumb + meta
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (primaryImage != null) ...[
              Semantics(
                button: true,
                label: 'Pratinjau gambar',
                child: GestureDetector(
                  onTap: () => showImagePreview(
                    context,
                    urls: detail.images
                        .map((i) => i.url)
                        .toList(growable: false),
                    initialIndex: detail.images.indexOf(primaryImage),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      primaryImage.url,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
              const Gap(12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          detail.lemma,
                          style: theme.typography.xl.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                      ),
                      if (detail.isVerified)
                        Semantics(
                          button: true,
                          label: 'Lihat verifikator',
                          child: GestureDetector(
                            onTap: () =>
                                showVerifierAttributionSheet(context, detail),
                            child: Icon(
                              FLucideIcons.badgeCheck,
                              size: 18,
                              color: theme.colors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Gap(2),
                  Text(
                    detail.wordTypeLabel,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  if (detail.verifiedBy != null) ...[
                    const Gap(6),
                    Semantics(
                      button: true,
                      label: 'Diverifikasi ${detail.verifiedBy!.username}',
                      child: GestureDetector(
                        onTap: () =>
                            showVerifierAttributionSheet(context, detail),
                        child: Text(
                          'Diverifikasi ${detail.verifiedBy!.username}',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (detail.pronunciations.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      detail.pronunciations
                          .map((p) => '${p.notation} ${p.value}')
                          .join(' · '),
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        if (detail.notes != null && detail.notes!.isNotEmpty) ...[
          const Gap(8),
          Text(
            detail.notes!,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],

        if (detail.categories.isNotEmpty) ...[
          const Gap(8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: detail.categories
                .map(
                  (c) => FBadge(
                    variant: FBadgeVariant.secondary,
                    child: Text(c.name),
                  ),
                )
                .toList(),
          ),
        ],

        const Gap(10),
        _WordVoteBar(wordId: wordId),

        const Gap(10),
        _SuggestEditCta(wordId: wordId),

        if (detail.meanings.isNotEmpty) ...[
          const Gap(16),
          const _SectionLabel('Makna'),
          const Gap(6),
          ...detail.meanings.asMap().entries.map(
            (e) => _MeaningBlock(index: e.key + 1, meaning: e.value),
          ),
        ],

        if (detail.variants.isNotEmpty) ...[
          const Gap(14),
          _SectionLabel(
            detail.variants.every((v) => v.isSpellingVariant)
                ? 'Variasi penulisan'
                : 'Variasi & bentuk turunan',
          ),
          const Gap(6),
          ...detail.variants.map((v) => _VariantRow(variant: v)),
        ],

        ..._relatedSections(detail.relatedWords),

        if (detail.appearsIn.isNotEmpty) ...[
          const Gap(14),
          const _SectionLabel('Muncul dalam'),
          const Gap(4),
          ...detail.appearsIn.map((r) => _RelatedRow(related: r)),
        ],

        const Gap(16),
        WordCommentsSection(wordId: wordId),
      ],
    );
  }

  /// Kelompokkan relasi per tipe (Sinonim, Antonim, …) supaya jelas di UI.
  static List<Widget> _relatedSections(List<RelatedWord> related) {
    if (related.isEmpty) return const [];

    const order = [
      'synonym',
      'antonym',
      'derived_from',
      'has_component',
      'see_also',
    ];
    final grouped = <String, List<RelatedWord>>{};
    for (final r in related) {
      grouped.putIfAbsent(r.relationType, () => []).add(r);
    }

    final keys = [
      ...order.where(grouped.containsKey),
      ...grouped.keys.where((k) => !order.contains(k)),
    ];

    return [
      for (final key in keys) ...[
        const Gap(14),
        _SectionLabel(grouped[key]!.first.relationLabel),
        const Gap(4),
        ...grouped[key]!.map((r) => _RelatedRow(related: r)),
      ],
    ];
  }
}

class _WordVoteBar extends ConsumerWidget {
  const _WordVoteBar({required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final target = VoteTarget(type: 'word', id: wordId);
    final async = ref.watch(voteControllerProvider(target));

    ref.listen(voteControllerProvider(target), (prev, next) {
      if (next.hasError && !(prev?.hasError ?? false)) {
        final err = next.error;
        showFToast(
          context: context,
          title: Text(err is VoteFailure ? err.message : 'Gagal memuat vote'),
          variant: FToastVariant.destructive,
        );
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 50) return const SizedBox.shrink();

        return async.when(
          loading: () => Skeletonizer(
            enabled: true,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Membantu?',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const Gap(8),
                  const VoteButtonsSkeleton(compact: true),
                ],
              ),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (view) => Row(
            children: [
              Text(
                'Membantu?',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(8),
              VoteButtons(
                upvotes: view.upvotes,
                downvotes: view.downvotes,
                myVote: view.myVote,
                compact: true,
                onVote: (value) => _vote(context, ref, target, value),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _vote(
    BuildContext context,
    WidgetRef ref,
    VoteTarget target,
    int value,
  ) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk memberi vote'),
        variant: FToastVariant.primary,
      );
      context.push('/login');
      return;
    }
    final failure = await ref
        .read(voteControllerProvider(target).notifier)
        .toggle(value);
    if (failure != null && context.mounted) {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
    }
  }
}

/// Tombol bookmark di header detail kata (16-api-bookmark.md). Widget
/// tombolnya murni tampilan - guard login + toast failure ada di sini
/// (pola _vote pada _WordVoteBar).
class _WordBookmarkHeaderAction extends ConsumerWidget {
  const _WordBookmarkHeaderAction({required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookmarkToggleControllerProvider(wordId));

    // Error seed → tetap tampilkan tombol (unbookmarked) supaya user bisa
    // coba toggle; jangan SizedBox.shrink (hilang tanpa pesan).
    return async.when(
      loading: () =>
          const BookmarkButton(isBookmarked: false, busy: true, onPress: _noop),
      error: (_, _) => BookmarkButton(
        isBookmarked: false,
        onPress: () => _toggle(context, ref),
      ),
      data: (status) => BookmarkButton(
        isBookmarked: status.isBookmarked,
        onPress: () => _toggle(context, ref),
      ),
    );
  }

  static Future<void> _noop() async {}

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk menyimpan kata'),
        variant: FToastVariant.primary,
      );
      context.push('/login');
      return;
    }
    final failure = await ref
        .read(bookmarkToggleControllerProvider(wordId).notifier)
        .toggle();
    if (failure != null && context.mounted) {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
    }
  }
}

/// CTA usul edit entri (sinonim, definisi, dll.) via moderasi admin.
class _SuggestEditCta extends ConsumerWidget {
  const _SuggestEditCta({required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FTile(
      prefix: const Icon(FLucideIcons.penLine),
      title: const Text('Usulkan perubahan'),
      subtitle: const Text('Lemma, definisi, catatan - masuk antrean review'),
      suffix: Icon(
        FLucideIcons.chevronRight,
        size: 16,
        color: context.theme.colors.mutedForeground,
      ),
      onPress: () async {
        final auth = await ref.read(authStatusProvider.future);
        if (!context.mounted) return;
        if (!auth.isAuth) {
          showFToast(
            context: context,
            title: const Text('Masuk dulu untuk mengusulkan perubahan'),
          );
          context.push('/login');
          return;
        }
        context.push('/suggest-edit/$wordId');
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      text.toUpperCase(),
      style: theme.typography.sm.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.06,
        color: theme.colors.mutedForeground,
        fontSize: 11,
      ),
    );
  }
}

class _MeaningBlock extends StatelessWidget {
  const _MeaningBlock({required this.index, required this.meaning});

  final int index;
  final WordMeaning meaning;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final className = meaning.wordClassName;
    final definition = meaning.definition?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$index.',
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (className != null && className.isNotEmpty)
                  Text(
                    className,
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.primary,
                      fontSize: 12,
                    ),
                  ),
                if (definition != null && definition.isNotEmpty)
                  Text(
                    definition,
                    style: theme.typography.sm.copyWith(height: 1.35),
                  ),
                if (meaning.translations.isNotEmpty) ...[
                  const Gap(4),
                  ...meaning.translations.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '→ ${t.text}',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const Gap(4),
                  Text(
                    'Belum ada padanan',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (meaning.examples.isNotEmpty) ...[
                  const Gap(4),
                  ...meaning.examples.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.sourceSentence,
                            style: theme.typography.sm.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                          ),
                          if (e.targetSentence.trim().isNotEmpty)
                            Text(
                              e.targetSentence,
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.mutedForeground,
                                height: 1.3,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedRow extends StatelessWidget {
  const _RelatedRow({required this.related});

  final RelatedWord related;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return InkWell(
      onTap: () => context.push('/words/${related.wordId}'),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                related.lemma,
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              FLucideIcons.chevronRight,
              size: 14,
              color: theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow({required this.variant});

  final WordVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final meta = [
      if (!variant.isSpellingVariant) variant.variantTypeLabel,
      if (variant.affixValue != null && variant.affixValue!.isNotEmpty)
        '"${variant.affixValue}"',
      if (variant.notes != null && variant.notes!.isNotEmpty) variant.notes!,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          FBadge(variant: FBadgeVariant.secondary, child: Text(variant.form)),
          if (meta.isNotEmpty) ...[
            const Gap(8),
            Expanded(
              child: Text(
                meta,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

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

    // Mirror 1:1 struktur [_DetailBody]: thumb+meta → vote → makna → komentar.
    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shimmer),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone(
                    width: 72,
                    height: 72,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'lemma contoh kata',
                          style: theme.typography.xl.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          'Nomina',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '/ma.kan/',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Bone(
                    width: 56,
                    height: 22,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  Bone(
                    width: 72,
                    height: 22,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
              const Gap(10),
              Row(
                children: [
                  Text(
                    'Membantu?',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const Gap(8),
                  const VoteButtonsSkeleton(compact: true),
                ],
              ),
              const Gap(16),
              const _SectionLabel('Makna'),
              const Gap(6),
              const _MeaningSkeletonBlock(index: 1),
              const _MeaningSkeletonBlock(index: 2),
              const Gap(16),
              Text(
                'Komentar',
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colors.mutedForeground,
                  fontSize: 11,
                  letterSpacing: 0.06,
                ),
              ),
              const Gap(8),
              const _CommentSkeletonCard(),
              const Gap(8),
              const _CommentSkeletonCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeaningSkeletonBlock extends StatelessWidget {
  const _MeaningSkeletonBlock({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$index.',
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verba',
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.primary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Definisi makna singkat untuk skeleton layout',
                  style: theme.typography.sm.copyWith(height: 1.35),
                ),
                const Gap(4),
                Text(
                  '→ terjemahan contoh',
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentSkeletonCard extends StatelessWidget {
  const _CommentSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'nama pengguna',
            style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(6),
          Text(
            'isi komentar skeleton beberapa kata di sini',
            style: theme.typography.sm,
          ),
          const Gap(10),
          const VoteButtonsSkeleton(compact: true),
        ],
      ),
    );
  }
}

void showVerifierAttributionSheet(BuildContext context, WordDetail detail) {
  final username = detail.verifiedBy?.username;
  final verifiedAt = formatDateTimeIso(detail.verifiedAt);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      return Material(
        color: Theme.of(sheetContext).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Verifikator',
                        style: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  username != null
                      ? 'Diverifikasi oleh $username'
                      : 'Verifikator tidak diketahui',
                  style: theme.typography.sm,
                ),
                if (verifiedAt.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    verifiedAt,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
                if (username != null) ...[
                  const Gap(16),
                  FButton(
                    onPress: () {
                      Navigator.of(sheetContext).pop();
                      UserProfileRouter.open(context, username);
                    },
                    child: const Text('Lihat profil'),
                  ),
                ],
                const Gap(8),
              ],
            ),
          ),
        ),
      );
    },
  );
}
