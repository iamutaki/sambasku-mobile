import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/login_request_dto.dart';
import '../models/login_response_dto.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract interface class AuthRemoteDatasource {
  factory AuthRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _AuthRemoteDatasource;

  @POST('/api/v1/auth/login')
  Future<ApiResponse<LoginResponseDto>> login(@Body() LoginRequestDto body);
}
