import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_word_request_dto.freezed.dart';
part 'create_word_request_dto.g.dart';

/// Body request POST /api/v1/contributions/words.
///
/// Anonim **tidak boleh** override `status` (dipaksa published → masuk
/// approval gate pending_review di controller backend). Semua ULID
/// reference (language_id, word_class_id, dialect_id, category_ids)
/// → jika tidak ada record: VALIDATION_ERROR 400 inline per field.
@freezed
abstract class CreateWordRequestDto with _$CreateWordRequestDto {
  const factory CreateWordRequestDto({
    required String lemma,
    @JsonKey(name: 'language_id') required String languageId,
    @JsonKey(name: 'word_class_id') required String wordClassId,
    required String definition,
    @JsonKey(name: 'dialect_id') String? dialectId,
    @JsonKey(name: 'translation_texts') required List<String> translationTexts,
    @JsonKey(name: 'category_ids') @Default([]) List<String> categoryIds,
    String? notes,
  }) = _CreateWordRequestDto;

  factory CreateWordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWordRequestDtoFromJson(json);
}
