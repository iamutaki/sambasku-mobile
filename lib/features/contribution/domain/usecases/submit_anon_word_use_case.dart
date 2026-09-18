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
    final definition = params.definition.trim();
    final dialectId = params.dialectId?.trim();
    final notes = params.notes?.trim();

    // Bersihkan translation teks: hapus spasi berlebih + buang yang kosong.
    // Backend mewajibkan MINIMAL 1 translation (VALIDATION_ERROR nanti).
    final translations = params.translationTexts
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final categoryIds = params.categoryIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    return _repository.submitAnon(
      lemma: lemma,
      languageId: params.languageId.trim(),
      wordClassId: params.wordClassId.trim(),
      definition: definition,
      dialectId: (dialectId != null && dialectId.isNotEmpty) ? dialectId : null,
      translationTexts: translations,
      categoryIds: categoryIds,
      notes: (notes != null && notes.isNotEmpty) ? notes : null,
    );
  }
}

/// Parameter untuk `SubmitAnonWordUseCase.call()`.
///
/// - `translationTexts`: daftar terjemahan (min 1 sesuai spec 01-api-tambah-kata).
/// - `categoryIds`: list ULID kategori (opsional, default kosong).
/// - `dialectId` & `notes` opsional (bisa null / string kosong).
class SubmitAnonWordParams {
  const SubmitAnonWordParams({
    required this.lemma,
    required this.languageId,
    required this.wordClassId,
    required this.definition,
    this.dialectId,
    this.translationTexts = const [],
    this.categoryIds = const [],
    this.notes,
  });

  final String lemma;
  final String languageId;
  final String wordClassId;
  final String definition;
  final String? dialectId;
  final List<String> translationTexts;
  final List<String> categoryIds;
  final String? notes;
}
