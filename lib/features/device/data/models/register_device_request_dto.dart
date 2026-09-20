import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_device_request_dto.freezed.dart';
part 'register_device_request_dto.g.dart';

@freezed
abstract class RegisterDeviceRequestDto with _$RegisterDeviceRequestDto {
  const factory RegisterDeviceRequestDto({
    required String udid,
    @JsonKey(name: 'fcm_token') required String fcmToken,
  }) = _RegisterDeviceRequestDto;

  factory RegisterDeviceRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterDeviceRequestDtoFromJson(json);
}
