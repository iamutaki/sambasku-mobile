import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_email_request_dto.freezed.dart';
part 'verify_email_request_dto.g.dart';

@freezed
abstract class VerifyEmailRequestDto with _$VerifyEmailRequestDto {
  const factory VerifyEmailRequestDto({
    required String email,
    required String code,
    @JsonKey(name: 'client_type') @Default('mobile') String clientType,
  }) = _VerifyEmailRequestDto;

  factory VerifyEmailRequestDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestDtoFromJson(json);
}
