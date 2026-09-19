import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/my_vote_dto.dart';
import '../models/vote_count_dto.dart';
import '../models/vote_toggle_request_dto.dart';
import '../models/vote_toggle_response_dto.dart';

part 'vote_remote_datasource.g.dart';

/// Endpoint vote polymorphic (08-api-upvote-downvote.md).
@RestApi()
abstract interface class VoteRemoteDatasource {
  factory VoteRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _VoteRemoteDatasource;

  /// Toggle vote (login) - POST /api/v1/votes.
  @POST('/api/v1/votes')
  Future<ApiResponse<VoteToggleResponseDto>> toggle(
    @Body() VoteToggleRequestDto body,
  );

  /// Batch jumlah vote (publik) - GET /api/v1/votes/counts.
  @GET('/api/v1/votes/counts')
  Future<ApiResponse<List<VoteCountDto>>> getCounts(
    @Queries() Map<String, dynamic> query,
  );

  /// Vote milik user (login) - GET /api/v1/votes/my.
  @GET('/api/v1/votes/my')
  Future<ApiResponse<List<MyVoteDto>>> getMyVotes(
    @Queries() Map<String, dynamic> query,
  );
}