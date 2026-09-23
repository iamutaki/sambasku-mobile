import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_account_message_dto.freezed.dart';
part 'delete_account_message_dto.g.dart';

@freezed
abstract class DeleteAccountMessageDto with _$DeleteAccountMessageDto {
  const factory DeleteAccountMessageDto({required String message}) =
      _DeleteAccountMessageDto;

  factory DeleteAccountMessageDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountMessageDtoFromJson(json);
}
