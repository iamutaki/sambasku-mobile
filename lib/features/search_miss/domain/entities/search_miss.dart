import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_miss.freezed.dart';
part 'search_miss.g.dart';

/// Satu baris "pencarian yang tidak ketemu", ditampilkan sebagai banner
/// horizontal di HomeSearch (atas hasil pencarian). Endpoint publik:
/// `GET /api/v1/search-misses?limit=10` (sort hit_count DESC).
@freezed
abstract class SearchMiss with _$SearchMiss {
  const factory SearchMiss({
    required String id,
    required String term,
    @JsonKey(name: 'search_in') required String searchIn,
    @JsonKey(name: 'hit_count') required int hitCount,
    @JsonKey(name: 'last_searched_at') DateTime? lastSearchedAt,
  }) = _SearchMiss;

  factory SearchMiss.fromJson(Map<String, dynamic> json) =>
      _$SearchMissFromJson(json);
}
