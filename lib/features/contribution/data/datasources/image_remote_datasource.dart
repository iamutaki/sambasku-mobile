import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/upload_credentials_dto.dart';

part 'image_remote_datasource.g.dart';

/// Kredensial direct-upload ImageKit (butuh Bearer + role contributor+).
@RestApi()
abstract interface class ImageRemoteDatasource {
  factory ImageRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _ImageRemoteDatasource;

  @GET('/api/v1/admin/images/upload-token')
  Future<ApiResponse<UploadCredentialsDto>> getUploadToken({
    @Query('folder') String folder = '/words',
  });
}
