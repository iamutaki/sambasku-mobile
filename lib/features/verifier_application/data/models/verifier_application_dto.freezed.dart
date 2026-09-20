// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verifier_application_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocialLinkDto {

 String get platform; String get url;
/// Create a copy of SocialLinkDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialLinkDtoCopyWith<SocialLinkDto> get copyWith => _$SocialLinkDtoCopyWithImpl<SocialLinkDto>(this as SocialLinkDto, _$identity);

  /// Serializes this SocialLinkDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialLinkDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,url);

@override
String toString() {
  return 'SocialLinkDto(platform: $platform, url: $url)';
}


}

/// @nodoc
abstract mixin class $SocialLinkDtoCopyWith<$Res>  {
  factory $SocialLinkDtoCopyWith(SocialLinkDto value, $Res Function(SocialLinkDto) _then) = _$SocialLinkDtoCopyWithImpl;
@useResult
$Res call({
 String platform, String url
});




}
/// @nodoc
class _$SocialLinkDtoCopyWithImpl<$Res>
    implements $SocialLinkDtoCopyWith<$Res> {
  _$SocialLinkDtoCopyWithImpl(this._self, this._then);

  final SocialLinkDto _self;
  final $Res Function(SocialLinkDto) _then;

/// Create a copy of SocialLinkDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? url = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialLinkDto].
extension SocialLinkDtoPatterns on SocialLinkDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialLinkDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialLinkDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialLinkDto value)  $default,){
final _that = this;
switch (_that) {
case _SocialLinkDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialLinkDto value)?  $default,){
final _that = this;
switch (_that) {
case _SocialLinkDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String platform,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialLinkDto() when $default != null:
return $default(_that.platform,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String platform,  String url)  $default,) {final _that = this;
switch (_that) {
case _SocialLinkDto():
return $default(_that.platform,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String platform,  String url)?  $default,) {final _that = this;
switch (_that) {
case _SocialLinkDto() when $default != null:
return $default(_that.platform,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialLinkDto implements SocialLinkDto {
  const _SocialLinkDto({required this.platform, required this.url});
  factory _SocialLinkDto.fromJson(Map<String, dynamic> json) => _$SocialLinkDtoFromJson(json);

@override final  String platform;
@override final  String url;

/// Create a copy of SocialLinkDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialLinkDtoCopyWith<_SocialLinkDto> get copyWith => __$SocialLinkDtoCopyWithImpl<_SocialLinkDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialLinkDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialLinkDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,url);

@override
String toString() {
  return 'SocialLinkDto(platform: $platform, url: $url)';
}


}

/// @nodoc
abstract mixin class _$SocialLinkDtoCopyWith<$Res> implements $SocialLinkDtoCopyWith<$Res> {
  factory _$SocialLinkDtoCopyWith(_SocialLinkDto value, $Res Function(_SocialLinkDto) _then) = __$SocialLinkDtoCopyWithImpl;
@override @useResult
$Res call({
 String platform, String url
});




}
/// @nodoc
class __$SocialLinkDtoCopyWithImpl<$Res>
    implements _$SocialLinkDtoCopyWith<$Res> {
  __$SocialLinkDtoCopyWithImpl(this._self, this._then);

  final _SocialLinkDto _self;
  final $Res Function(_SocialLinkDto) _then;

/// Create a copy of SocialLinkDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? url = null,}) {
  return _then(_SocialLinkDto(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VerifierApplicationDto {

 String get id; String get status; String get phone; String get address;@JsonKey(name: 'social_links') List<SocialLinkDto> get socialLinks;@JsonKey(name: 'admin_comment') String? get adminComment;@JsonKey(name: 'reviewed_at') String? get reviewedAt;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of VerifierApplicationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifierApplicationDtoCopyWith<VerifierApplicationDto> get copyWith => _$VerifierApplicationDtoCopyWithImpl<VerifierApplicationDto>(this as VerifierApplicationDto, _$identity);

  /// Serializes this VerifierApplicationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifierApplicationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other.socialLinks, socialLinks)&&(identical(other.adminComment, adminComment) || other.adminComment == adminComment)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,phone,address,const DeepCollectionEquality().hash(socialLinks),adminComment,reviewedAt,createdAt,updatedAt);

@override
String toString() {
  return 'VerifierApplicationDto(id: $id, status: $status, phone: $phone, address: $address, socialLinks: $socialLinks, adminComment: $adminComment, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $VerifierApplicationDtoCopyWith<$Res>  {
  factory $VerifierApplicationDtoCopyWith(VerifierApplicationDto value, $Res Function(VerifierApplicationDto) _then) = _$VerifierApplicationDtoCopyWithImpl;
@useResult
$Res call({
 String id, String status, String phone, String address,@JsonKey(name: 'social_links') List<SocialLinkDto> socialLinks,@JsonKey(name: 'admin_comment') String? adminComment,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$VerifierApplicationDtoCopyWithImpl<$Res>
    implements $VerifierApplicationDtoCopyWith<$Res> {
  _$VerifierApplicationDtoCopyWithImpl(this._self, this._then);

  final VerifierApplicationDto _self;
  final $Res Function(VerifierApplicationDto) _then;

/// Create a copy of VerifierApplicationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? phone = null,Object? address = null,Object? socialLinks = null,Object? adminComment = freezed,Object? reviewedAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self.socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as List<SocialLinkDto>,adminComment: freezed == adminComment ? _self.adminComment : adminComment // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifierApplicationDto].
extension VerifierApplicationDtoPatterns on VerifierApplicationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifierApplicationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifierApplicationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifierApplicationDto value)  $default,){
final _that = this;
switch (_that) {
case _VerifierApplicationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifierApplicationDto value)?  $default,){
final _that = this;
switch (_that) {
case _VerifierApplicationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks, @JsonKey(name: 'admin_comment')  String? adminComment, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifierApplicationDto() when $default != null:
return $default(_that.id,_that.status,_that.phone,_that.address,_that.socialLinks,_that.adminComment,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks, @JsonKey(name: 'admin_comment')  String? adminComment, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _VerifierApplicationDto():
return $default(_that.id,_that.status,_that.phone,_that.address,_that.socialLinks,_that.adminComment,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks, @JsonKey(name: 'admin_comment')  String? adminComment, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _VerifierApplicationDto() when $default != null:
return $default(_that.id,_that.status,_that.phone,_that.address,_that.socialLinks,_that.adminComment,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifierApplicationDto implements VerifierApplicationDto {
  const _VerifierApplicationDto({required this.id, required this.status, required this.phone, required this.address, @JsonKey(name: 'social_links') required final  List<SocialLinkDto> socialLinks, @JsonKey(name: 'admin_comment') this.adminComment, @JsonKey(name: 'reviewed_at') this.reviewedAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _socialLinks = socialLinks;
  factory _VerifierApplicationDto.fromJson(Map<String, dynamic> json) => _$VerifierApplicationDtoFromJson(json);

@override final  String id;
@override final  String status;
@override final  String phone;
@override final  String address;
 final  List<SocialLinkDto> _socialLinks;
@override@JsonKey(name: 'social_links') List<SocialLinkDto> get socialLinks {
  if (_socialLinks is EqualUnmodifiableListView) return _socialLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_socialLinks);
}

@override@JsonKey(name: 'admin_comment') final  String? adminComment;
@override@JsonKey(name: 'reviewed_at') final  String? reviewedAt;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of VerifierApplicationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifierApplicationDtoCopyWith<_VerifierApplicationDto> get copyWith => __$VerifierApplicationDtoCopyWithImpl<_VerifierApplicationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifierApplicationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifierApplicationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other._socialLinks, _socialLinks)&&(identical(other.adminComment, adminComment) || other.adminComment == adminComment)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,phone,address,const DeepCollectionEquality().hash(_socialLinks),adminComment,reviewedAt,createdAt,updatedAt);

@override
String toString() {
  return 'VerifierApplicationDto(id: $id, status: $status, phone: $phone, address: $address, socialLinks: $socialLinks, adminComment: $adminComment, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VerifierApplicationDtoCopyWith<$Res> implements $VerifierApplicationDtoCopyWith<$Res> {
  factory _$VerifierApplicationDtoCopyWith(_VerifierApplicationDto value, $Res Function(_VerifierApplicationDto) _then) = __$VerifierApplicationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, String phone, String address,@JsonKey(name: 'social_links') List<SocialLinkDto> socialLinks,@JsonKey(name: 'admin_comment') String? adminComment,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$VerifierApplicationDtoCopyWithImpl<$Res>
    implements _$VerifierApplicationDtoCopyWith<$Res> {
  __$VerifierApplicationDtoCopyWithImpl(this._self, this._then);

  final _VerifierApplicationDto _self;
  final $Res Function(_VerifierApplicationDto) _then;

/// Create a copy of VerifierApplicationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? phone = null,Object? address = null,Object? socialLinks = null,Object? adminComment = freezed,Object? reviewedAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_VerifierApplicationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self._socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as List<SocialLinkDto>,adminComment: freezed == adminComment ? _self.adminComment : adminComment // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SubmitVerifierApplicationRequestDto {

 String get phone; String get address;@JsonKey(name: 'social_links') List<SocialLinkDto> get socialLinks;
/// Create a copy of SubmitVerifierApplicationRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitVerifierApplicationRequestDtoCopyWith<SubmitVerifierApplicationRequestDto> get copyWith => _$SubmitVerifierApplicationRequestDtoCopyWithImpl<SubmitVerifierApplicationRequestDto>(this as SubmitVerifierApplicationRequestDto, _$identity);

  /// Serializes this SubmitVerifierApplicationRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitVerifierApplicationRequestDto&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other.socialLinks, socialLinks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,address,const DeepCollectionEquality().hash(socialLinks));

@override
String toString() {
  return 'SubmitVerifierApplicationRequestDto(phone: $phone, address: $address, socialLinks: $socialLinks)';
}


}

/// @nodoc
abstract mixin class $SubmitVerifierApplicationRequestDtoCopyWith<$Res>  {
  factory $SubmitVerifierApplicationRequestDtoCopyWith(SubmitVerifierApplicationRequestDto value, $Res Function(SubmitVerifierApplicationRequestDto) _then) = _$SubmitVerifierApplicationRequestDtoCopyWithImpl;
@useResult
$Res call({
 String phone, String address,@JsonKey(name: 'social_links') List<SocialLinkDto> socialLinks
});




}
/// @nodoc
class _$SubmitVerifierApplicationRequestDtoCopyWithImpl<$Res>
    implements $SubmitVerifierApplicationRequestDtoCopyWith<$Res> {
  _$SubmitVerifierApplicationRequestDtoCopyWithImpl(this._self, this._then);

  final SubmitVerifierApplicationRequestDto _self;
  final $Res Function(SubmitVerifierApplicationRequestDto) _then;

/// Create a copy of SubmitVerifierApplicationRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phone = null,Object? address = null,Object? socialLinks = null,}) {
  return _then(_self.copyWith(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self.socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as List<SocialLinkDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [SubmitVerifierApplicationRequestDto].
extension SubmitVerifierApplicationRequestDtoPatterns on SubmitVerifierApplicationRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmitVerifierApplicationRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmitVerifierApplicationRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmitVerifierApplicationRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto() when $default != null:
return $default(_that.phone,_that.address,_that.socialLinks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks)  $default,) {final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto():
return $default(_that.phone,_that.address,_that.socialLinks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks)?  $default,) {final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto() when $default != null:
return $default(_that.phone,_that.address,_that.socialLinks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubmitVerifierApplicationRequestDto implements SubmitVerifierApplicationRequestDto {
  const _SubmitVerifierApplicationRequestDto({required this.phone, required this.address, @JsonKey(name: 'social_links') required final  List<SocialLinkDto> socialLinks}): _socialLinks = socialLinks;
  factory _SubmitVerifierApplicationRequestDto.fromJson(Map<String, dynamic> json) => _$SubmitVerifierApplicationRequestDtoFromJson(json);

@override final  String phone;
@override final  String address;
 final  List<SocialLinkDto> _socialLinks;
@override@JsonKey(name: 'social_links') List<SocialLinkDto> get socialLinks {
  if (_socialLinks is EqualUnmodifiableListView) return _socialLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_socialLinks);
}


/// Create a copy of SubmitVerifierApplicationRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmitVerifierApplicationRequestDtoCopyWith<_SubmitVerifierApplicationRequestDto> get copyWith => __$SubmitVerifierApplicationRequestDtoCopyWithImpl<_SubmitVerifierApplicationRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubmitVerifierApplicationRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitVerifierApplicationRequestDto&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other._socialLinks, _socialLinks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,address,const DeepCollectionEquality().hash(_socialLinks));

@override
String toString() {
  return 'SubmitVerifierApplicationRequestDto(phone: $phone, address: $address, socialLinks: $socialLinks)';
}


}

/// @nodoc
abstract mixin class _$SubmitVerifierApplicationRequestDtoCopyWith<$Res> implements $SubmitVerifierApplicationRequestDtoCopyWith<$Res> {
  factory _$SubmitVerifierApplicationRequestDtoCopyWith(_SubmitVerifierApplicationRequestDto value, $Res Function(_SubmitVerifierApplicationRequestDto) _then) = __$SubmitVerifierApplicationRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String phone, String address,@JsonKey(name: 'social_links') List<SocialLinkDto> socialLinks
});




}
/// @nodoc
class __$SubmitVerifierApplicationRequestDtoCopyWithImpl<$Res>
    implements _$SubmitVerifierApplicationRequestDtoCopyWith<$Res> {
  __$SubmitVerifierApplicationRequestDtoCopyWithImpl(this._self, this._then);

  final _SubmitVerifierApplicationRequestDto _self;
  final $Res Function(_SubmitVerifierApplicationRequestDto) _then;

/// Create a copy of SubmitVerifierApplicationRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phone = null,Object? address = null,Object? socialLinks = null,}) {
  return _then(_SubmitVerifierApplicationRequestDto(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self._socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as List<SocialLinkDto>,
  ));
}


}

// dart format on
