import 'package:freezed_annotation/freezed_annotation.dart';

part 'public_profile_dto.freezed.dart';
part 'public_profile_dto.g.dart';

@freezed
abstract class PublicProfileDto with _$PublicProfileDto {
  const factory PublicProfileDto({
    required String username,
    required String role,
    @JsonKey(name: 'is_verifier') @Default(false) bool isVerifier,
    @JsonKey(name: 'joined_at') required String joinedAt,
    required PublicProfileStatsDto stats,
  }) = _PublicProfileDto;

  factory PublicProfileDto.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileDtoFromJson(json);
}

@freezed
abstract class PublicProfileStatsDto with _$PublicProfileStatsDto {
  const factory PublicProfileStatsDto({
    @JsonKey(name: 'contributions_approved')
    @Default(0)
    int contributionsApproved,
    @JsonKey(name: 'verifications_done') @Default(0) int verificationsDone,
  }) = _PublicProfileStatsDto;

  factory PublicProfileStatsDto.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileStatsDtoFromJson(json);
}
