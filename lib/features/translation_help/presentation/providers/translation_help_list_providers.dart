import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../vote/domain/providers/vote_domain_providers.dart';
import '../../data/translation_help_providers.dart';
import '../../domain/translation_help_models.dart';

class TranslationHelpListState {
  const TranslationHelpListState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.status,
    this.sort = 'latest',
  });

  final List<TranslationHelpItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String? status;
  final String sort;

  TranslationHelpListState copyWith({
    List<TranslationHelpItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    String? status,
    String? sort,
    bool clearCursor = false,
  }) {
    return TranslationHelpListState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      status: status ?? this.status,
      sort: sort ?? this.sort,
    );
  }
}

final translationHelpFeedSortProvider =
    NotifierProvider.autoDispose<TranslationHelpFeedSort, String>(
      TranslationHelpFeedSort.new,
    );

class TranslationHelpFeedSort extends Notifier<String> {
  @override
  String build() => 'latest';

  void select(String sort) => state = sort;
}

final translationHelpFeedProvider =
    AsyncNotifierProvider.autoDispose<
      TranslationHelpFeedController,
      TranslationHelpListState
    >(TranslationHelpFeedController.new);

class TranslationHelpFeedController
    extends AsyncNotifier<TranslationHelpListState> {
  static const _pageSize = 20;

  @override
  Future<TranslationHelpListState> build() async {
    final sort = ref.watch(translationHelpFeedSortProvider);
    final page = await ref
        .watch(translationHelpRepositoryProvider)
        .listPublished(limit: _pageSize, sort: sort);
    final value = page.match((failure) => throw failure, (v) => v);
    final items = await _attachMyVotes(value.items);
    return TranslationHelpListState(
      items: items,
      nextCursor: value.nextCursor,
      hasMore: value.hasMore,
      sort: sort,
    );
  }

  Future<List<TranslationHelpItem>> _attachMyVotes(
    List<TranslationHelpItem> items,
  ) async {
    if (items.isEmpty) return items;
    final auth = await ref.watch(authStatusProvider.future);
    if (!auth.isAuth) return items;

    final mine = await ref.watch(getMyVotesUseCaseProvider)(
      items.map((i) => i.voteTarget).toList(growable: false),
    );
    return mine.match(
      (failure) => items,
      (map) => items
          .map(
            (i) => map.containsKey(i.voteTarget.key)
                ? i.copyWith(myVote: map[i.voteTarget.key])
                : i,
          )
          .toList(growable: false),
    );
  }

  Future<TranslationHelpFailure?> toggleHelpVote(
    TranslationHelpItem item,
    int value,
  ) async {
    final current = state.value;
    if (current == null) {
      return const TranslationHelpFailure('Belum siap');
    }

    final result = await ref.watch(toggleVoteUseCaseProvider)(
      target: item.voteTarget,
      value: value,
    );
    return result.match(
      (failure) => TranslationHelpFailure(
        failure.message,
        errorCode: failure.errorCode,
      ),
      (view) {
        state = AsyncData(
          current.copyWith(
            items: [
              for (final i in current.items)
                i.id == item.id
                    ? i.copyWith(upvotes: view.upvotes, myVote: view.myVote)
                    : i,
            ],
          ),
        );
        return null;
      },
    );
  }

  Future<TranslationHelpFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final page = await ref
        .read(translationHelpRepositoryProvider)
        .listPublished(
          limit: _pageSize,
          cursor: current.nextCursor,
          sort: current.sort,
        );
    final failureOrNull = page.match(
      (failure) => failure,
      (_) => null,
    );
    if (failureOrNull != null) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      return failureOrNull;
    }
    final value = page.match((_) => throw StateError('unreachable'), (v) => v);
    final more = await _attachMyVotes(value.items);
    state = AsyncData(
      current.copyWith(
        items: [...current.items, ...more],
        nextCursor: value.nextCursor,
        hasMore: value.hasMore,
        isLoadingMore: false,
      ),
    );
    return null;
  }
}

final myTranslationHelpsStatusFilterProvider =
    NotifierProvider.autoDispose<MyTranslationHelpsStatusFilter, String?>(
      MyTranslationHelpsStatusFilter.new,
    );

class MyTranslationHelpsStatusFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? status) => state = status;
}

final myTranslationHelpsProvider =
    AsyncNotifierProvider.autoDispose<
      MyTranslationHelpsController,
      TranslationHelpListState
    >(MyTranslationHelpsController.new);

class MyTranslationHelpsController
    extends AsyncNotifier<TranslationHelpListState> {
  static const _pageSize = 20;

  @override
  Future<TranslationHelpListState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    final status = ref.watch(myTranslationHelpsStatusFilterProvider);
    if (!(auth?.isAuth ?? false)) {
      return TranslationHelpListState(status: status);
    }
    final page = await ref
        .watch(translationHelpRepositoryProvider)
        .listMine(limit: _pageSize, status: status);
    return page.match(
      (failure) => throw failure,
      (value) => TranslationHelpListState(
        items: value.items,
        nextCursor: value.nextCursor,
        hasMore: value.hasMore,
        status: status,
      ),
    );
  }

  Future<TranslationHelpFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final page = await ref
        .read(translationHelpRepositoryProvider)
        .listMine(
          limit: _pageSize,
          cursor: current.nextCursor,
          status: current.status,
        );
    return page.match(
      (failure) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
        return failure;
      },
      (value) {
        state = AsyncData(
          current.copyWith(
            items: [...current.items, ...value.items],
            nextCursor: value.nextCursor,
            hasMore: value.hasMore,
            isLoadingMore: false,
          ),
        );
        return null;
      },
    );
  }
}

class TranslationHelpDetailState {
  const TranslationHelpDetailState({
    required this.item,
    this.isSubmittingReply = false,
  });

  final TranslationHelpItem item;
  final bool isSubmittingReply;

  TranslationHelpDetailState copyWith({
    TranslationHelpItem? item,
    bool? isSubmittingReply,
  }) {
    return TranslationHelpDetailState(
      item: item ?? this.item,
      isSubmittingReply: isSubmittingReply ?? this.isSubmittingReply,
    );
  }
}

final translationHelpDetailProvider = AsyncNotifierProvider.autoDispose
    .family<TranslationHelpDetailController, TranslationHelpDetailState, String>(
      TranslationHelpDetailController.new,
    );

class TranslationHelpDetailController
    extends AsyncNotifier<TranslationHelpDetailState> {
  TranslationHelpDetailController(this.helpId);

  final String helpId;

  @override
  Future<TranslationHelpDetailState> build() async {
    final result = await ref
        .watch(translationHelpRepositoryProvider)
        .getDetail(helpId);
    final item = result.match((failure) => throw failure, (item) => item);
    final withHelpVote = await _attachHelpMyVote(item);
    final replies = await _attachMyVotes(withHelpVote.replies);
    return TranslationHelpDetailState(
      item: withHelpVote.copyWith(replies: replies),
    );
  }

  Future<TranslationHelpItem> _attachHelpMyVote(TranslationHelpItem item) async {
    if (!item.isPublished) return item;

    final auth = await ref.watch(authStatusProvider.future);
    if (!auth.isAuth) return item;

    final mine = await ref.watch(getMyVotesUseCaseProvider)([item.voteTarget]);
    return mine.match(
      (failure) => item,
      (map) => map.containsKey(item.voteTarget.key)
          ? item.copyWith(myVote: map[item.voteTarget.key])
          : item,
    );
  }

  /// Seed myVote per balasan (batch) saat login; gagal = bukan blocker.
  Future<List<TranslationHelpReply>> _attachMyVotes(
    List<TranslationHelpReply> items,
  ) async {
    if (items.isEmpty) return items;

    final auth = await ref.watch(authStatusProvider.future);
    if (!auth.isAuth) return items;

    final published = items.where((r) => r.isPublished).toList(growable: false);
    if (published.isEmpty) return items;

    final mine = await ref.watch(getMyVotesUseCaseProvider)(
      published.map((r) => r.voteTarget).toList(growable: false),
    );
    return mine.match(
      (failure) => items,
      (map) => items
          .map(
            (r) => map.containsKey(r.voteTarget.key)
                ? r.copyWith(myVote: map[r.voteTarget.key])
                : r,
          )
          .toList(growable: false),
    );
  }

  Future<TranslationHelpFailure?> toggleHelpVote(int value) async {
    final current = state.value;
    if (current == null) {
      return const TranslationHelpFailure('Belum siap');
    }
    final item = current.item;
    if (!item.isPublished) {
      return const TranslationHelpFailure('Pertanyaan belum tayang');
    }

    final result = await ref.watch(toggleVoteUseCaseProvider)(
      target: item.voteTarget,
      value: value,
    );
    return result.match(
      (failure) => TranslationHelpFailure(
        failure.message,
        errorCode: failure.errorCode,
      ),
      (view) {
        state = AsyncData(
          current.copyWith(
            item: item.copyWith(
              upvotes: view.upvotes,
              myVote: view.myVote,
            ),
          ),
        );
        return null;
      },
    );
  }

  Future<TranslationHelpFailure?> toggleVote(
    TranslationHelpReply reply,
    int value,
  ) async {
    final current = state.value;
    if (current == null) {
      return const TranslationHelpFailure('Belum siap');
    }

    final result = await ref.watch(toggleVoteUseCaseProvider)(
      target: reply.voteTarget,
      value: value,
    );
    return result.match(
      (failure) => TranslationHelpFailure(
        failure.message,
        errorCode: failure.errorCode,
      ),
      (view) {
        final updated = reply.copyWith(
          upvotes: view.upvotes,
          downvotes: view.downvotes,
          myVote: view.myVote,
        );
        state = AsyncData(
          current.copyWith(
            item: current.item.copyWith(
              replies: [
                for (final r in current.item.replies)
                  r.id == updated.id ? updated : r,
              ],
            ),
          ),
        );
        return null;
      },
    );
  }

  Future<TranslationHelpFailure?> createReply(String body) async {
    final current = state.value;
    if (current == null) {
      return const TranslationHelpFailure('Belum siap');
    }
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const TranslationHelpFailure('Balasan minimal 1 karakter');
    }
    state = AsyncData(current.copyWith(isSubmittingReply: true));
    final result = await ref
        .read(translationHelpRepositoryProvider)
        .createReply(helpId: helpId, body: trimmed);
    return result.match(
      (failure) {
        state = AsyncData(current.copyWith(isSubmittingReply: false));
        return failure;
      },
      (reply) {
        state = AsyncData(
          TranslationHelpDetailState(
            item: current.item.copyWith(
              replies: [...current.item.replies, reply],
            ),
          ),
        );
        return null;
      },
    );
  }

  Future<TranslationHelpFailure?> deleteReply(TranslationHelpReply reply) async {
    final current = state.value;
    if (current == null) {
      return const TranslationHelpFailure('Belum siap');
    }
    final result = await ref
        .read(translationHelpRepositoryProvider)
        .deleteReply(reply.id);
    return result.match((failure) => failure, (_) {
      state = AsyncData(
        TranslationHelpDetailState(
          item: current.item.copyWith(
            replies: [
              for (final r in current.item.replies)
                if (r.id != reply.id) r,
            ],
          ),
        ),
      );
      return null;
    });
  }
}
