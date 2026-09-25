import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/linked_accounts_repository.dart';
import '../datasources/linked_accounts_remote_datasource.dart';
import '../repositories/linked_accounts_repository_impl.dart';

part 'linked_accounts_data_providers.g.dart';

@riverpod
LinkedAccountsRemoteDatasource linkedAccountsRemoteDatasource(Ref ref) =>
    LinkedAccountsRemoteDatasource(ref.watch(dioProvider));

@riverpod
LinkedAccountsRepository linkedAccountsRepository(Ref ref) =>
    LinkedAccountsRepositoryImpl(
      ref.watch(linkedAccountsRemoteDatasourceProvider),
    );
