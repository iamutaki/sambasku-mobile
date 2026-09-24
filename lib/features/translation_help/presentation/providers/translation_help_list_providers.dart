import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/translation_help_providers.dart';
import '../../domain/translation_help_models.dart';

class TranslationHelpListState {
  const TranslationHelpListState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.status,
  });

  final List<TranslationHelpItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String? status;

  TranslationHelpListState copyWith({
    List<TranslationHelpItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    String? status,
    bool clearCursor = false,
  }) {
    return TranslationHelpListState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      status: status ?? this.status,
    );
  }
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
    final page = await ref
        .watch(translationHelpRepositoryProvider)
        .listPublished(limit: _pageSize);
    return page.match(
      (failure) => throw failure,
      (value) => TranslationHelpListState(
        items: value.items,
        nextCursor: value.nextCursor,
        hasMore: value.hasMore,
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
        .listPublished(limit: _pageSize, cursor: current.nextCursor);
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
    return result.match(
      (failure) => throw failure,
      (item) => TranslationHelpDetailState(item: item),
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
