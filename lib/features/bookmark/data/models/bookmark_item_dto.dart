import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_item_dto.freezed.dart';
part 'bookmark_item_dto.g.dart';

/// Satu item data GET /api/v1/bookmarks/my - bookmark + ringkasan kata.
@freezed
abstract class BookmarkItemDto with _$BookmarkItemDto {
  const factory BookmarkItemDto({
    @JsonKey(name: 'word_id') required String wordId,
    @JsonKey(name: 'bookmarked_at') String? bookmarkedAt,
    required BookmarkWordDto word,
  }) = _BookmarkItemDto;

  factory BookmarkItemDto.fromJson(Map<String, dynamic> json) =>
      _$BookmarkItemDtoFromJson(json);
}

/// Ringkasan kata pada item bookmark (subset minimal list UI).
@freezed
abstract class BookmarkWordDto with _$BookmarkWordDto {
  const factory BookmarkWordDto({
    required String id,
    required String lemma,
    @JsonKey(name: 'word_type') @Default('word') String wordType,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
  }) = _BookmarkWordDto;

  factory BookmarkWordDto.fromJson(Map<String, dynamic> json) =>
      _$BookmarkWordDtoFromJson(json);
}
