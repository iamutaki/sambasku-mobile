import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_comment_request_dto.freezed.dart';
part 'create_comment_request_dto.g.dart';

/// Body POST /api/v1/words/:wordId/comments - plain text 1..1000 char.
@freezed
abstract class CreateCommentRequestDto with _$CreateCommentRequestDto {
  const factory CreateCommentRequestDto({required String body}) =
      _CreateCommentRequestDto;

  factory CreateCommentRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentRequestDtoFromJson(json);
}