import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/verifier_application_dto.dart';

part 'verifier_application_remote_datasource.g.dart';

@RestApi()
abstract interface class VerifierApplicationRemoteDatasource {
  factory VerifierApplicationRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _VerifierApplicationRemoteDatasource;

  @GET('/api/v1/verifier-applications/me')
  Future<ApiResponse<VerifierApplicationDto>> getMine();

  @POST('/api/v1/verifier-applications')
  Future<ApiResponse<VerifierApplicationDto>> submit(
    @Body() SubmitVerifierApplicationRequestDto body,
  );

  @PATCH('/api/v1/verifier-applications/me')
  Future<ApiResponse<VerifierApplicationDto>> resubmit(
    @Body() SubmitVerifierApplicationRequestDto body,
  );
}
