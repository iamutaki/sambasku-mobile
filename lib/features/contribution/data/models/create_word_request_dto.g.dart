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
  dialectId: json['dialect_id'] as String?,
  wordType: json['word_type'] as String? ?? 'word',
  meanings: (json['meanings'] as List<dynamic>)
      .map((e) => CreateWordMeaningDto.fromJson(e as Map<String, dynamic>))
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
  'dialect_id': instance.dialectId,
  'word_type': instance.wordType,
  'meanings': instance.meanings,
  'category_ids': instance.categoryIds,
  'notes': ?instance.notes,
};
