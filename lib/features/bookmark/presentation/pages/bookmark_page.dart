import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/bookmark_item.dart';
import '../../domain/failures/bookmark_failure.dart';
import '../providers/bookmark_providers.dart';

/// Halaman daftar kata tersimpan milik user login - GET /api/v1/bookmarks/my
/// (16-api-bookmark.md). Diakses dari tile Bookmark di Profil.
class BookmarkPage extends ConsumerWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Bookmark'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      // Auth error → treat as guest (jangan spinner abadi lewat orElse).
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => const _GuestState(),
        data: (status) =>
            status.isAuth ? const _BookmarkList() : const _GuestState(),
      ),
    );
  }
}

class _GuestState extends StatelessWidget {
  const _GuestState();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.bookmark,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              'Masuk dulu untuk melihat kata tersimpan',
              style: theme.typography.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push('/login'),
              child: const Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkList extends ConsumerWidget {
  const _BookmarkList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final async = ref.watch(bookmarkListControllerProvider);

    // Riverpod `when` mengecek isLoading DULU - saat AsyncLoading+error
    // (retry/rebuild) cabang error tidak pernah dipanggil → spinner tanpa
    // pesan. Prefer hasError supaya 4xx/5xx selalu tampil ke user.
    if (async.hasError) {
      final error = async.error!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.circleAlert,
                size: 40,
                color: theme.colors.mutedForeground,
              ),
              const Gap(10),
              Text(
                error is BookmarkFailure
                    ? error.message
                    : 'Gagal memuat bookmark',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () =>
                    ref.invalidate(bookmarkListControllerProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (async.isLoading) {
      return const Center(child: FCircularProgress());
    }

    final state = async.requireValue;
    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.bookmark,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              'Belum ada kata tersimpan.',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(4),
            Text(
              'Tekan ikon bookmark di halaman detail kata.',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Compact list (mobile-base-stack §5a): FTile + Gap kecil, bukan FCard.
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const Gap(6),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              variant: FButtonVariant.ghost,
              onPress: state.isLoadingMore
                  ? null
                  : () => ref
                      .read(bookmarkListControllerProvider.notifier)
                      .loadMore(),
              prefix: state.isLoadingMore ? const FCircularProgress() : null,
              child: Text(
                state.isLoadingMore ? 'Memuat...' : 'Muat lainnya',
              ),
            ),
          );
        }
        return _BookmarkRow(item: state.items[index]);
      },
    );
  }
}

class _BookmarkRow extends ConsumerWidget {
  const _BookmarkRow({required this.item});

  final BookmarkItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    return FTile(
      title: Text(item.word.lemma),
      subtitle: Text(item.word.wordTypeLabel),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.word.isVerified) ...[
            Icon(
              FLucideIcons.badgeCheck,
              size: 16,
              color: theme.colors.primary,
            ),
            const Gap(4),
          ],
          _RemoveButton(wordId: item.wordId),
        ],
      ),
      onPress: () => context.push('/words/${item.wordId}'),
    );
  }
}

class _RemoveButton extends ConsumerWidget {
  const _RemoveButton({required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    // GestureDetector di suffix: serap tap supaya tidak ikut onPress tile.
    return Semantics(
      button: true,
      label: 'Lepas kata dari bookmark',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          final failure = await ref
              .read(bookmarkListControllerProvider.notifier)
              .remove(wordId);
          if (failure != null && context.mounted) {
            showFToast(
              context: context,
              title: Text(failure.message),
              variant: FToastVariant.destructive,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            FLucideIcons.trash2,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
