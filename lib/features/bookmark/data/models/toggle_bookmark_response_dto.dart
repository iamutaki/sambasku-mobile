import 'package:freezed_annotation/freezed_annotation.dart';

part 'toggle_bookmark_response_dto.freezed.dart';
part 'toggle_bookmark_response_dto.g.dart';

/// Data response POST /api/v1/bookmarks - state bookmark final kata.
@freezed
abstract class ToggleBookmarkResponseDto with _$ToggleBookmarkResponseDto {
  const factory ToggleBookmarkResponseDto({
    @JsonKey(name: 'word_id') required String wordId,
    @JsonKey(name: 'is_bookmarked') @Default(false) bool isBookmarked,
    @JsonKey(name: 'bookmarked_at') String? bookmarkedAt,
  }) = _ToggleBookmarkResponseDto;

  factory ToggleBookmarkResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ToggleBookmarkResponseDtoFromJson(json);
}
