import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/verifier_application_data_providers.dart';
import '../usecases/get_my_verifier_application_use_case.dart';
import '../usecases/submit_verifier_application_use_case.dart';

part 'verifier_application_domain_providers.g.dart';

@riverpod
GetMyVerifierApplicationUseCase getMyVerifierApplicationUseCase(Ref ref) =>
    GetMyVerifierApplicationUseCase(
      ref.watch(verifierApplicationRepositoryProvider),
    );

@riverpod
SubmitVerifierApplicationUseCase submitVerifierApplicationUseCase(Ref ref) =>
    SubmitVerifierApplicationUseCase(
      ref.watch(verifierApplicationRepositoryProvider),
    );
