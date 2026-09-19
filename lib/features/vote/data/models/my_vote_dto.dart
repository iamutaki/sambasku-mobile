import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_vote_dto.freezed.dart';
part 'my_vote_dto.g.dart';

/// Satu item data GET /api/v1/votes/my - vote milik user untuk target.
@freezed
abstract class MyVoteDto with _$MyVoteDto {
  const factory MyVoteDto({
    @JsonKey(name: 'target_type') required String targetType,
    @JsonKey(name: 'target_id') required String targetId,
    required int value,
  }) = _MyVoteDto;

  factory MyVoteDto.fromJson(Map<String, dynamic> json) =>
      _$MyVoteDtoFromJson(json);
}