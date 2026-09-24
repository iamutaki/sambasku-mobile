import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/failures/linked_accounts_failure.dart';
import '../../domain/repositories/linked_accounts_repository.dart';
import '../datasources/linked_accounts_remote_datasource.dart';
import '../models/auth_providers_dto.dart';

class LinkedAccountsRepositoryImpl implements LinkedAccountsRepository {
  LinkedAccountsRepositoryImpl(this._remote);

  final LinkedAccountsRemoteDatasource _remote;

  @override
  Future<Either<LinkedAccountsFailure, bool>> isGoogleLinked() async {
    try {
      final response = await _remote.listProviders();
      if (response.success == false || response.data == null) {
        return Either.left(
          LinkedAccountsFailure(
            response.message ?? 'Gagal memuat status akun',
            errorCode: response.errorCode,
          ),
        );
      }
      final linked = response.data!.providers.any((p) => p.provider == 'google');
      return Either.right(linked);
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(LinkedAccountsFailure(error.toString()));
    }
  }

  @override
  Future<Either<LinkedAccountsFailure, void>> linkGoogle(String idToken) async {
    try {
      final response = await _remote.linkGoogle(
        GoogleLinkRequestDto(idToken: idToken),
      );
      if (response.success == false) {
        return Either.left(
          LinkedAccountsFailure(
            response.message ?? 'Gagal menghubungkan Google',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(null);
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(LinkedAccountsFailure(error.toString()));
    }
  }

  @override
  Future<Either<LinkedAccountsFailure, String>> unlinkGoogle() async {
    try {
      final response = await _remote.unlinkGoogle();
      if (response.success == false) {
        return Either.left(
          LinkedAccountsFailure(
            response.message ?? 'Gagal melepas Google',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(
        response.data?.message ?? 'Akun Google berhasil dilepas.',
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(LinkedAccountsFailure(error.toString()));
    }
  }

  LinkedAccountsFailure _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      final code = data['error_code'];
      if (message is String && message.isNotEmpty) {
        return LinkedAccountsFailure(
          message,
          errorCode: code is String ? code : null,
        );
      }
    }
    return LinkedAccountsFailure(switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Koneksi lambat, coba lagi',
      DioExceptionType.connectionError => 'Tidak ada koneksi internet',
      _ => 'Terjadi kesalahan, coba lagi',
    });
  }
}
