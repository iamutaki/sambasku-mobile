// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_word_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateWordRequestDto {

 String get lemma;@JsonKey(name: 'language_id') String get languageId;@JsonKey(name: 'word_class_id') String get wordClassId; String get definition;@JsonKey(name: 'dialect_id') String? get dialectId;@JsonKey(name: 'translation_texts') List<String> get translationTexts;@JsonKey(name: 'category_ids') List<String> get categoryIds; String? get notes;
/// Create a copy of CreateWordRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWordRequestDtoCopyWith<CreateWordRequestDto> get copyWith => _$CreateWordRequestDtoCopyWithImpl<CreateWordRequestDto>(this as CreateWordRequestDto, _$identity);

  /// Serializes this CreateWordRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWordRequestDto&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.wordClassId, wordClassId) || other.wordClassId == wordClassId)&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.dialectId, dialectId) || other.dialectId == dialectId)&&const DeepCollectionEquality().equals(other.translationTexts, translationTexts)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lemma,languageId,wordClassId,definition,dialectId,const DeepCollectionEquality().hash(translationTexts),const DeepCollectionEquality().hash(categoryIds),notes);

@override
String toString() {
  return 'CreateWordRequestDto(lemma: $lemma, languageId: $languageId, wordClassId: $wordClassId, definition: $definition, dialectId: $dialectId, translationTexts: $translationTexts, categoryIds: $categoryIds, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CreateWordRequestDtoCopyWith<$Res>  {
  factory $CreateWordRequestDtoCopyWith(CreateWordRequestDto value, $Res Function(CreateWordRequestDto) _then) = _$CreateWordRequestDtoCopyWithImpl;
@useResult
$Res call({
 String lemma,@JsonKey(name: 'language_id') String languageId,@JsonKey(name: 'word_class_id') String wordClassId, String definition,@JsonKey(name: 'dialect_id') String? dialectId,@JsonKey(name: 'translation_texts') List<String> translationTexts,@JsonKey(name: 'category_ids') List<String> categoryIds, String? notes
});




}
/// @nodoc
class _$CreateWordRequestDtoCopyWithImpl<$Res>
    implements $CreateWordRequestDtoCopyWith<$Res> {
  _$CreateWordRequestDtoCopyWithImpl(this._self, this._then);

  final CreateWordRequestDto _self;
  final $Res Function(CreateWordRequestDto) _then;

/// Create a copy of CreateWordRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lemma = null,Object? languageId = null,Object? wordClassId = null,Object? definition = null,Object? dialectId = freezed,Object? translationTexts = null,Object? categoryIds = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,wordClassId: null == wordClassId ? _self.wordClassId : wordClassId // ignore: cast_nullable_to_non_nullable
as String,definition: null == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String,dialectId: freezed == dialectId ? _self.dialectId : dialectId // ignore: cast_nullable_to_non_nullable
as String?,translationTexts: null == translationTexts ? _self.translationTexts : translationTexts // ignore: cast_nullable_to_non_nullable
as List<String>,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWordRequestDto].
extension CreateWordRequestDtoPatterns on CreateWordRequestDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWordRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWordRequestDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWordRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateWordRequestDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWordRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWordRequestDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lemma, @JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'word_class_id')  String wordClassId,  String definition, @JsonKey(name: 'dialect_id')  String? dialectId, @JsonKey(name: 'translation_texts')  List<String> translationTexts, @JsonKey(name: 'category_ids')  List<String> categoryIds,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWordRequestDto() when $default != null:
return $default(_that.lemma,_that.languageId,_that.wordClassId,_that.definition,_that.dialectId,_that.translationTexts,_that.categoryIds,_that.notes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lemma, @JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'word_class_id')  String wordClassId,  String definition, @JsonKey(name: 'dialect_id')  String? dialectId, @JsonKey(name: 'translation_texts')  List<String> translationTexts, @JsonKey(name: 'category_ids')  List<String> categoryIds,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _CreateWordRequestDto():
return $default(_that.lemma,_that.languageId,_that.wordClassId,_that.definition,_that.dialectId,_that.translationTexts,_that.categoryIds,_that.notes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lemma, @JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'word_class_id')  String wordClassId,  String definition, @JsonKey(name: 'dialect_id')  String? dialectId, @JsonKey(name: 'translation_texts')  List<String> translationTexts, @JsonKey(name: 'category_ids')  List<String> categoryIds,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _CreateWordRequestDto() when $default != null:
return $default(_that.lemma,_that.languageId,_that.wordClassId,_that.definition,_that.dialectId,_that.translationTexts,_that.categoryIds,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWordRequestDto implements CreateWordRequestDto {
  const _CreateWordRequestDto({required this.lemma, @JsonKey(name: 'language_id') required this.languageId, @JsonKey(name: 'word_class_id') required this.wordClassId, required this.definition, @JsonKey(name: 'dialect_id') this.dialectId, @JsonKey(name: 'translation_texts') required final  List<String> translationTexts, @JsonKey(name: 'category_ids') final  List<String> categoryIds = const [], this.notes}): _translationTexts = translationTexts,_categoryIds = categoryIds;
  factory _CreateWordRequestDto.fromJson(Map<String, dynamic> json) => _$CreateWordRequestDtoFromJson(json);

@override final  String lemma;
@override@JsonKey(name: 'language_id') final  String languageId;
@override@JsonKey(name: 'word_class_id') final  String wordClassId;
@override final  String definition;
@override@JsonKey(name: 'dialect_id') final  String? dialectId;
 final  List<String> _translationTexts;
@override@JsonKey(name: 'translation_texts') List<String> get translationTexts {
  if (_translationTexts is EqualUnmodifiableListView) return _translationTexts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_translationTexts);
}

 final  List<String> _categoryIds;
@override@JsonKey(name: 'category_ids') List<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryIds);
}

@override final  String? notes;

/// Create a copy of CreateWordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWordRequestDtoCopyWith<_CreateWordRequestDto> get copyWith => __$CreateWordRequestDtoCopyWithImpl<_CreateWordRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWordRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWordRequestDto&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.wordClassId, wordClassId) || other.wordClassId == wordClassId)&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.dialectId, dialectId) || other.dialectId == dialectId)&&const DeepCollectionEquality().equals(other._translationTexts, _translationTexts)&&const DeepCollectionEquality().equals(other._categoryIds, _categoryIds)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lemma,languageId,wordClassId,definition,dialectId,const DeepCollectionEquality().hash(_translationTexts),const DeepCollectionEquality().hash(_categoryIds),notes);

@override
String toString() {
  return 'CreateWordRequestDto(lemma: $lemma, languageId: $languageId, wordClassId: $wordClassId, definition: $definition, dialectId: $dialectId, translationTexts: $translationTexts, categoryIds: $categoryIds, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$CreateWordRequestDtoCopyWith<$Res> implements $CreateWordRequestDtoCopyWith<$Res> {
  factory _$CreateWordRequestDtoCopyWith(_CreateWordRequestDto value, $Res Function(_CreateWordRequestDto) _then) = __$CreateWordRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String lemma,@JsonKey(name: 'language_id') String languageId,@JsonKey(name: 'word_class_id') String wordClassId, String definition,@JsonKey(name: 'dialect_id') String? dialectId,@JsonKey(name: 'translation_texts') List<String> translationTexts,@JsonKey(name: 'category_ids') List<String> categoryIds, String? notes
});




}
/// @nodoc
class __$CreateWordRequestDtoCopyWithImpl<$Res>
    implements _$CreateWordRequestDtoCopyWith<$Res> {
  __$CreateWordRequestDtoCopyWithImpl(this._self, this._then);

  final _CreateWordRequestDto _self;
  final $Res Function(_CreateWordRequestDto) _then;

/// Create a copy of CreateWordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lemma = null,Object? languageId = null,Object? wordClassId = null,Object? definition = null,Object? dialectId = freezed,Object? translationTexts = null,Object? categoryIds = null,Object? notes = freezed,}) {
  return _then(_CreateWordRequestDto(
lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,wordClassId: null == wordClassId ? _self.wordClassId : wordClassId // ignore: cast_nullable_to_non_nullable
as String,definition: null == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String,dialectId: freezed == dialectId ? _self.dialectId : dialectId // ignore: cast_nullable_to_non_nullable
as String?,translationTexts: null == translationTexts ? _self._translationTexts : translationTexts // ignore: cast_nullable_to_non_nullable
as List<String>,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
