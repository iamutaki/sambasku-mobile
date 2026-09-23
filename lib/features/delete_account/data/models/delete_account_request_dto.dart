import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_account_request_dto.freezed.dart';
part 'delete_account_request_dto.g.dart';

/// Body DELETE /api/v1/auth/account.
@freezed
abstract class DeleteAccountRequestDto with _$DeleteAccountRequestDto {
  const factory DeleteAccountRequestDto({
    @JsonKey(includeIfNull: false) String? password,
    required String confirmation,
  }) = _DeleteAccountRequestDto;

  factory DeleteAccountRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountRequestDtoFromJson(json);
}
