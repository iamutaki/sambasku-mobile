import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/auth/data/models/login_request_dto.dart';

void main() {
  test('LoginRequestDto.toJson memakai client_type (snake_case API)', () {
    const dto = LoginRequestDto(
      email: 'budi@test.com',
      password: 'Password123',
    );

    expect(dto.toJson(), {
      'email': 'budi@test.com',
      'password': 'Password123',
      'client_type': 'mobile',
    });
  });

  test('RefreshRequestDto.toJson memakai refresh_token snake_case', () {
    const dto = RefreshRequestDto(refreshToken: 'abc');

    expect(dto.toJson(), {
      'refresh_token': 'abc',
      'client_type': 'mobile',
    });
  });
}
