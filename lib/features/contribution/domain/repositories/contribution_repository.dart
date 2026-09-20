import 'package:fpdart/fpdart.dart';

import '../entities/submit_word_result.dart';
import '../failures/contribution_failure.dart';

/// Satu gambar siap dikirim (hasil upload ImageKit).
class SubmitWordImage {
  const SubmitWordImage({
    required this.url,
    required this.providerFileId,
    this.altText,
    this.isPrimary = false,
  });

  final String url;
  final String providerFileId;
  final String? altText;
  final bool isPrimary;
}

/// Relasi inline (Form B) - sinonim/antonim lemma baru ikut makna induk.
class SubmitWordRelation {
  const SubmitWordRelation({
    required this.relationType,
    required this.lemma,
  });

  /// `synonym` | `antonym`
  final String relationType;
  final String lemma;
}

/// Kontrak repository submit kata.
///
/// Method `submitAnon` = endpoint publik `POST /api/v1/contributions/words`
/// (tidak butuh Authorization header). Hasil selalu `pending_review`
/// (approval gate di backend). User anonim tidak bisa langsung tayang.
/// `images` opsional - hanya untuk user yang sudah upload via token.
abstract interface class ContributionRepository {
  Future<Either<ContributionFailure, SubmitWordResult>> submitAnon({
    required String lemma,
    required String languageId,
    required String wordClassId,
    required String definition,
    // false = placeholder "-" (docs: is_have_definition).
    bool isHaveDefinition = true,
    String? dialectId,
    required List<String> translationTexts,
    List<String> categoryIds = const [],
    String? notes,
    // Ejaan alternatif (variasi penulisan, docs/api/11) - dikirim sebagai
    // variants[] variant_type 'alternative'.
    List<String> spellingVariants = const [],
    // Sinonim/antonim inline Form B (docs/api/04).
    List<SubmitWordRelation> relatedWords = const [],
    // Bahasa target terjemahan = Indonesia (IDN), di-resolve dari page.
    required String translationLanguageId,
    List<SubmitWordImage> images = const [],
    String? searchMissId,
  });
}
