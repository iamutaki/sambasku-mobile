import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/domain/entities/word_summary.dart';
import '../../../dictionary/domain/providers/dictionary_domain_providers.dart';
import '../../../dictionary/domain/usecases/list_latest_words_use_case.dart';
import '../../../my_votes/presentation/providers/my_votes_providers.dart';
import '../../domain/entities/vote_deck_item.dart';
import '../../domain/entities/vote_target.dart';
import '../../domain/failures/vote_failure.dart';
import '../../domain/providers/vote_domain_providers.dart';

part 'vote_deck_providers.g.dart';

class VoteDeckState {
  const VoteDeckState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<VoteDeckItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  VoteDeckState copyWith({
    List<VoteDeckItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearCursor = false,
  }) {
    return VoteDeckState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Antrean deck nilai kata (login). keepAlive + watch auth.
@Riverpod(keepAlive: true)
class VoteDeckController extends _$VoteDeckController {
  static const _pageSize = 10;

  @override
  Future<VoteDeckState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return const VoteDeckState();

    final result = await ref.watch(getVoteDeckUseCaseProvider)(limit: _pageSize);
    final page = result.match((failure) => throw failure, (page) => page);
    return VoteDeckState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<VoteFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref.watch(getVoteDeckUseCaseProvider)(
      limit: _pageSize,
      cursor: current.nextCursor,
    );
    return result.match(
      (failure) {
        final latest = state.value ?? current;
        state = AsyncData(latest.copyWith(isLoadingMore: false));
        return failure;
      },
      (page) {
        final latest = state.value ?? current;
        state = AsyncData(
          VoteDeckState(
            isLoadingMore: false,
            items: [...latest.items, ...page.items],
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
          ),
        );
        return null;
      },
    );
  }

  /// Vote lalu buang kartu dari antrean lokal. Return failure jika gagal.
  Future<VoteFailure?> castAndAdvance({
    required String wordId,
    required int value,
  }) async {
    final target = VoteTarget(type: 'word', id: wordId);
    final result = await ref.watch(toggleVoteUseCaseProvider)(
      target: target,
      value: value,
    );
    return result.match(
      (failure) => failure,
      (_) {
        AnalyticsService.instance.logVoteCast(
          targetType: target.type,
          direction: value,
        );
        ref.invalidate(myVotesListControllerProvider);
        _dropLocal(wordId);
        return null;
      },
    );
  }

  /// Lewati tanpa vote - hanya buang dari antrean sesi ini.
  void skipAndAdvance(String wordId) {
    AnalyticsService.instance.log(
      AnalyticsEvents.voteDeckSwipe,
      params: {'direction': 'skip', 'word_id': wordId},
    );
    _dropLocal(wordId);
  }

  void _dropLocal(String wordId) {
    final current = state.value;
    if (current == null) return;
    final remaining = current.items.where((i) => i.id != wordId).toList();
    state = AsyncData(current.copyWith(items: remaining));
    if (remaining.length <= 2 && current.hasMore) {
      loadMore();
    }
  }
}

/// Sample kartu untuk tamu (read-only) dari GET /words/latest.
@riverpod
Future<List<WordSummary>> voteDeckGuestSamples(Ref ref) async {
  final result = await ref.watch(listLatestWordsUseCaseProvider)(
    const ListLatestWordsParams(limit: 2),
  );
  return result.match((_) => <WordSummary>[], (page) => page.items.take(2).toList());
}
