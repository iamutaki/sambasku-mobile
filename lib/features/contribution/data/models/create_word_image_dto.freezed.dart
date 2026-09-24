// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_word_image_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateWordImageDto {

 String get url;@JsonKey(name: 'provider_file_id') String get providerFileId;/// Stock Media Explorer; absen = storage aktif (GitHub) di API.
@JsonKey(includeIfNull: false) String? get provider;@JsonKey(includeIfNull: false) String? get sha;@JsonKey(name: 'alt_text', includeIfNull: false) String? get altText;@JsonKey(name: 'is_primary') bool get isPrimary;
/// Create a copy of CreateWordImageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWordImageDtoCopyWith<CreateWordImageDto> get copyWith => _$CreateWordImageDtoCopyWithImpl<CreateWordImageDto>(this as CreateWordImageDto, _$identity);

  /// Serializes this CreateWordImageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWordImageDto&&(identical(other.url, url) || other.url == url)&&(identical(other.providerFileId, providerFileId) || other.providerFileId == providerFileId)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,providerFileId,provider,sha,altText,isPrimary);

@override
String toString() {
  return 'CreateWordImageDto(url: $url, providerFileId: $providerFileId, provider: $provider, sha: $sha, altText: $altText, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class $CreateWordImageDtoCopyWith<$Res>  {
  factory $CreateWordImageDtoCopyWith(CreateWordImageDto value, $Res Function(CreateWordImageDto) _then) = _$CreateWordImageDtoCopyWithImpl;
@useResult
$Res call({
 String url,@JsonKey(name: 'provider_file_id') String providerFileId,@JsonKey(includeIfNull: false) String? provider,@JsonKey(includeIfNull: false) String? sha,@JsonKey(name: 'alt_text', includeIfNull: false) String? altText,@JsonKey(name: 'is_primary') bool isPrimary
});




}
/// @nodoc
class _$CreateWordImageDtoCopyWithImpl<$Res>
    implements $CreateWordImageDtoCopyWith<$Res> {
  _$CreateWordImageDtoCopyWithImpl(this._self, this._then);

  final CreateWordImageDto _self;
  final $Res Function(CreateWordImageDto) _then;

/// Create a copy of CreateWordImageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? providerFileId = null,Object? provider = freezed,Object? sha = freezed,Object? altText = freezed,Object? isPrimary = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,providerFileId: null == providerFileId ? _self.providerFileId : providerFileId // ignore: cast_nullable_to_non_nullable
as String,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,sha: freezed == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWordImageDto].
extension CreateWordImageDtoPatterns on CreateWordImageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWordImageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWordImageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWordImageDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateWordImageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWordImageDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWordImageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'provider_file_id')  String providerFileId, @JsonKey(includeIfNull: false)  String? provider, @JsonKey(includeIfNull: false)  String? sha, @JsonKey(name: 'alt_text', includeIfNull: false)  String? altText, @JsonKey(name: 'is_primary')  bool isPrimary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWordImageDto() when $default != null:
return $default(_that.url,_that.providerFileId,_that.provider,_that.sha,_that.altText,_that.isPrimary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'provider_file_id')  String providerFileId, @JsonKey(includeIfNull: false)  String? provider, @JsonKey(includeIfNull: false)  String? sha, @JsonKey(name: 'alt_text', includeIfNull: false)  String? altText, @JsonKey(name: 'is_primary')  bool isPrimary)  $default,) {final _that = this;
switch (_that) {
case _CreateWordImageDto():
return $default(_that.url,_that.providerFileId,_that.provider,_that.sha,_that.altText,_that.isPrimary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url, @JsonKey(name: 'provider_file_id')  String providerFileId, @JsonKey(includeIfNull: false)  String? provider, @JsonKey(includeIfNull: false)  String? sha, @JsonKey(name: 'alt_text', includeIfNull: false)  String? altText, @JsonKey(name: 'is_primary')  bool isPrimary)?  $default,) {final _that = this;
switch (_that) {
case _CreateWordImageDto() when $default != null:
return $default(_that.url,_that.providerFileId,_that.provider,_that.sha,_that.altText,_that.isPrimary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWordImageDto implements CreateWordImageDto {
  const _CreateWordImageDto({required this.url, @JsonKey(name: 'provider_file_id') required this.providerFileId, @JsonKey(includeIfNull: false) this.provider, @JsonKey(includeIfNull: false) this.sha, @JsonKey(name: 'alt_text', includeIfNull: false) this.altText, @JsonKey(name: 'is_primary') this.isPrimary = false});
  factory _CreateWordImageDto.fromJson(Map<String, dynamic> json) => _$CreateWordImageDtoFromJson(json);

@override final  String url;
@override@JsonKey(name: 'provider_file_id') final  String providerFileId;
/// Stock Media Explorer; absen = storage aktif (GitHub) di API.
@override@JsonKey(includeIfNull: false) final  String? provider;
@override@JsonKey(includeIfNull: false) final  String? sha;
@override@JsonKey(name: 'alt_text', includeIfNull: false) final  String? altText;
@override@JsonKey(name: 'is_primary') final  bool isPrimary;

/// Create a copy of CreateWordImageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWordImageDtoCopyWith<_CreateWordImageDto> get copyWith => __$CreateWordImageDtoCopyWithImpl<_CreateWordImageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWordImageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWordImageDto&&(identical(other.url, url) || other.url == url)&&(identical(other.providerFileId, providerFileId) || other.providerFileId == providerFileId)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,providerFileId,provider,sha,altText,isPrimary);

@override
String toString() {
  return 'CreateWordImageDto(url: $url, providerFileId: $providerFileId, provider: $provider, sha: $sha, altText: $altText, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class _$CreateWordImageDtoCopyWith<$Res> implements $CreateWordImageDtoCopyWith<$Res> {
  factory _$CreateWordImageDtoCopyWith(_CreateWordImageDto value, $Res Function(_CreateWordImageDto) _then) = __$CreateWordImageDtoCopyWithImpl;
@override @useResult
$Res call({
 String url,@JsonKey(name: 'provider_file_id') String providerFileId,@JsonKey(includeIfNull: false) String? provider,@JsonKey(includeIfNull: false) String? sha,@JsonKey(name: 'alt_text', includeIfNull: false) String? altText,@JsonKey(name: 'is_primary') bool isPrimary
});




}
/// @nodoc
class __$CreateWordImageDtoCopyWithImpl<$Res>
    implements _$CreateWordImageDtoCopyWith<$Res> {
  __$CreateWordImageDtoCopyWithImpl(this._self, this._then);

  final _CreateWordImageDto _self;
  final $Res Function(_CreateWordImageDto) _then;

/// Create a copy of CreateWordImageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? providerFileId = null,Object? provider = freezed,Object? sha = freezed,Object? altText = freezed,Object? isPrimary = null,}) {
  return _then(_CreateWordImageDto(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,providerFileId: null == providerFileId ? _self.providerFileId : providerFileId // ignore: cast_nullable_to_non_nullable
as String,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,sha: freezed == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
