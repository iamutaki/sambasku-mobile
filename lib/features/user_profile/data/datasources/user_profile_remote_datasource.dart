import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/public_profile_dto.dart';

part 'user_profile_remote_datasource.g.dart';

/// GET /api/v1/users/:username (19-api-profil-publik.md). Publik, tanpa auth.
@RestApi()
abstract interface class UserProfileRemoteDatasource {
  factory UserProfileRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _UserProfileRemoteDatasource;

  @GET('/api/v1/users/{username}')
  Future<ApiResponse<PublicProfileDto>> getByUsername(
    @Path('username') String username,
  );
}
