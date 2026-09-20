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
  bool? isHaveDefinition;
  bool? isHaveTranslation;
  String? dialectId;
  List<String>? translationTexts;
  List<String>? categoryIds;
  String? notes;
  List<String>? spellingVariants;
  List<SubmitWordRelation>? relatedWords;
  String? translationLanguageId;
  List<SubmitWordImage>? images;
  String? searchMissId;

  @override
  Future<Either<ContributionFailure, SubmitWordResult>> submitAnon({
    required String lemma,
    required String languageId,
    required String wordClassId,
    required String definition,
    bool isHaveDefinition = true,
    bool isHaveTranslation = true,
    String? dialectId,
    required List<String> translationTexts,
    List<String> categoryIds = const [],
    String? notes,
    List<String> spellingVariants = const [],
    List<SubmitWordRelation> relatedWords = const [],
    required String translationLanguageId,
    List<SubmitWordImage> images = const [],
    String? searchMissId,
  }) async {
    this.lemma = lemma;
    this.languageId = languageId;
    this.wordClassId = wordClassId;
    this.definition = definition;
    this.isHaveDefinition = isHaveDefinition;
    this.isHaveTranslation = isHaveTranslation;
    this.dialectId = dialectId;
    this.translationTexts = translationTexts;
    this.categoryIds = categoryIds;
    this.notes = notes;
    this.spellingVariants = spellingVariants;
    this.relatedWords = relatedWords;
    this.translationLanguageId = translationLanguageId;
    this.images = images;
    this.searchMissId = searchMissId;
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
        translationLanguageId: 'lan-idn',
      ),
    );

    expect(repo.lemma, 'makai');
    expect(repo.definition, 'memakai');
    expect(repo.translationTexts, ['make']);
    expect(repo.categoryIds, ['kat-01']);
    // dialectId kosong → di-null-kan (kontrak repository optional)
    expect(repo.dialectId, isNull);
    expect(repo.notes, 'halo');
    expect(repo.translationLanguageId, 'lan-idn');
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
        translationLanguageId: 'lan-idn',
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
        translationLanguageId: 'lan-idn',
      ),
    );

    // usecase hanya membersihkan; validasi minimal 1 ada di backend
    // (VALIDATION_ERROR inline field translation_texts).
    expect(repo.translationTexts, isEmpty);
  });

  test('tanpa definisi - paksa definition "-" saja; terjemahan tetap', () async {
    final repo = _FakeRepo(Either.right(result));
    final usecase = SubmitAnonWordUseCase(repo);

    await usecase(
      const SubmitAnonWordParams(
        lemma: 'makai',
        languageId: 'lan-sbs',
        wordClassId: 'wc-01',
        definition: 'akan diabaikan',
        isHaveDefinition: false,
        translationTexts: ['  memakai  '],
        translationLanguageId: 'lan-idn',
        relatedWords: [
          SubmitWordRelation(relationType: 'synonym', lemma: ' make '),
          SubmitWordRelation(relationType: 'antonym', lemma: 'makai'),
        ],
      ),
    );

    expect(repo.definition, '-');
    expect(repo.translationTexts, ['memakai']);
    expect(repo.isHaveDefinition, false);
    // lemma induk didrop; synonym tetap
    expect(repo.relatedWords?.length, 1);
    expect(repo.relatedWords?.first.lemma, 'make');
    expect(repo.relatedWords?.first.relationType, 'synonym');
  });

  test('tanpa padanan - translations kosong, isHaveTranslation false', () async {
    final repo = _FakeRepo(Either.right(result));
    final usecase = SubmitAnonWordUseCase(repo);

    await usecase(
      const SubmitAnonWordParams(
        lemma: 'makai',
        languageId: 'lan-sbs',
        wordClassId: 'wc-01',
        definition: 'uraian makna tanpa padanan tunggal',
        isHaveTranslation: false,
        translationTexts: ['akan diabaikan'],
        translationLanguageId: 'lan-idn',
      ),
    );

    expect(repo.definition, 'uraian makna tanpa padanan tunggal');
    expect(repo.translationTexts, isEmpty);
    expect(repo.isHaveTranslation, false);
  });
}