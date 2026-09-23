import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/delete_account_repository.dart';
import '../datasources/delete_account_remote_datasource.dart';
import '../repositories/delete_account_repository_impl.dart';

part 'delete_account_data_providers.g.dart';

@riverpod
DeleteAccountRemoteDatasource deleteAccountRemoteDatasource(Ref ref) =>
    DeleteAccountRemoteDatasource(ref.watch(dioProvider));

@riverpod
DeleteAccountRepository deleteAccountRepository(Ref ref) =>
    DeleteAccountRepositoryImpl(ref.watch(deleteAccountRemoteDatasourceProvider));
