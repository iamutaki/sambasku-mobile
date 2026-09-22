import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/bookmark_item_dto.dart';
import '../models/toggle_bookmark_request_dto.dart';
import '../models/toggle_bookmark_response_dto.dart';

part 'bookmark_remote_datasource.g.dart';

/// Endpoint bookmark kata per user (16-api-bookmark.md).
@RestApi()
abstract interface class BookmarkRemoteDatasource {
  factory BookmarkRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _BookmarkRemoteDatasource;

  /// Toggle bookmark (login) - POST /api/v1/bookmarks.
  @POST('/api/v1/bookmarks')
  Future<ApiResponse<ToggleBookmarkResponseDto>> toggle(
    @Body() ToggleBookmarkRequestDto body,
  );

  /// Daftar bookmark user (login) - GET /api/v1/bookmarks/my.
  /// `word_ids` (koma) = mode cek status batch tanpa meta pagination.
  @GET('/api/v1/bookmarks/my')
  Future<ApiResponse<List<BookmarkItemDto>>> getMyBookmarks(
    @Queries() Map<String, dynamic> query,
  );
}
