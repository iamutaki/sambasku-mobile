import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_toggle_response_dto.freezed.dart';
part 'vote_toggle_response_dto.g.dart';

/// Data response POST /api/v1/votes - state vote final + counts segar.
@freezed
abstract class VoteToggleResponseDto with _$VoteToggleResponseDto {
  const factory VoteToggleResponseDto({
    @JsonKey(name: 'target_type') required String targetType,
    @JsonKey(name: 'target_id') required String targetId,
    @JsonKey(name: 'my_vote') int? myVote,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
  }) = _VoteToggleResponseDto;

  factory VoteToggleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VoteToggleResponseDtoFromJson(json);
}