import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_word_translation_dto.freezed.dart';
part 'create_word_translation_dto.g.dart';

/// Satu item `translations` di dalam `meanings`.
///
/// Backend `createWordBodySchema`: butuh `language_id` (bahasa target
/// terjemahan, di mobile selalu bahasa Indonesia), `translation_text`,
/// dan `translation_type` (default `direct`).
@freezed
abstract class CreateWordTranslationDto with _$CreateWordTranslationDto {
  const factory CreateWordTranslationDto({
    @JsonKey(name: 'language_id') required String languageId,
    @JsonKey(name: 'translation_text') required String translationText,
    @JsonKey(name: 'translation_type')
    @Default('direct')
    String translationType,
  }) = _CreateWordTranslationDto;

  factory CreateWordTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWordTranslationDtoFromJson(json);
}
