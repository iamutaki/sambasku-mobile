import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_miss_dto.freezed.dart';
part 'search_miss_dto.g.dart';

/// DTO untuk `ApiResponse<List<SearchMissDto>>` dari endpoint
/// `GET /api/v1/search-misses`. Field 1:1 sama dengan entity SearchMiss
/// tapi tanpa mapping custom business logic (repository yang akan
/// konversi ke entity).
@freezed
abstract class SearchMissDto with _$SearchMissDto {
  const factory SearchMissDto({
    required String id,
    required String term,
    @JsonKey(name: 'search_in') required String searchIn,
    @JsonKey(name: 'hit_count') required int hitCount,
    @JsonKey(name: 'last_searched_at') DateTime? lastSearchedAt,
  }) = _SearchMissDto;

  factory SearchMissDto.fromJson(Map<String, dynamic> json) =>
      _$SearchMissDtoFromJson(json);
}
