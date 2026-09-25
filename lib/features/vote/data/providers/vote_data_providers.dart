import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/vote_repository.dart';
import '../datasources/vote_remote_datasource.dart';
import '../repositories/vote_repository_impl.dart';

part 'vote_data_providers.g.dart';

@riverpod
VoteRemoteDatasource voteRemoteDatasource(Ref ref) =>
    VoteRemoteDatasource(ref.watch(dioProvider));

@riverpod
VoteRepository voteRepository(Ref ref) => VoteRepositoryImpl(
      ref.watch(dioProvider),
      ref.watch(voteRemoteDatasourceProvider),
    );
