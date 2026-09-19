import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/change_password_request_dto.dart';
import '../models/message_response_dto.dart';

part 'change_password_remote_datasource.g.dart';

@RestApi()
abstract interface class ChangePasswordRemoteDatasource {
  factory ChangePasswordRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _ChangePasswordRemoteDatasource;

  @POST('/api/v1/auth/change-password')
  Future<ApiResponse<MessageResponseDto>> changePassword(
    @Body() ChangePasswordRequestDto body,
  );
}
