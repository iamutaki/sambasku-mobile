import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_word_example_dto.freezed.dart';
part 'create_word_example_dto.g.dart';

/// Satu contoh kalimat pada makna (`meanings[].examples[]`).
/// Bahasa sumber = bahasa lemma (Sambas). Terjemahan contoh opsional di API
/// dan tidak diisi dari mode standar.
@freezed
abstract class CreateWordExampleDto with _$CreateWordExampleDto {
  const factory CreateWordExampleDto({
    @JsonKey(name: 'source_language_id') required String sourceLanguageId,
    @JsonKey(name: 'source_sentence') required String sourceSentence,
  }) = _CreateWordExampleDto;

  factory CreateWordExampleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWordExampleDtoFromJson(json);
}
