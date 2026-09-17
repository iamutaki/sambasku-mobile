import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/word_detail_dto.dart';
import '../models/word_summary_dto.dart';

part 'dictionary_remote_datasource.g.dart';

@RestApi()
abstract interface class DictionaryRemoteDatasource {
  factory DictionaryRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _DictionaryRemoteDatasource;

  /// Pencarian kata - cursor-based (?q=&limit=&cursor=&search_in=).
  /// Endpoint publik tanpa auth.
  @GET('/api/v1/words/search')
  Future<ApiResponse<List<WordSummaryDto>>> searchWords(
    @Queries() Map<String, dynamic> query,
  );

  /// Detail kata lengkap (makna, terjemahan, relasi, dll). Publik.
  @GET('/api/v1/words/{id}')
  Future<ApiResponse<WordDetailDto>> getWordById(@Path('id') String id);
}
