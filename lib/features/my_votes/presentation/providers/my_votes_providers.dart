import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/failures/my_vote_failure.dart';
import '../../domain/providers/my_vote_domain_providers.dart';
import '../models/my_votes_state.dart';

part 'my_votes_providers.g.dart';

/// Daftar riwayat vote. keepAlive + watch auth: login/logout memuat ulang
/// tanpa invalidate dari AuthStatusNotifier (circular di Riverpod 3).
@Riverpod(keepAlive: true)
class MyVotesListController extends _$MyVotesListController {
  static const _pageSize = 20;

  @override
  Future<MyVotesState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return const MyVotesState();

    final result = await ref.watch(listMyVotesUseCaseProvider)(limit: _pageSize);
    final page = result.match((failure) => throw failure, (page) => page);
    return MyVotesState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<MyVoteFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref.watch(listMyVotesUseCaseProvider)(
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
          MyVotesState(
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
}
