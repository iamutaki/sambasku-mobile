import 'package:freezed_annotation/freezed_annotation.dart';

part 'resend_otp_request_dto.freezed.dart';
part 'resend_otp_request_dto.g.dart';

@freezed
abstract class ResendOtpRequestDto with _$ResendOtpRequestDto {
  const factory ResendOtpRequestDto({required String email}) =
      _ResendOtpRequestDto;

  factory ResendOtpRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ResendOtpRequestDtoFromJson(json);
}

@freezed
abstract class ResendOtpResponseDto with _$ResendOtpResponseDto {
  const factory ResendOtpResponseDto({required String message}) =
      _ResendOtpResponseDto;

  factory ResendOtpResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ResendOtpResponseDtoFromJson(json);
}
