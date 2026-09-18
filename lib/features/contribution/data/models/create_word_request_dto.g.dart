// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_word_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateWordRequestDto _$CreateWordRequestDtoFromJson(
  Map<String, dynamic> json,
) => _CreateWordRequestDto(
  lemma: json['lemma'] as String,
  languageId: json['language_id'] as String,
  wordClassId: json['word_class_id'] as String,
  definition: json['definition'] as String,
  dialectId: json['dialect_id'] as String?,
  translationTexts: (json['translation_texts'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  categoryIds:
      (json['category_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CreateWordRequestDtoToJson(
  _CreateWordRequestDto instance,
) => <String, dynamic>{
  'lemma': instance.lemma,
  'language_id': instance.languageId,
  'word_class_id': instance.wordClassId,
  'definition': instance.definition,
  'dialect_id': instance.dialectId,
  'translation_texts': instance.translationTexts,
  'category_ids': instance.categoryIds,
  'notes': instance.notes,
};
