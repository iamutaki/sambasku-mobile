import 'package:freezed_annotation/freezed_annotation.dart';

part 'revoke_device_request_dto.freezed.dart';
part 'revoke_device_request_dto.g.dart';

@freezed
abstract class RevokeDeviceRequestDto with _$RevokeDeviceRequestDto {
  const factory RevokeDeviceRequestDto({
    required String udid,
  }) = _RevokeDeviceRequestDto;

  factory RevokeDeviceRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RevokeDeviceRequestDtoFromJson(json);
}
