// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicProfileDto _$PublicProfileDtoFromJson(Map<String, dynamic> json) =>
    _PublicProfileDto(
      username: json['username'] as String,
      role: json['role'] as String,
      isVerifier: json['is_verifier'] as bool? ?? false,
      joinedAt: json['joined_at'] as String,
      stats: PublicProfileStatsDto.fromJson(
        json['stats'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PublicProfileDtoToJson(_PublicProfileDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'role': instance.role,
      'is_verifier': instance.isVerifier,
      'joined_at': instance.joinedAt,
      'stats': instance.stats,
    };

_PublicProfileStatsDto _$PublicProfileStatsDtoFromJson(
  Map<String, dynamic> json,
) => _PublicProfileStatsDto(
  contributionsApproved: (json['contributions_approved'] as num?)?.toInt() ?? 0,
  verificationsDone: (json['verifications_done'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PublicProfileStatsDtoToJson(
  _PublicProfileStatsDto instance,
) => <String, dynamic>{
  'contributions_approved': instance.contributionsApproved,
  'verifications_done': instance.verificationsDone,
};
