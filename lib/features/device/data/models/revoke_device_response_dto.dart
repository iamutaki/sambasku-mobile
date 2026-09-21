import 'package:freezed_annotation/freezed_annotation.dart';

part 'revoke_device_response_dto.freezed.dart';
part 'revoke_device_response_dto.g.dart';

@freezed
abstract class RevokeDeviceResponseDto with _$RevokeDeviceResponseDto {
  const factory RevokeDeviceResponseDto({
    required String udid,
    required bool revoked,
  }) = _RevokeDeviceResponseDto;

  factory RevokeDeviceResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RevokeDeviceResponseDtoFromJson(json);
}
