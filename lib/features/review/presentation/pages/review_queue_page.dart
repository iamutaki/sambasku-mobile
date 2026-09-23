import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/failures/review_failure.dart';
import '../../domain/review_access.dart';
import '../providers/review_providers.dart';
import 'review_forbidden_page.dart';

class ReviewQueuePage extends ConsumerWidget {
  const ReviewQueuePage({super.key, this.wordId});

  final String? wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ReviewQueueQuery(wordId: wordId);
    final queue = ref.watch(reviewQueueProvider(query));
    final failure = queue.hasError ? queue.error : null;
    if (failure is ReviewFailure && failure.isForbidden) {
      return ReviewForbiddenPage(message: failure.message);
    }
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Tinjau usulan'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: queue.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              FAlert(
                variant: FAlertVariant.destructive,
                title: Text(
                  error is ReviewFailure ? error.message : 'Gagal memuat antrean',
                ),
              ),
              const Gap(12),
              FButton(
                onPress: () => ref.invalidate(reviewQueueProvider(query)),
                child: const Text('Muat ulang'),
              ),
            ],
          );
        },
        data: (state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('Tidak ada usulan yang menunggu.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: state.items.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const Gap(8),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return FButton(
                  variant: .outline,
                  onPress: state.isLoadingMore
                      ? null
                      : () => ref.read(reviewQueueProvider(query).notifier).loadMore(),
                  child: Text(state.isLoadingMore ? 'Memuat…' : 'Muat lagi'),
                );
              }
              final item = state.items[index];
              return FTile(
                title: Text(item.title),
                subtitle: Text(
                  '${reviewEntityLabel(item.entityType)} · ${item.contributorUsername ?? 'anonim'}',
                ),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => context.push('/review/${item.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
