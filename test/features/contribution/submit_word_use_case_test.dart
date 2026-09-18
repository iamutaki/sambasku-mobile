import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/contribution/domain/entities/submit_word_result.dart';
import 'package:sambasku_mobile/features/contribution/domain/failures/contribution_failure.dart';
import 'package:sambasku_mobile/features/contribution/domain/repositories/contribution_repository.dart';
import 'package:sambasku_mobile/features/contribution/domain/usecases/submit_anon_word_use_case.dart';

/// Usecase wajib unit test (mobile-base-stack Section 10): trim semua
/// input, buang translation/category kosong, null-kan dialectId/notes
/// kosong, dan teruskan hasil Either apa adanya.
class _FakeRepo implements ContributionRepository {
  _FakeRepo(this.result);

  final Either<ContributionFailure, SubmitWordResult> result;
  String? lemma;
  String? languageId;
  String? wordClassId;
  String? definition;
  String? dialectId;
  List<String>? translationTexts;
  List<String>? categoryIds;
  String? notes;

  @override
  Future<Either<ContributionFailure, SubmitWordResult>> submitAnon({
    required String lemma,
    required String languageId,
    required String wordClassId,
    required String definition,
    String? dialectId,
    required List<String> translationTexts,
    List<String> categoryIds = const [],
    String? notes,
  }) async {
    this.lemma = lemma;
    this.languageId = languageId;
    this.wordClassId = wordClassId;
    this.definition = definition;
    this.dialectId = dialectId;
    this.translationTexts = translationTexts;
    this.categoryIds = categoryIds;
    this.notes = notes;
    return result;
  }
}

void main() {
  const result = SubmitWordResult(
    wordId: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
    status: 'pending_review',
  );

  test('sukses - input di-trim, translation/category kosong dibuang', () async {
    final repo = _FakeRepo(Either.right(result));
    final usecase = SubmitAnonWordUseCase(repo);

    final r = await usecase(
      const SubmitAnonWordParams(
        lemma: '  makai  ',
        languageId: 'lan-sbs',
        wordClassId: 'wc-01',
        definition: '  memakai  ',
        dialectId: '  ',
        translationTexts: ['  ', '  make  ', '  '],
        categoryIds: ['  ', 'kat-01'],
        notes: 'halo',
      ),
    );

    expect(repo.lemma, 'makai');
    expect(repo.definition, 'memakai');
    expect(repo.translationTexts, ['make']);
    expect(repo.categoryIds, ['kat-01']);
    // dialectId kosong → di-null-kan (kontrak repository optional)
    expect(repo.dialectId, isNull);
    expect(repo.notes, 'halo');
    expect(r.getRight().toNullable()?.status, 'pending_review');
  });

  test('gagal - failure diteruskan tanpa diubah', () async {
    final repo = _FakeRepo(
      Either.left(
        const ContributionFailure(
          'Language ID tidak dikenal',
          errorCode: 'VALIDATION_ERROR',
        ),
      ),
    );
    final usecase = SubmitAnonWordUseCase(repo);

    final r = await usecase(
      const SubmitAnonWordParams(
        lemma: 'makai',
        languageId: 'lan-xyz',
        wordClassId: 'wc-01',
        definition: 'memakai',
        translationTexts: ['make'],
      ),
    );

    final failure = r.getLeft().toNullable();
    expect(failure?.message, 'Language ID tidak dikenal');
    expect(failure?.errorCode, 'VALIDATION_ERROR');
  });

  test('translation teks tetap di-trim tapi tidak dipaksa minimal 1 di usecase',
      () async {
    final repo = _FakeRepo(Either.right(result));
    final usecase = SubmitAnonWordUseCase(repo);

    await usecase(
      const SubmitAnonWordParams(
        lemma: 'x',
        languageId: 'lan-sbs',
        wordClassId: 'wc-01',
        definition: 'y',
        translationTexts: ['   '],
      ),
    );

    // usecase hanya membersihkan; validasi minimal 1 ada di backend
    // (VALIDATION_ERROR inline field translation_texts).
    expect(repo.translationTexts, isEmpty);
  });
}