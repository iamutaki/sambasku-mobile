import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

/// Envelope standar backend sambasku (api-base-stack.md Section 13):
/// sukses = { success, data, meta? }; gagal = { success, error_code,
/// message, details? }. `meta` untuk list cursor-based dibaca manual
/// (next_cursor / has_more) di repository impl.
@Freezed(genericArgumentFactories: true)
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    bool? success,
    String? message,
    @JsonKey(name: 'error_code') String? errorCode,
    List<ApiErrorDetail>? details,
    T? data,
    Map<String, dynamic>? meta,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
}

/// Satu item `details` pada VALIDATION_ERROR - dipetakan ke error inline
/// per field form (mobile-base-stack Section 11).
@freezed
abstract class ApiErrorDetail with _$ApiErrorDetail {
  const factory ApiErrorDetail({
    required String field,
    required String message,
  }) = _ApiErrorDetail;

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorDetailFromJson(json);
}
