import 'package:freezed_annotation/freezed_annotation.dart';

part 'reset_password_dto.freezed.dart';
part 'reset_password_dto.g.dart';

/// Body POST /api/v1/auth/forgot-password.
@freezed
abstract class ForgotPasswordRequestDto with _$ForgotPasswordRequestDto {
  const factory ForgotPasswordRequestDto({required String email}) =
      _ForgotPasswordRequestDto;

  factory ForgotPasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestDtoFromJson(json);
}

/// Body POST /api/v1/auth/reset-password.
/// Jalur aplikasi: email + code. Cadangan tautan: token.
@freezed
abstract class ResetPasswordRequestDto with _$ResetPasswordRequestDto {
  const factory ResetPasswordRequestDto({
    @JsonKey(includeIfNull: false) String? token,
    @JsonKey(includeIfNull: false) String? email,
    @JsonKey(includeIfNull: false) String? code,
    @JsonKey(name: 'new_password') required String newPassword,
  }) = _ResetPasswordRequestDto;

  factory ResetPasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestDtoFromJson(json);
}

/// Payload `data` envelope `{ message }` (forgot + reset).
@freezed
abstract class AuthMessageResponseDto with _$AuthMessageResponseDto {
  const factory AuthMessageResponseDto({required String message}) =
      _AuthMessageResponseDto;

  factory AuthMessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthMessageResponseDtoFromJson(json);
}
