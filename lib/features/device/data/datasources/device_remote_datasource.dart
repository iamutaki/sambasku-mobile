import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/register_device_request_dto.dart';
import '../models/revoke_device_request_dto.dart';

part 'device_remote_datasource.g.dart';

@RestApi()
abstract interface class DeviceRemoteDatasource {
  factory DeviceRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _DeviceRemoteDatasource;

  @POST('/api/v1/device/register')
  Future<ApiResponse<Map<String, dynamic>>> registerDevice(
    @Body() RegisterDeviceRequestDto body,
  );

  @PATCH('/api/v1/device/revoke')
  Future<ApiResponse<Map<String, dynamic>>> revokeDevice(
    @Body() RevokeDeviceRequestDto body,
  );
}
