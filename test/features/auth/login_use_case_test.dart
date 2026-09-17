import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/auth/domain/usecases/login_use_case.dart';

/// Usecase wajib unit test (mobile-base-stack Section 10):
/// trim email + teruskan hasil Either apa adanya.
class _FakeRepo implements AuthRepository {
  _FakeRepo(this.result);

  final Either<AuthFailure, AuthSession> result;
  String? receivedEmail;

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    receivedEmail = email;
    return result;
  }
}

void main() {
  const session = AuthSession(userId: '01U', username: 'budi', role: 'contributor');

  test('sukses - email di-trim sebelum kirim', () async {
    final repo = _FakeRepo(Either.right(session));
    final usecase = LoginUseCase(repo);

    final result = await usecase(
      const LoginParams(email: '  budi@test.com  ', password: 'Password123'),
    );

    expect(repo.receivedEmail, 'budi@test.com');
    expect(result.getRight().toNullable()?.username, 'budi');
  });

  test('gagal - failure diteruskan tanpa diubah', () async {
    final repo = _FakeRepo(
      Either.left(const AuthFailure('Email atau password salah',
          errorCode: 'INVALID_CREDENTIALS')),
    );
    final usecase = LoginUseCase(repo);

    final result = await usecase(
      const LoginParams(email: 'budi@test.com', password: 'salah'),
    );

    final failure = result.getLeft().toNullable();
    expect(failure?.message, 'Email atau password salah');
    expect(failure?.errorCode, 'INVALID_CREDENTIALS');
  });
}
