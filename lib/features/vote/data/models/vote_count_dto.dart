import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_count_dto.freezed.dart';
part 'vote_count_dto.g.dart';

/// Satu item data GET /api/v1/votes/counts.
@freezed
abstract class VoteCountDto with _$VoteCountDto {
  const factory VoteCountDto({
    @JsonKey(name: 'target_type') required String targetType,
    @JsonKey(name: 'target_id') required String targetId,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
  }) = _VoteCountDto;

  factory VoteCountDto.fromJson(Map<String, dynamic> json) =>
      _$VoteCountDtoFromJson(json);
}