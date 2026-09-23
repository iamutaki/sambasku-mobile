import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/delete_account_message_dto.dart';
import '../models/delete_account_request_dto.dart';

part 'delete_account_remote_datasource.g.dart';

@RestApi()
abstract interface class DeleteAccountRemoteDatasource {
  factory DeleteAccountRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _DeleteAccountRemoteDatasource;

  @DELETE('/api/v1/auth/account')
  Future<ApiResponse<DeleteAccountMessageDto>> deleteAccount(
    @Body() DeleteAccountRequestDto body,
  );
}
