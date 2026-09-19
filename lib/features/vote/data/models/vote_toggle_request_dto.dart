import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_toggle_request_dto.freezed.dart';
part 'vote_toggle_request_dto.g.dart';

/// Body POST /api/v1/votes (toggle).
@freezed
abstract class VoteToggleRequestDto with _$VoteToggleRequestDto {
  const factory VoteToggleRequestDto({
    @JsonKey(name: 'target_type') required String targetType,
    @JsonKey(name: 'target_id') required String targetId,
    required int value,
  }) = _VoteToggleRequestDto;

  factory VoteToggleRequestDto.fromJson(Map<String, dynamic> json) =>
      _$VoteToggleRequestDtoFromJson(json);
}