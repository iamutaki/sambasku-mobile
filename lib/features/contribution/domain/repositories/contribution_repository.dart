import 'package:fpdart/fpdart.dart';

import '../entities/submit_word_result.dart';
import '../failures/contribution_failure.dart';

/// Kontrak repository submit kata.
///
/// Method `submitAnon` = endpoint publik `POST /api/v1/contributions/words`
/// (tidak butuh Authorization header). Hasil selalu `pending_review`
/// (approval gate di backend). User anonim tidak bisa langsung tayang.
abstract interface class ContributionRepository {
  Future<Either<ContributionFailure, SubmitWordResult>> submitAnon({
    required String lemma,
    required String languageId,
    required String wordClassId,
    required String definition,
    String? dialectId,
    required List<String> translationTexts,
    List<String> categoryIds = const [],
    String? notes,
  });
}
