import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/failures/my_comment_failure.dart';
import '../../domain/providers/my_comment_domain_providers.dart';
import '../models/my_comments_state.dart';

part 'my_comments_providers.g.dart';

/// Filter chip. null = Semua. Ganti nilai memuat ulang daftar dari awal.
@riverpod
class MyCommentsStatusFilter extends _$MyCommentsStatusFilter {
  @override
  String? build() => null;

  void select(String? status) => state = status;
}

@Riverpod(keepAlive: true)
class MyCommentsListController extends _$MyCommentsListController {
  static const _pageSize = 20;

  @override
  Future<MyCommentsState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    final status = ref.watch(myCommentsStatusFilterProvider);
    if (!(auth?.isAuth ?? false)) {
      return MyCommentsState(status: status);
    }

    final result = await ref.watch(listMyCommentsUseCaseProvider)(
      limit: _pageSize,
      status: status,
    );
    final page = result.match((failure) => throw failure, (page) => page);
    return MyCommentsState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
      status: status,
    );
  }

  Future<MyCommentFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }

    state = AsyncData(
      MyCommentsState(
        items: current.items,
        nextCursor: current.nextCursor,
        hasMore: current.hasMore,
        isLoadingMore: true,
        status: current.status,
      ),
    );
    final result = await ref.watch(listMyCommentsUseCaseProvider)(
      limit: _pageSize,
      cursor: current.nextCursor,
      status: current.status,
    );
    return result.match(
      (failure) {
        state = AsyncData(
          MyCommentsState(
            items: current.items,
            nextCursor: current.nextCursor,
            hasMore: current.hasMore,
            status: current.status,
          ),
        );
        return failure;
      },
      (page) {
        state = AsyncData(
          MyCommentsState(
            items: [...current.items, ...page.items],
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
            status: current.status,
          ),
        );
        return null;
      },
    );
  }
}
