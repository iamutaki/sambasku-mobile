import 'package:fpdart/fpdart.dart';

import '../entities/verifier_application.dart';
import '../failures/verifier_application_failure.dart';
import '../repositories/verifier_application_repository.dart';

class GetMyVerifierApplicationUseCase {
  const GetMyVerifierApplicationUseCase(this._repository);

  final VerifierApplicationRepository _repository;

  Future<Either<VerifierApplicationFailure, VerifierApplication?>> call() =>
      _repository.getMine();
}
