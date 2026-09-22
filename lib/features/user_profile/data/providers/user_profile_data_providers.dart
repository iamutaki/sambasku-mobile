import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../repositories/user_profile_repository_impl.dart';

part 'user_profile_data_providers.g.dart';

@riverpod
UserProfileRemoteDatasource userProfileRemoteDatasource(Ref ref) =>
    UserProfileRemoteDatasource(ref.watch(dioProvider));

@riverpod
UserProfileRepository userProfileRepository(Ref ref) =>
    UserProfileRepositoryImpl(ref.watch(userProfileRemoteDatasourceProvider));
