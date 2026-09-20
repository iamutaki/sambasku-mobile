import 'package:freezed_annotation/freezed_annotation.dart';

import 'create_word_translation_dto.dart';

part 'create_word_meaning_dto.freezed.dart';
part 'create_word_meaning_dto.g.dart';

/// Satu item array `meanings` (wajib min 1) sesuai backend
/// `createWordBodySchema`. Kata Sambas punya satu makna di form mobile,
/// jadi form flat (word_class_id/definition/translation_texts) di-transform
/// ke sini di `ContributionRepositoryImpl`.
@freezed
abstract class CreateWordMeaningDto with _$CreateWordMeaningDto {
  const factory CreateWordMeaningDto({
    @JsonKey(name: 'word_class_id') required String wordClassId,
    required String definition,
    // false = placeholder "-" (kontributor belum tahu definisi Indonesia).
    @JsonKey(name: 'is_have_definition') @Default(true) bool isHaveDefinition,
    @JsonKey(name: 'order_index') @Default(1) int orderIndex,
    required List<CreateWordTranslationDto> translations,
  }) = _CreateWordMeaningDto;

  factory CreateWordMeaningDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWordMeaningDtoFromJson(json);
}