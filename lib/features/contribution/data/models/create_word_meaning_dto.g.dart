// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_word_meaning_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateWordMeaningDto _$CreateWordMeaningDtoFromJson(
  Map<String, dynamic> json,
) => _CreateWordMeaningDto(
  wordClassId: json['word_class_id'] as String,
  definition: json['definition'] as String,
  orderIndex: (json['order_index'] as num?)?.toInt() ?? 1,
  translations: (json['translations'] as List<dynamic>)
      .map((e) => CreateWordTranslationDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CreateWordMeaningDtoToJson(
  _CreateWordMeaningDto instance,
) => <String, dynamic>{
  'word_class_id': instance.wordClassId,
  'definition': instance.definition,
  'order_index': instance.orderIndex,
  'translations': instance.translations,
};
