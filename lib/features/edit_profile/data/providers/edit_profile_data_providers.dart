import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/edit_profile_repository.dart';
import '../datasources/edit_profile_remote_datasource.dart';
import '../repositories/edit_profile_repository_impl.dart';

part 'edit_profile_data_providers.g.dart';

@riverpod
EditProfileRemoteDatasource editProfileRemoteDatasource(Ref ref) =>
    EditProfileRemoteDatasource(ref.watch(dioProvider));

@riverpod
EditProfileRepository editProfileRepository(Ref ref) =>
    EditProfileRepositoryImpl(ref.watch(editProfileRemoteDatasourceProvider));
