import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/auth/data/models/reset_password_dto.dart';

void main() {
  test('ForgotPasswordRequestDto.toJson memakai email', () {
    const dto = ForgotPasswordRequestDto(email: 'budi@test.com');
    expect(dto.toJson(), {'email': 'budi@test.com'});
  });

  test('ResetPasswordRequestDto.toJson memakai new_password snake_case', () {
    const dto = ResetPasswordRequestDto(
      token: 'tok',
      newPassword: 'Password123',
    );
    expect(dto.toJson(), {'token': 'tok', 'new_password': 'Password123'});
  });

  test('ResetPasswordRequestDto.toJson jalur OTP email+code', () {
    const dto = ResetPasswordRequestDto(
      email: 'budi@test.com',
      code: '482917',
      newPassword: 'Password123',
    );
    expect(dto.toJson(), {
      'email': 'budi@test.com',
      'code': '482917',
      'new_password': 'Password123',
    });
  });
}
