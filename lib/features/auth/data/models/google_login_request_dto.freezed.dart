// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_login_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoogleLoginRequestDto {

@JsonKey(name: 'id_token') String get idToken;@JsonKey(name: 'client_type') String get clientType;
/// Create a copy of GoogleLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoogleLoginRequestDtoCopyWith<GoogleLoginRequestDto> get copyWith => _$GoogleLoginRequestDtoCopyWithImpl<GoogleLoginRequestDto>(this as GoogleLoginRequestDto, _$identity);

  /// Serializes this GoogleLoginRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoogleLoginRequestDto&&(identical(other.idToken, idToken) || other.idToken == idToken)&&(identical(other.clientType, clientType) || other.clientType == clientType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idToken,clientType);

@override
String toString() {
  return 'GoogleLoginRequestDto(idToken: $idToken, clientType: $clientType)';
}


}

/// @nodoc
abstract mixin class $GoogleLoginRequestDtoCopyWith<$Res>  {
  factory $GoogleLoginRequestDtoCopyWith(GoogleLoginRequestDto value, $Res Function(GoogleLoginRequestDto) _then) = _$GoogleLoginRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_token') String idToken,@JsonKey(name: 'client_type') String clientType
});




}
/// @nodoc
class _$GoogleLoginRequestDtoCopyWithImpl<$Res>
    implements $GoogleLoginRequestDtoCopyWith<$Res> {
  _$GoogleLoginRequestDtoCopyWithImpl(this._self, this._then);

  final GoogleLoginRequestDto _self;
  final $Res Function(GoogleLoginRequestDto) _then;

/// Create a copy of GoogleLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idToken = null,Object? clientType = null,}) {
  return _then(_self.copyWith(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GoogleLoginRequestDto].
extension GoogleLoginRequestDtoPatterns on GoogleLoginRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoogleLoginRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoogleLoginRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoogleLoginRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _GoogleLoginRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoogleLoginRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _GoogleLoginRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_token')  String idToken, @JsonKey(name: 'client_type')  String clientType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoogleLoginRequestDto() when $default != null:
return $default(_that.idToken,_that.clientType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_token')  String idToken, @JsonKey(name: 'client_type')  String clientType)  $default,) {final _that = this;
switch (_that) {
case _GoogleLoginRequestDto():
return $default(_that.idToken,_that.clientType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_token')  String idToken, @JsonKey(name: 'client_type')  String clientType)?  $default,) {final _that = this;
switch (_that) {
case _GoogleLoginRequestDto() when $default != null:
return $default(_that.idToken,_that.clientType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoogleLoginRequestDto implements GoogleLoginRequestDto {
  const _GoogleLoginRequestDto({@JsonKey(name: 'id_token') required this.idToken, @JsonKey(name: 'client_type') this.clientType = 'mobile'});
  factory _GoogleLoginRequestDto.fromJson(Map<String, dynamic> json) => _$GoogleLoginRequestDtoFromJson(json);

@override@JsonKey(name: 'id_token') final  String idToken;
@override@JsonKey(name: 'client_type') final  String clientType;

/// Create a copy of GoogleLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoogleLoginRequestDtoCopyWith<_GoogleLoginRequestDto> get copyWith => __$GoogleLoginRequestDtoCopyWithImpl<_GoogleLoginRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoogleLoginRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoogleLoginRequestDto&&(identical(other.idToken, idToken) || other.idToken == idToken)&&(identical(other.clientType, clientType) || other.clientType == clientType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idToken,clientType);

@override
String toString() {
  return 'GoogleLoginRequestDto(idToken: $idToken, clientType: $clientType)';
}


}

/// @nodoc
abstract mixin class _$GoogleLoginRequestDtoCopyWith<$Res> implements $GoogleLoginRequestDtoCopyWith<$Res> {
  factory _$GoogleLoginRequestDtoCopyWith(_GoogleLoginRequestDto value, $Res Function(_GoogleLoginRequestDto) _then) = __$GoogleLoginRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_token') String idToken,@JsonKey(name: 'client_type') String clientType
});




}
/// @nodoc
class __$GoogleLoginRequestDtoCopyWithImpl<$Res>
    implements _$GoogleLoginRequestDtoCopyWith<$Res> {
  __$GoogleLoginRequestDtoCopyWithImpl(this._self, this._then);

  final _GoogleLoginRequestDto _self;
  final $Res Function(_GoogleLoginRequestDto) _then;

/// Create a copy of GoogleLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idToken = null,Object? clientType = null,}) {
  return _then(_GoogleLoginRequestDto(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
