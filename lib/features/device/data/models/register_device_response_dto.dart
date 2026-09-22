import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_device_response_dto.freezed.dart';
part 'register_device_response_dto.g.dart';

@freezed
abstract class RegisterDeviceResponseDto with _$RegisterDeviceResponseDto {
  const factory RegisterDeviceResponseDto({
    required String udid,
    @JsonKey(name: 'fcm_token_registered') required bool fcmTokenRegistered,
  }) = _RegisterDeviceResponseDto;

  factory RegisterDeviceResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterDeviceResponseDtoFromJson(json);
}
