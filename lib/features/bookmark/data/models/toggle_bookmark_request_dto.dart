import 'package:freezed_annotation/freezed_annotation.dart';

part 'toggle_bookmark_request_dto.freezed.dart';
part 'toggle_bookmark_request_dto.g.dart';

/// Body POST /api/v1/bookmarks.
@freezed
abstract class ToggleBookmarkRequestDto with _$ToggleBookmarkRequestDto {
  const factory ToggleBookmarkRequestDto({
    @JsonKey(name: 'word_id') required String wordId,
  }) = _ToggleBookmarkRequestDto;

  factory ToggleBookmarkRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ToggleBookmarkRequestDtoFromJson(json);
}
