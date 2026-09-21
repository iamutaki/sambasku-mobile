import 'package:freezed_annotation/freezed_annotation.dart';

part 'facebook_login_request_dto.freezed.dart';
part 'facebook_login_request_dto.g.dart';

@freezed
abstract class FacebookLoginRequestDto with _$FacebookLoginRequestDto {
  const factory FacebookLoginRequestDto({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'client_type') @Default('mobile') String clientType,
  }) = _FacebookLoginRequestDto;

  factory FacebookLoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$FacebookLoginRequestDtoFromJson(json);
}
