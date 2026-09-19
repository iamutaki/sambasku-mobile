import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_response_dto.freezed.dart';
part 'message_response_dto.g.dart';

/// Payload `data` envelope generik `{ message }` (mis. change-password).
@freezed
abstract class MessageResponseDto with _$MessageResponseDto {
  const factory MessageResponseDto({required String message}) = _MessageResponseDto;

  factory MessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseDtoFromJson(json);
}
