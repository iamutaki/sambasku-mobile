import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/network/auth_token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_dto.dart';
import '../models/logout_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDatasource, this._tokenStorage);

  final AuthRemoteDatasource _remoteDatasource;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDatasource.login(
        LoginRequestDto(email: email, password: password),
      );

      final payload = response.data;
      if (payload == null) {
        return Either.left(AuthFailure(
          response.message ?? 'Login gagal',
          errorCode: response.errorCode,
        ));
      }

      // varian mobile: refresh_token WAJIB di body (00-api-auth.md)
      final refreshToken = payload.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        return Either.left(const AuthFailure(
          'Login mobile tanpa refresh_token; cek client_type',
          errorCode: 'INTERNAL_ERROR',
        ));
      }

      await _tokenStorage.saveTokens(
        accessToken: payload.accessToken,
        refreshToken: refreshToken,
      );
      await _tokenStorage.saveSessionUser(
        username: payload.user.username,
        role: payload.user.role,
      );
      await _tokenStorage.setIsAuth(true);

      return Either.right(AuthSession(
        userId: payload.user.id,
        username: payload.user.username,
        role: payload.user.role,
      ));
    } on DioException catch (error) {
      return Either.left(AuthFailure(_mapDioError(error)));
    } catch (error) {
      return Either.left(AuthFailure(error.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _remoteDatasource.logout(
          LogoutRequestDto(refreshToken: refreshToken),
        );
      }
    } on DioException catch (_) {
      // revoke refresh bersifat best-effort (00-api-auth.md): offline/gagal
      // tetap lanjut clear sesi lokal - refresh token tak lagi dimiliki client
    } finally {
      await _tokenStorage.clearTokens();
    }
    return Either.right(null);
  }

  /// Baca envelope error dari body 4xx (error_code + message sudah
  /// ramah user dari backend - jangan ditimpa)
  String _mapDioError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'Koneksi lambat, coba lagi',
      DioExceptionType.connectionError => 'Tidak ada koneksi internet',
      _ => 'Terjadi kesalahan, coba lagi',
    };
  }
}
