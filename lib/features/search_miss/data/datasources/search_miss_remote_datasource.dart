import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/search_miss_dto.dart';

part 'search_miss_remote_datasource.g.dart';

/// Banner / daftar "Sedang dicari oleh user lain". Endpoint publik
/// tanpa auth, rate limit lebar (100 req/menit per IP).
///
/// Hanya miss yang sudah diizinkan admin (`is_visible=true`) -
/// filter ada di API, bukan di client (14-api-search-miss-moderation).
@RestApi()
abstract interface class SearchMissRemoteDatasource {
  factory SearchMissRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _SearchMissRemoteDatasource;

  @GET('/api/v1/search-misses')
  Future<ApiResponse<List<SearchMissDto>>> listSearchMisses(
    @Queries() Map<String, dynamic> query,
  );
}
