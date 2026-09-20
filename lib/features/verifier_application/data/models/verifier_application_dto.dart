import 'package:freezed_annotation/freezed_annotation.dart';

part 'verifier_application_dto.freezed.dart';
part 'verifier_application_dto.g.dart';

@freezed
abstract class SocialLinkDto with _$SocialLinkDto {
  const factory SocialLinkDto({
    required String platform,
    required String url,
  }) = _SocialLinkDto;

  factory SocialLinkDto.fromJson(Map<String, dynamic> json) =>
      _$SocialLinkDtoFromJson(json);
}

@freezed
abstract class VerifierApplicationDto with _$VerifierApplicationDto {
  const factory VerifierApplicationDto({
    required String id,
    required String status,
    required String phone,
    required String address,
    @JsonKey(name: 'social_links') required List<SocialLinkDto> socialLinks,
    @JsonKey(name: 'admin_comment') String? adminComment,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _VerifierApplicationDto;

  factory VerifierApplicationDto.fromJson(Map<String, dynamic> json) =>
      _$VerifierApplicationDtoFromJson(json);
}

@freezed
abstract class SubmitVerifierApplicationRequestDto
    with _$SubmitVerifierApplicationRequestDto {
  const factory SubmitVerifierApplicationRequestDto({
    required String phone,
    required String address,
    @JsonKey(name: 'social_links') required List<SocialLinkDto> socialLinks,
  }) = _SubmitVerifierApplicationRequestDto;

  factory SubmitVerifierApplicationRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SubmitVerifierApplicationRequestDtoFromJson(json);
}
