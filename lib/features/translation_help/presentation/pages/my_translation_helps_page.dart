import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/translation_help_models.dart';
import '../../translation_help_router.dart';
import '../providers/translation_help_list_providers.dart';

const _statusFilters = <(String?, String)>[
  (null, 'Semua'),
  ('pending_review', 'Menunggu'),
  ('published', 'Tayang'),
  ('rejected', 'Ditolak'),
  ('taken_down', 'Diturunkan'),
];

/// Riwayat permintaan bantuan milik user login.
class MyTranslationHelpsPage extends ConsumerWidget {
  const MyTranslationHelpsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Bantuan Saya'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.plus),
            onPress: () => context.push(TranslationHelpRouter.create.path),
          ),
        ],
      ),
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => const _GuestState(),
        data: (status) =>
            status.isAuth ? const _MineList() : const _GuestState(),
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.languages,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              'Masuk dulu untuk melihat riwayat bantuan kamu',
              style: theme.typography.md.copyWith(fontWeight: FontWeight.w600),
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

class _MineList extends ConsumerWidget {
  const _MineList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final selected = ref.watch(myTranslationHelpsStatusFilterProvider);
    final async = ref.watch(myTranslationHelpsProvider);

    final chips = Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < _statusFilters.length; i++) ...[
              if (i > 0) const Gap(6),
              GestureDetector(
                onTap: () => ref
                    .read(myTranslationHelpsStatusFilterProvider.notifier)
                    .select(_statusFilters[i].$1),
                child: FBadge(
                  variant: selected == _statusFilters[i].$1
                      ? FBadgeVariant.primary
                      : FBadgeVariant.secondary,
                  child: Text(_statusFilters[i].$2),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Column(
      children: [
        chips,
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myTranslationHelpsProvider);
              await ref.read(myTranslationHelpsProvider.future);
            },
            child: async.when(
              loading: () => const _MineSkeleton(),
              error: (error, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  const Gap(40),
                  Text(
                    error is TranslationHelpFailure
                        ? error.message
                        : 'Gagal memuat riwayat',
                    textAlign: TextAlign.center,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const Gap(16),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => ref.invalidate(myTranslationHelpsProvider),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
              data: (state) {
                if (state.items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    children: [
                      const Gap(40),
                      Text(
                        'Belum ada permintaan bantuan',
                        textAlign: TextAlign.center,
                        style: theme.typography.md.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Kirim teks atau foto yang sulit diterjemahkan.',
                        textAlign: TextAlign.center,
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const Gap(16),
                      FButton(
                        onPress: () =>
                            context.push(TranslationHelpRouter.create.path),
                        child: const Text('Minta bantuan'),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                  itemCount:
                      state.items.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: theme.colors.border),
                  itemBuilder: (context, index) {
                    if (index >= state.items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: FCircularProgress()),
                      );
                    }
                    if (index == state.items.length - 3 && state.hasMore) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(myTranslationHelpsProvider.notifier)
                            .loadMore();
                      });
                    }
                    final item = state.items[index];
                    final when = formatDateTimeIso(item.createdAt);
                    final preview = item.body?.trim().isNotEmpty == true
                        ? item.body!.trim()
                        : (item.images.isEmpty
                              ? 'Tanpa teks'
                              : '${item.images.length} foto');
                    return FTile(
                      title: Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        [
                          item.statusLabel,
                          if (when.isNotEmpty) when,
                        ].join(' · '),
                      ),
                      suffix: const Icon(FLucideIcons.chevronRight),
                      onPress: () => context.push(
                        TranslationHelpRouter.detailPath(item.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MineSkeleton extends StatelessWidget {
  const _MineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: 6,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.text(words: 4),
              Gap(6),
              Bone.text(words: 2),
            ],
          ),
        ),
      ),
    );
  }
}
