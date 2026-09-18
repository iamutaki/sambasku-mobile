import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_request_dto.freezed.dart';
part 'logout_request_dto.g.dart';

@freezed
abstract class LogoutRequestDto with _$LogoutRequestDto {
  const factory LogoutRequestDto({
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'client_type') @Default('mobile') String clientType,
  }) = _LogoutRequestDto;

  factory LogoutRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestDtoFromJson(json);
}
