import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/contribution/domain/entities/submit_word_result.dart';
import 'package:sambasku_mobile/features/contribution/domain/failures/contribution_failure.dart';
import 'package:sambasku_mobile/features/contribution/domain/repositories/contribution_repository.dart';
import 'package:sambasku_mobile/features/contribution/domain/usecases/submit_anon_word_use_case.dart';

class _FakeRepo implements ContributionRepository {
  List<SubmitWordImage>? lastImages;

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
    List<String> spellingVariants = const [],
    required String translationLanguageId,
    List<SubmitWordImage> images = const [],
    String? searchMissId,
  }) async {
    lastImages = images;
    return Either.right(
      const SubmitWordResult(wordId: '01TEST', status: 'pending_review'),
    );
  }
}

void main() {
  test('submit memastikan satu is_primary bila ada gambar', () async {
    final repo = _FakeRepo();
    final usecase = SubmitAnonWordUseCase(repo);

    await usecase(
      const SubmitAnonWordParams(
        lemma: 'makatn',
        languageId: '01LANG',
        wordClassId: '01CLASS',
        definition: 'makan',
        translationLanguageId: '01IDN',
        translationTexts: ['makan'],
        images: [
          SubmitWordImage(
            url: 'https://ik.imagekit.io/x/a.jpg',
            providerFileId: 'file_a',
          ),
          SubmitWordImage(
            url: 'https://ik.imagekit.io/x/b.jpg',
            providerFileId: 'file_b',
          ),
        ],
      ),
    );

    expect(repo.lastImages, isNotNull);
    expect(repo.lastImages!.where((e) => e.isPrimary), hasLength(1));
    expect(repo.lastImages!.first.isPrimary, isTrue);
  });
}
