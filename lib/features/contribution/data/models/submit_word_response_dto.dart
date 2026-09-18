import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_word_response_dto.freezed.dart';
part 'submit_word_response_dto.g.dart';

/// Body `data` dari response 201 POST /api/v1/contributions/words.
///
/// Selalu `{ word_id, status }`; untuk anonim status = `pending_review`
/// (approval gate di backend).
@freezed
abstract class SubmitWordResponseDto with _$SubmitWordResponseDto {
  const factory SubmitWordResponseDto({
    @JsonKey(name: 'word_id') required String wordId,
    required String status,
  }) = _SubmitWordResponseDto;

  factory SubmitWordResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubmitWordResponseDtoFromJson(json);
}