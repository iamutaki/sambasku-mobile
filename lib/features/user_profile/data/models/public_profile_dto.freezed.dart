// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicProfileDto {

 String get username; String get role;@JsonKey(name: 'is_verifier') bool get isVerifier;@JsonKey(name: 'joined_at') String get joinedAt; PublicProfileStatsDto get stats;
/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicProfileDtoCopyWith<PublicProfileDto> get copyWith => _$PublicProfileDtoCopyWithImpl<PublicProfileDto>(this as PublicProfileDto, _$identity);

  /// Serializes this PublicProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicProfileDto&&(identical(other.username, username) || other.username == username)&&(identical(other.role, role) || other.role == role)&&(identical(other.isVerifier, isVerifier) || other.isVerifier == isVerifier)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,role,isVerifier,joinedAt,stats);

@override
String toString() {
  return 'PublicProfileDto(username: $username, role: $role, isVerifier: $isVerifier, joinedAt: $joinedAt, stats: $stats)';
}


}

/// @nodoc
abstract mixin class $PublicProfileDtoCopyWith<$Res>  {
  factory $PublicProfileDtoCopyWith(PublicProfileDto value, $Res Function(PublicProfileDto) _then) = _$PublicProfileDtoCopyWithImpl;
@useResult
$Res call({
 String username, String role,@JsonKey(name: 'is_verifier') bool isVerifier,@JsonKey(name: 'joined_at') String joinedAt, PublicProfileStatsDto stats
});


$PublicProfileStatsDtoCopyWith<$Res> get stats;

}
/// @nodoc
class _$PublicProfileDtoCopyWithImpl<$Res>
    implements $PublicProfileDtoCopyWith<$Res> {
  _$PublicProfileDtoCopyWithImpl(this._self, this._then);

  final PublicProfileDto _self;
  final $Res Function(PublicProfileDto) _then;

/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? role = null,Object? isVerifier = null,Object? joinedAt = null,Object? stats = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isVerifier: null == isVerifier ? _self.isVerifier : isVerifier // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PublicProfileStatsDto,
  ));
}
/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicProfileStatsDtoCopyWith<$Res> get stats {
  
  return $PublicProfileStatsDtoCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [PublicProfileDto].
extension PublicProfileDtoPatterns on PublicProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _PublicProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _PublicProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String role, @JsonKey(name: 'is_verifier')  bool isVerifier, @JsonKey(name: 'joined_at')  String joinedAt,  PublicProfileStatsDto stats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicProfileDto() when $default != null:
return $default(_that.username,_that.role,_that.isVerifier,_that.joinedAt,_that.stats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String role, @JsonKey(name: 'is_verifier')  bool isVerifier, @JsonKey(name: 'joined_at')  String joinedAt,  PublicProfileStatsDto stats)  $default,) {final _that = this;
switch (_that) {
case _PublicProfileDto():
return $default(_that.username,_that.role,_that.isVerifier,_that.joinedAt,_that.stats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String role, @JsonKey(name: 'is_verifier')  bool isVerifier, @JsonKey(name: 'joined_at')  String joinedAt,  PublicProfileStatsDto stats)?  $default,) {final _that = this;
switch (_that) {
case _PublicProfileDto() when $default != null:
return $default(_that.username,_that.role,_that.isVerifier,_that.joinedAt,_that.stats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicProfileDto implements PublicProfileDto {
  const _PublicProfileDto({required this.username, required this.role, @JsonKey(name: 'is_verifier') this.isVerifier = false, @JsonKey(name: 'joined_at') required this.joinedAt, required this.stats});
  factory _PublicProfileDto.fromJson(Map<String, dynamic> json) => _$PublicProfileDtoFromJson(json);

@override final  String username;
@override final  String role;
@override@JsonKey(name: 'is_verifier') final  bool isVerifier;
@override@JsonKey(name: 'joined_at') final  String joinedAt;
@override final  PublicProfileStatsDto stats;

/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicProfileDtoCopyWith<_PublicProfileDto> get copyWith => __$PublicProfileDtoCopyWithImpl<_PublicProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicProfileDto&&(identical(other.username, username) || other.username == username)&&(identical(other.role, role) || other.role == role)&&(identical(other.isVerifier, isVerifier) || other.isVerifier == isVerifier)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,role,isVerifier,joinedAt,stats);

@override
String toString() {
  return 'PublicProfileDto(username: $username, role: $role, isVerifier: $isVerifier, joinedAt: $joinedAt, stats: $stats)';
}


}

/// @nodoc
abstract mixin class _$PublicProfileDtoCopyWith<$Res> implements $PublicProfileDtoCopyWith<$Res> {
  factory _$PublicProfileDtoCopyWith(_PublicProfileDto value, $Res Function(_PublicProfileDto) _then) = __$PublicProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String username, String role,@JsonKey(name: 'is_verifier') bool isVerifier,@JsonKey(name: 'joined_at') String joinedAt, PublicProfileStatsDto stats
});


@override $PublicProfileStatsDtoCopyWith<$Res> get stats;

}
/// @nodoc
class __$PublicProfileDtoCopyWithImpl<$Res>
    implements _$PublicProfileDtoCopyWith<$Res> {
  __$PublicProfileDtoCopyWithImpl(this._self, this._then);

  final _PublicProfileDto _self;
  final $Res Function(_PublicProfileDto) _then;

/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? role = null,Object? isVerifier = null,Object? joinedAt = null,Object? stats = null,}) {
  return _then(_PublicProfileDto(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isVerifier: null == isVerifier ? _self.isVerifier : isVerifier // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PublicProfileStatsDto,
  ));
}

/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicProfileStatsDtoCopyWith<$Res> get stats {
  
  return $PublicProfileStatsDtoCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// @nodoc
mixin _$PublicProfileStatsDto {

@JsonKey(name: 'contributions_approved') int get contributionsApproved;@JsonKey(name: 'verifications_done') int get verificationsDone;
/// Create a copy of PublicProfileStatsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicProfileStatsDtoCopyWith<PublicProfileStatsDto> get copyWith => _$PublicProfileStatsDtoCopyWithImpl<PublicProfileStatsDto>(this as PublicProfileStatsDto, _$identity);

  /// Serializes this PublicProfileStatsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicProfileStatsDto&&(identical(other.contributionsApproved, contributionsApproved) || other.contributionsApproved == contributionsApproved)&&(identical(other.verificationsDone, verificationsDone) || other.verificationsDone == verificationsDone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contributionsApproved,verificationsDone);

@override
String toString() {
  return 'PublicProfileStatsDto(contributionsApproved: $contributionsApproved, verificationsDone: $verificationsDone)';
}


}

/// @nodoc
abstract mixin class $PublicProfileStatsDtoCopyWith<$Res>  {
  factory $PublicProfileStatsDtoCopyWith(PublicProfileStatsDto value, $Res Function(PublicProfileStatsDto) _then) = _$PublicProfileStatsDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'contributions_approved') int contributionsApproved,@JsonKey(name: 'verifications_done') int verificationsDone
});




}
/// @nodoc
class _$PublicProfileStatsDtoCopyWithImpl<$Res>
    implements $PublicProfileStatsDtoCopyWith<$Res> {
  _$PublicProfileStatsDtoCopyWithImpl(this._self, this._then);

  final PublicProfileStatsDto _self;
  final $Res Function(PublicProfileStatsDto) _then;

/// Create a copy of PublicProfileStatsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contributionsApproved = null,Object? verificationsDone = null,}) {
  return _then(_self.copyWith(
contributionsApproved: null == contributionsApproved ? _self.contributionsApproved : contributionsApproved // ignore: cast_nullable_to_non_nullable
as int,verificationsDone: null == verificationsDone ? _self.verificationsDone : verificationsDone // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicProfileStatsDto].
extension PublicProfileStatsDtoPatterns on PublicProfileStatsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicProfileStatsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicProfileStatsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicProfileStatsDto value)  $default,){
final _that = this;
switch (_that) {
case _PublicProfileStatsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicProfileStatsDto value)?  $default,){
final _that = this;
switch (_that) {
case _PublicProfileStatsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'contributions_approved')  int contributionsApproved, @JsonKey(name: 'verifications_done')  int verificationsDone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicProfileStatsDto() when $default != null:
return $default(_that.contributionsApproved,_that.verificationsDone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'contributions_approved')  int contributionsApproved, @JsonKey(name: 'verifications_done')  int verificationsDone)  $default,) {final _that = this;
switch (_that) {
case _PublicProfileStatsDto():
return $default(_that.contributionsApproved,_that.verificationsDone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'contributions_approved')  int contributionsApproved, @JsonKey(name: 'verifications_done')  int verificationsDone)?  $default,) {final _that = this;
switch (_that) {
case _PublicProfileStatsDto() when $default != null:
return $default(_that.contributionsApproved,_that.verificationsDone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicProfileStatsDto implements PublicProfileStatsDto {
  const _PublicProfileStatsDto({@JsonKey(name: 'contributions_approved') this.contributionsApproved = 0, @JsonKey(name: 'verifications_done') this.verificationsDone = 0});
  factory _PublicProfileStatsDto.fromJson(Map<String, dynamic> json) => _$PublicProfileStatsDtoFromJson(json);

@override@JsonKey(name: 'contributions_approved') final  int contributionsApproved;
@override@JsonKey(name: 'verifications_done') final  int verificationsDone;

/// Create a copy of PublicProfileStatsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicProfileStatsDtoCopyWith<_PublicProfileStatsDto> get copyWith => __$PublicProfileStatsDtoCopyWithImpl<_PublicProfileStatsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicProfileStatsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicProfileStatsDto&&(identical(other.contributionsApproved, contributionsApproved) || other.contributionsApproved == contributionsApproved)&&(identical(other.verificationsDone, verificationsDone) || other.verificationsDone == verificationsDone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contributionsApproved,verificationsDone);

@override
String toString() {
  return 'PublicProfileStatsDto(contributionsApproved: $contributionsApproved, verificationsDone: $verificationsDone)';
}


}

/// @nodoc
abstract mixin class _$PublicProfileStatsDtoCopyWith<$Res> implements $PublicProfileStatsDtoCopyWith<$Res> {
  factory _$PublicProfileStatsDtoCopyWith(_PublicProfileStatsDto value, $Res Function(_PublicProfileStatsDto) _then) = __$PublicProfileStatsDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'contributions_approved') int contributionsApproved,@JsonKey(name: 'verifications_done') int verificationsDone
});




}
/// @nodoc
class __$PublicProfileStatsDtoCopyWithImpl<$Res>
    implements _$PublicProfileStatsDtoCopyWith<$Res> {
  __$PublicProfileStatsDtoCopyWithImpl(this._self, this._then);

  final _PublicProfileStatsDto _self;
  final $Res Function(_PublicProfileStatsDto) _then;

/// Create a copy of PublicProfileStatsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contributionsApproved = null,Object? verificationsDone = null,}) {
  return _then(_PublicProfileStatsDto(
contributionsApproved: null == contributionsApproved ? _self.contributionsApproved : contributionsApproved // ignore: cast_nullable_to_non_nullable
as int,verificationsDone: null == verificationsDone ? _self.verificationsDone : verificationsDone // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
