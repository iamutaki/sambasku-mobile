import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_word_image_dto.freezed.dart';
part 'create_word_image_dto.g.dart';

/// Item `images[]` body usul kata (docs/api/01 + 03).
@freezed
abstract class CreateWordImageDto with _$CreateWordImageDto {
  const factory CreateWordImageDto({
    required String url,
    @JsonKey(name: 'provider_file_id') required String providerFileId,
    @JsonKey(includeIfNull: false) String? sha,
    @JsonKey(name: 'alt_text', includeIfNull: false) String? altText,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
  }) = _CreateWordImageDto;

  factory CreateWordImageDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWordImageDtoFromJson(json);
}
