import 'package:fpdart/fpdart.dart';

import '../entities/verifier_application.dart';
import '../failures/verifier_application_failure.dart';
import '../repositories/verifier_application_repository.dart';

class SubmitVerifierApplicationParams {
  const SubmitVerifierApplicationParams({
    required this.phone,
    required this.address,
    required this.socialLinks,
    required this.isResubmit,
  });

  final String phone;
  final String address;
  final List<SocialLink> socialLinks;
  final bool isResubmit;
}

class SubmitVerifierApplicationUseCase {
  const SubmitVerifierApplicationUseCase(this._repository);

  final VerifierApplicationRepository _repository;

  Future<Either<VerifierApplicationFailure, VerifierApplication>> call(
    SubmitVerifierApplicationParams params,
  ) {
    if (params.isResubmit) {
      return _repository.resubmit(
        phone: params.phone,
        address: params.address,
        socialLinks: params.socialLinks,
      );
    }
    return _repository.submit(
      phone: params.phone,
      address: params.address,
      socialLinks: params.socialLinks,
    );
  }
}
