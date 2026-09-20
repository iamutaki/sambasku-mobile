import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/my_submission.dart';
import '../../domain/failures/my_contribution_failure.dart';
import '../../domain/providers/my_contribution_domain_providers.dart';
import '../models/my_contributions_state.dart';

part 'my_contributions_providers.g.dart';

/// Daftar kontribusi milik user (cursor). Guest = state kosong.
/// keepAlive: cache saat keluar ke detail lalu kembali.
@Riverpod(keepAlive: true)
class MyContributionsListController extends _$MyContributionsListController {
  static const _pageSize = 20;

  @override
  Future<MyContributionsState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return const MyContributionsState();

    final result = await ref.watch(listMyContributionsUseCaseProvider)(
      limit: _pageSize,
    );
    final page = result.match((failure) => throw failure, (page) => page);
    return MyContributionsState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<MyContributionFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final result = await ref.watch(listMyContributionsUseCaseProvider)(
      limit: _pageSize,
      cursor: current.nextCursor,
    );
    return result.match(
      (failure) {
        final s = state.value ?? current;
        state = AsyncData(s.copyWith(isLoadingMore: false));
        return failure;
      },
      (page) {
        final s = state.value ?? current;
        state = AsyncData(
          s.copyWith(
            isLoadingMore: false,
            items: [...s.items, ...page.items],
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
          ),
        );
        return null;
      },
    );
  }
}

@riverpod
Future<MySubmission> myContributionDetail(
  Ref ref,
  String kind,
  String id,
) async {
  final result = await ref.watch(getMyContributionDetailUseCaseProvider)(
    kind: kind,
    id: id,
  );
  return result.match((failure) => throw failure, (item) => item);
}
