import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../datasources/contribution_remote_datasource.dart';
import '../repositories/contribution_repository_impl.dart';

part 'contribution_data_providers.g.dart';

@riverpod
ContributionRemoteDatasource contributionRemoteDatasource(Ref ref) =>
    ContributionRemoteDatasource(ref.watch(dioProvider));

@riverpod
ContributionRepository contributionRepository(Ref ref) =>
    ContributionRepositoryImpl(ref.watch(contributionRemoteDatasourceProvider));
