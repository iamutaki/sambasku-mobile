import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../comment/presentation/widgets/word_comments_section.dart';
import '../../../vote/domain/entities/vote_target.dart';
import '../../../vote/domain/failures/vote_failure.dart';
import '../../../vote/presentation/providers/vote_providers.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/entities/word_detail.dart';
import '../../domain/failures/dictionary_failure.dart';
import '../providers/word_detail_providers.dart';

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
        title: const Text('Detail kata'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
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
                    size: 56,
                    color: theme.colors.mutedForeground,
                  ),
                  const Gap(12),
                  Text(
                    isNotFound ? 'Kata tidak ditemukan' : 'Gagal memuat detail',
                    style: theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Text(
                    failure.message,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(20),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (primaryImage != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              primaryImage.url,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          const Gap(16),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                detail.lemma,
                style: theme.typography.xl2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (detail.isVerified)
              Icon(
                FLucideIcons.badgeCheck,
                size: 22,
                color: theme.colors.primary,
              ),
          ],
        ),
        const Gap(6),
        Text(
          detail.wordTypeLabel,
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
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
        if (detail.pronunciations.isNotEmpty) ...[
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.pronunciations
                .map((p) => FBadge(child: Text('${p.notation}: ${p.value}')))
                .toList(),
          ),
        ],
        if (detail.categories.isNotEmpty) ...[
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.categories
                .map((c) => FBadge(child: Text(c.name)))
                .toList(),
          ),
        ],
        const Gap(16),
        _WordVoteBar(wordId: wordId),
        if (detail.meanings.isNotEmpty) ...[
          const Gap(24),
          _SectionTitle('Makna'),
          const Gap(8),
          ...detail.meanings.map((m) => _MeaningCard(meaning: m)),
        ],
        if (detail.relatedWords.isNotEmpty) ...[
          const Gap(24),
          _SectionTitle('Relasi'),
          const Gap(8),
          ...detail.relatedWords.map((r) => _RelatedTile(related: r)),
        ],
        if (detail.appearsIn.isNotEmpty) ...[
          const Gap(24),
          _SectionTitle('Muncul dalam'),
          const Gap(8),
          ...detail.appearsIn.map((r) => _RelatedTile(related: r)),
        ],
        if (detail.variants.isNotEmpty) ...[
          const Gap(24),
          _SectionTitle('Varian'),
          const Gap(8),
          ...detail.variants.map((v) {
            final affix = [
              if (v.affixValue != null) v.affixValue,
              v.variantType,
            ].whereType<String>().join(' · ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FTile(
                title: Text(v.form),
                subtitle: Text(
                  v.notes?.isNotEmpty == true ? '${v.notes} · $affix' : affix,
                ),
              ),
            );
          }),
        ],
        const Gap(24),
        WordCommentsSection(wordId: wordId),
      ],
    );
  }
}

/// Vote bar kata (auth: toggle via VoteController; anonim: prompt login).
class _WordVoteBar extends ConsumerWidget {
  const _WordVoteBar({required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final target = VoteTarget(type: 'word', id: wordId);
    final async = ref.watch(voteControllerProvider(target));

    // Vote = bagian opsional detail: gagal load cukup shrink + toast,
    // jangan ganggu sisa halaman.
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

    // Constraint degeneratif (lebar < 50, mis. frame awal rute di device
    // Oppo yang mengirim width 0/negatif) langsung shrink - layout anak
    // tidak boleh melihat constraint gila. Guard di luar async.when agar
    // ketiga cabang (loading/error/data) terlindungi.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 50) return const SizedBox.shrink();

        return async.when(
          loading: () => Skeletonizer(
            enabled: true,
            child: Row(
              children: const [
                Flexible(
                  child: Text(
                    'Apakah kata ini membantu?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gap(12),
                Text('Upvote 0'),
                Gap(6),
                Text('Downvote 0'),
              ],
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (view) => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Apakah kata ini membantu?',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(12),
              Flexible(
                child: VoteButtons(
                  upvotes: view.upvotes,
                  downvotes: view.downvotes,
                  myVote: view.myVote,
                  onVote: (value) => _vote(context, ref, target, value),
                ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _MeaningCard extends StatelessWidget {
  const _MeaningCard({required this.meaning});

  final WordMeaning meaning;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final titleParts = <String>[
      if (meaning.wordClassName != null) meaning.wordClassName!,
      if (meaning.definition != null && meaning.definition!.isNotEmpty)
        meaning.definition!,
    ];
    final title = titleParts.isEmpty
        ? 'Makna ${meaning.orderIndex}'
        : titleParts.join(' - ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FCard(
        title: Text(title),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meaning.translations.isNotEmpty) ...[
              const Gap(8),
              Text(
                'Terjemahan',
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(4),
              ...meaning.translations.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${t.text} (${t.typeLabel})',
                    style: theme.typography.sm,
                  ),
                ),
              ),
            ],
            if (meaning.examples.isNotEmpty) ...[
              const Gap(8),
              Text(
                'Contoh',
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(4),
              ...meaning.examples.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.sourceSentence,
                        style: theme.typography.sm.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        e.targetSentence,
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
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
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({required this.related});

  final RelatedWord related;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FTile(
        title: Text(related.lemma),
        subtitle: Text(related.relationLabel),
        suffix: const Icon(FLucideIcons.chevronRight, size: 16),
        onPress: () => context.push('/words/${related.wordId}'),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('lemma skeleton judul panjang'),
          Gap(8),
          Text('tipe kata'),
          Gap(24),
          Text('Makna'),
          Gap(8),
          Text('definisi makna yang sedang dimuat dari server'),
          Gap(8),
          Text('terjemahan contoh baris'),
        ],
      ),
    );
  }
}
