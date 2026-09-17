import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../repositories/auth_repository_impl.dart';

part 'auth_data_providers.g.dart';

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) =>
    AuthRemoteDatasource(ref.watch(dioProvider));

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  ref.watch(authRemoteDatasourceProvider),
  ref.watch(authTokenStorageProvider),
);
