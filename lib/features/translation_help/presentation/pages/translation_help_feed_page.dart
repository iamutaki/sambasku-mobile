import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/translation_help_models.dart';
import '../../translation_help_router.dart';
import '../providers/translation_help_list_providers.dart';

/// Feed publik bantuan terjemahan yang sudah tayang.
class TranslationHelpFeedPage extends HookConsumerWidget {
  const TranslationHelpFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(translationHelpFeedProvider);
    final scroll = useScrollController();

    useEffect(() {
      void listener() {
        if (!scroll.hasClients) return;
        if (scroll.position.maxScrollExtent - scroll.position.pixels < 200) {
          ref.read(translationHelpFeedProvider.notifier).loadMore();
        }
      }

      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll]);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Bantuan Terjemahan'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.history),
            onPress: () => context.push(TranslationHelpRouter.mine.path),
          ),
          FHeaderAction(
            icon: const Icon(FLucideIcons.plus),
            onPress: () => context.push(TranslationHelpRouter.create.path),
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(translationHelpFeedProvider);
          await ref.read(translationHelpFeedProvider.future);
        },
        child: async.when(
          loading: () => const _FeedSkeleton(),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const Gap(40),
              Icon(
                FLucideIcons.circleAlert,
                size: 40,
                color: context.theme.colors.mutedForeground,
              ),
              const Gap(10),
              Text(
                error is TranslationHelpFailure
                    ? error.message
                    : 'Gagal memuat bantuan terjemahan',
                textAlign: TextAlign.center,
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => ref.invalidate(translationHelpFeedProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
          data: (state) {
            if (state.items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                children: [
                  Icon(
                    FLucideIcons.languages,
                    size: 40,
                    color: context.theme.colors.mutedForeground,
                  ),
                  const Gap(10),
                  Text(
                    'Belum ada bantuan yang tayang',
                    textAlign: TextAlign.center,
                    style: context.theme.typography.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    'Kirim foto atau teks yang sulit diterjemahkan supaya warga bisa membantu.',
                    textAlign: TextAlign.center,
                    style: context.theme.typography.sm.copyWith(
                      color: context.theme.colors.mutedForeground,
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
              controller: scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: context.theme.colors.border),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: FCircularProgress()),
                  );
                }
                return _FeedTile(item: state.items[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _FeedTile extends StatelessWidget {
  const _FeedTile({required this.item});

  final TranslationHelpItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final when = formatRelative(DateTime.tryParse(item.createdAt));
    final username = displayPublicUsername(item.username);
    final body = item.body?.trim() ?? '';
    final urls = item.imageDisplayUrls;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(TranslationHelpRouter.detailPath(item.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      username,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (when.isNotEmpty)
                    Text(
                      when,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              if (body.isNotEmpty) ...[
                const Gap(6),
                Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.sm,
                ),
              ],
              if (urls.isNotEmpty) ...[
                const Gap(8),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: urls.length.clamp(0, 4),
                    separatorBuilder: (_, _) => const Gap(6),
                    itemBuilder: (context, i) {
                      final src = urls[i];
                      final display = displayImageUrl(src, width: 200) ?? src;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: CachedNetworkImageWithFallback(
                            imageUrl: display,
                            fallbackUrl: src,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: 6,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.text(words: 2),
              Gap(8),
              Bone.multiText(lines: 2),
              Gap(8),
              Bone(width: 72, height: 72),
            ],
          ),
        ),
      ),
    );
  }
}
