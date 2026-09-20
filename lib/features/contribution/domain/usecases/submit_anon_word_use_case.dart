import 'package:fpdart/fpdart.dart';

import '../entities/submit_word_result.dart';
import '../failures/contribution_failure.dart';
import '../repositories/contribution_repository.dart';

class SubmitAnonWordUseCase {
  const SubmitAnonWordUseCase(this._repository);

  final ContributionRepository _repository;

  Future<Either<ContributionFailure, SubmitWordResult>> call(
    SubmitAnonWordParams params,
  ) {
    final lemma = params.lemma.trim();
    final dialectId = params.dialectId?.trim();
    final notes = params.notes?.trim();

    // Placeholder: definisi + terjemahan sentinel "-" + flag false
    // (API create-word.validator + add-meaning e2e).
    final isHaveDefinition = params.isHaveDefinition;
    final definition = isHaveDefinition ? params.definition.trim() : '-';
    final translations = isHaveDefinition
        ? params.translationTexts
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false)
        : const ['-'];

    final categoryIds = params.categoryIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final seenVariants = <String>{};
    final spellingVariants = params.spellingVariants
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.toLowerCase() != lemma.toLowerCase())
        .where((e) => seenVariants.add(e.toLowerCase()))
        .toList(growable: false);

    // Max 5 Form B per request (API); dedup lemma case-insensitive
    // (termasuk lemma induk).
    final seenRelated = <String>{lemma.toLowerCase()};
    final relatedWords = <SubmitWordRelation>[];
    for (final rel in params.relatedWords) {
      final relLemma = rel.lemma.trim();
      if (relLemma.isEmpty) continue;
      final key = relLemma.toLowerCase();
      if (!seenRelated.add(key)) continue;
      relatedWords.add(
        SubmitWordRelation(relationType: rel.relationType, lemma: relLemma),
      );
      if (relatedWords.length >= 5) break;
    }

    // Pastikan maksimal satu is_primary (mirror validator API).
    var sawPrimary = false;
    final images = <SubmitWordImage>[];
    for (final img in params.images) {
      final primary = img.isPrimary && !sawPrimary;
      if (primary) sawPrimary = true;
      images.add(
        SubmitWordImage(
          url: img.url,
          providerFileId: img.providerFileId,
          altText: img.altText,
          isPrimary: primary,
        ),
      );
    }
    if (images.isNotEmpty && !sawPrimary) {
      final first = images.first;
      images[0] = SubmitWordImage(
        url: first.url,
        providerFileId: first.providerFileId,
        altText: first.altText,
        isPrimary: true,
      );
    }

    return _repository.submitAnon(
      lemma: lemma,
      languageId: params.languageId.trim(),
      wordClassId: params.wordClassId.trim(),
      definition: definition,
      isHaveDefinition: isHaveDefinition,
      dialectId: (dialectId != null && dialectId.isNotEmpty) ? dialectId : null,
      translationTexts: translations,
      categoryIds: categoryIds,
      notes: (notes != null && notes.isNotEmpty) ? notes : null,
      spellingVariants: spellingVariants,
      relatedWords: relatedWords,
      translationLanguageId: params.translationLanguageId.trim(),
      images: images,
      searchMissId: params.searchMissId,
    );
  }
}

class SubmitAnonWordParams {
  const SubmitAnonWordParams({
    required this.lemma,
    required this.languageId,
    required this.wordClassId,
    required this.definition,
    required this.translationLanguageId,
    this.isHaveDefinition = true,
    this.dialectId,
    this.translationTexts = const [],
    this.categoryIds = const [],
    this.notes,
    this.spellingVariants = const [],
    this.relatedWords = const [],
    this.images = const [],
    this.searchMissId,
  });

  final String lemma;
  final String languageId;
  final String wordClassId;
  final String definition;
  final String translationLanguageId;
  final bool isHaveDefinition;
  final String? dialectId;
  final List<String> translationTexts;
  final List<String> categoryIds;
  final String? notes;
  final List<String> spellingVariants;
  final List<SubmitWordRelation> relatedWords;
  final List<SubmitWordImage> images;
  final String? searchMissId;
}
