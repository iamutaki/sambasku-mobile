import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/bookmark_data_providers.dart';
import '../usecases/get_bookmark_statuses_use_case.dart';
import '../usecases/get_my_bookmarks_use_case.dart';
import '../usecases/toggle_bookmark_use_case.dart';

part 'bookmark_domain_providers.g.dart';

@riverpod
ToggleBookmarkUseCase toggleBookmarkUseCase(Ref ref) =>
    ToggleBookmarkUseCase(ref.watch(bookmarkRepositoryProvider));

@riverpod
GetMyBookmarksUseCase getMyBookmarksUseCase(Ref ref) =>
    GetMyBookmarksUseCase(ref.watch(bookmarkRepositoryProvider));

@riverpod
GetBookmarkStatusesUseCase getBookmarkStatusesUseCase(Ref ref) =>
    GetBookmarkStatusesUseCase(ref.watch(bookmarkRepositoryProvider));
