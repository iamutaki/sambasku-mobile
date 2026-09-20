import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/verifier_application_repository.dart';
import '../datasources/verifier_application_remote_datasource.dart';
import '../repositories/verifier_application_repository_impl.dart';

part 'verifier_application_data_providers.g.dart';

@riverpod
VerifierApplicationRemoteDatasource verifierApplicationRemoteDatasource(
  Ref ref,
) => VerifierApplicationRemoteDatasource(ref.watch(dioProvider));

@riverpod
VerifierApplicationRepository verifierApplicationRepository(Ref ref) =>
    VerifierApplicationRepositoryImpl(
      ref.watch(verifierApplicationRemoteDatasourceProvider),
    );
