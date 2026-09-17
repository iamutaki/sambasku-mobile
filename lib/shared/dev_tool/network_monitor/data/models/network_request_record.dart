import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_request_record.freezed.dart';
part 'network_request_record.g.dart';

@freezed
abstract class NetworkRequestRecord with _$NetworkRequestRecord {
  const factory NetworkRequestRecord({
    required String id,
    required DateTime startedAt,
    required String method,
    required String url,
    required String path,
    DateTime? finishedAt,
    int? statusCode,
    int? durationMs,
    @Default(<String, String>{}) Map<String, String> queryParameters,
    @Default(<String, String>{}) Map<String, String> requestHeaders,
    String? requestBody,
    @Default(<String, String>{}) Map<String, String> responseHeaders,
    String? responseBody,
    String? errorMessage,
    @Default(false) bool isError,
  }) = _NetworkRequestRecord;

  factory NetworkRequestRecord.fromJson(Map<String, dynamic> json) =>
      _$NetworkRequestRecordFromJson(json);
}
