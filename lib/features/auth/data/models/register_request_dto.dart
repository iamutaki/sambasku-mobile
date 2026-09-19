import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request_dto.freezed.dart';
part 'register_request_dto.g.dart';

/// Body POST /api/v1/auth/register (00-api-auth.md).
/// `phone` = digit nasional tanpa prefix (opsional); server normalisasi ke 62….
@freezed
abstract class RegisterRequestDto with _$RegisterRequestDto {
  const factory RegisterRequestDto({
    required String name,
    required String email,
    @JsonKey(includeIfNull: false) String? phone,
    required String password,
    @JsonKey(name: 'confirm_password') required String confirmPassword,
  }) = _RegisterRequestDto;

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);
}

@freezed
abstract class RegisterResponseDto with _$RegisterResponseDto {
  const factory RegisterResponseDto({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    required String email,
    String? phone,
  }) = _RegisterResponseDto;

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseDtoFromJson(json);
}
