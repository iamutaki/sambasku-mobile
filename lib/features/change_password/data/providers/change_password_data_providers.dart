import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/change_password_repository.dart';
import '../datasources/change_password_remote_datasource.dart';
import '../repositories/change_password_repository_impl.dart';

part 'change_password_data_providers.g.dart';

@riverpod
ChangePasswordRemoteDatasource changePasswordRemoteDatasource(Ref ref) =>
    ChangePasswordRemoteDatasource(ref.watch(dioProvider));

@riverpod
ChangePasswordRepository changePasswordRepository(Ref ref) =>
    ChangePasswordRepositoryImpl(ref.watch(changePasswordRemoteDatasourceProvider));
