import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/my_profile_dto.dart';

part 'edit_profile_remote_datasource.g.dart';

@RestApi()
abstract interface class EditProfileRemoteDatasource {
  factory EditProfileRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _EditProfileRemoteDatasource;

  @GET('/api/v1/users/me')
  Future<ApiResponse<MyProfileDto>> getMyProfile();

  @PATCH('/api/v1/users/me')
  Future<ApiResponse<MyProfileDto>> updateMyProfile(
    @Body() UpdateMyProfileRequestDto body,
  );
}
