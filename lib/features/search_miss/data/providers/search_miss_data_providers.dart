import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/search_miss_repository.dart';
import '../datasources/search_miss_remote_datasource.dart';
import '../repositories/search_miss_repository_impl.dart';

part 'search_miss_data_providers.g.dart';

@riverpod
SearchMissRemoteDatasource searchMissRemoteDatasource(Ref ref) =>
    SearchMissRemoteDatasource(ref.watch(dioProvider));

@riverpod
SearchMissRepository searchMissRepository(Ref ref) =>
    SearchMissRepositoryImpl(ref.watch(searchMissRemoteDatasourceProvider));
