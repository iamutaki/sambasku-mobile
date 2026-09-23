import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/review_access.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepositoryImpl(ref.watch(dioProvider)),
);

/// Titik oranye: ada minimal satu usulan menunggu. Gagal jaringan = tidak ada titik.
final reviewQueueHasPendingProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(authStatusProvider).value;
  if (!canReviewQueue(auth?.role)) return false;
  final page = await ref.watch(reviewRepositoryProvider).list(
    status: 'pending',
    limit: 1,
  );
  return page.match((_) => false, (value) => value.items.isNotEmpty);
});

class ReviewQueueQuery {
  const ReviewQueueQuery({this.entityType, this.wordId});

  final String? entityType;
  final String? wordId;

  @override
  bool operator ==(Object other) =>
      other is ReviewQueueQuery &&
      other.entityType == entityType &&
      other.wordId == wordId;

  @override
  int get hashCode => Object.hash(entityType, wordId);
}

class ReviewQueueState {
  const ReviewQueueState({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<ReviewItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  ReviewQueueState copyWith({
    List<ReviewItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearCursor = false,
  }) {
    return ReviewQueueState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final reviewQueueProvider = AsyncNotifierProvider.autoDispose
    .family<ReviewQueueController, ReviewQueueState, ReviewQueueQuery>(
      ReviewQueueController.new,
    );

class ReviewQueueController extends AsyncNotifier<ReviewQueueState> {
  ReviewQueueController(this.query);

  final ReviewQueueQuery query;
  static const _pageSize = 20;

  @override
  Future<ReviewQueueState> build() async {
    final page = await ref.watch(reviewRepositoryProvider).list(
      status: 'pending',
      entityType: query.entityType,
      wordId: query.wordId,
      limit: _pageSize,
    );
    return page.match(
      (failure) => throw failure,
      (value) => ReviewQueueState(
        items: value.items,
        nextCursor: value.nextCursor,
        hasMore: value.hasMore,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final page = await ref.read(reviewRepositoryProvider).list(
      status: 'pending',
      entityType: query.entityType,
      wordId: query.wordId,
      limit: _pageSize,
      cursor: current.nextCursor,
    );
    page.match(
      (failure) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
      (value) {
        state = AsyncData(
          current.copyWith(
            items: [...current.items, ...value.items],
            nextCursor: value.nextCursor,
            hasMore: value.hasMore,
            isLoadingMore: false,
            clearCursor: value.nextCursor == null,
          ),
        );
      },
    );
  }

  void drop(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: current.items.where((item) => item.id != id).toList(),
      ),
    );
  }
}

final reviewDetailProvider = FutureProvider.autoDispose.family<ReviewDetail, String>((
  ref,
  id,
) async {
  final result = await ref.watch(reviewRepositoryProvider).detail(id);
  return result.match((failure) => throw failure, (detail) => detail);
});

void invalidateReviewQueue(WidgetRef ref) {
  ref.invalidate(reviewQueueHasPendingProvider);
  ref.invalidate(reviewQueueProvider);
}
