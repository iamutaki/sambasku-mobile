import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/review/data/review_correct_body.dart';
import 'package:sambasku_mobile/features/review/domain/entities/review_contribution.dart';
import 'package:sambasku_mobile/features/review/domain/failures/review_failure.dart';
import 'package:sambasku_mobile/features/review/domain/repositories/review_repository.dart';
import 'package:sambasku_mobile/features/review/presentation/pages/review_queue_page.dart';
import 'package:sambasku_mobile/features/review/presentation/providers/review_providers.dart';
import 'package:sambasku_mobile/features/review/presentation/widgets/review_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository(this.failure);

  final ReviewFailure? failure;

  @override
  Future<Either<ReviewFailure, ReviewListPage>> list({
    String? status,
    String? entityType,
    String? wordId,
    int limit = 20,
    String? cursor,
  }) async {
    if (failure != null) return Either.left(failure!);
    return Either.right(
      const ReviewListPage(
        items: [
          ReviewItem(
            id: '01REVIEWITEM00000000000001',
            contributorUsername: 'budi',
            entityType: 'word',
            entityId: '01WORD00000000000000000001',
            action: 'create',
            status: 'pending',
            createdAt: '2026-09-23T00:00:00.000Z',
            wordLemma: 'kalintiak',
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<ReviewFailure, ReviewDetail>> detail(String id) async =>
      Either.left(ReviewFailure('tidak dipakai'));

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> approve(
    String id, {
    String? comment,
  }) async => Either.left(ReviewFailure('sudah', errorCode: 'CONTRIBUTION_ALREADY_REVIEWED'));

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> reject(
    String id, {
    required String comment,
  }) async => Either.left(ReviewFailure('tidak dipakai'));

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> correct(
    String id,
    Map<String, dynamic> body,
  ) async => Either.left(ReviewFailure('tidak dipakai'));
}

void main() {
  test('body koreksi kata membawa gambar dan tidak mengosongkan makna', () {
    final body = buildWordCorrectBody(
      entity: {
        'languageId': '01LANG00000000000000000001',
        'lemma': 'lama',
        'wordType': 'word',
        'isVerified': true,
        'meanings': [
          {
            'definition': 'ikan',
            'orderIndex': 0,
            'wordClass': {'id': '01CLASS0000000000000000001'},
            'translations': [
              {
                'languageId': '01ID0000000000000000000001',
                'translationText': 'ikan kecil',
                'translationType': 'direct',
              },
            ],
          },
        ],
        'images': [
          {'url': 'https://cdn.example/a.png', 'providerFileId': 'file-1', 'isPrimary': true},
        ],
        'categories': [],
      },
      lemma: 'kalintiak',
      notes: '',
      wordType: 'word',
      meaningEdits: [(definition: 'ikan kecil', translation: 'ikan kecil')],
      publish: true,
    );

    expect(body['lemma'], 'kalintiak');
    expect(body['images'], isNotEmpty);
    expect((body['meanings'] as List).first['definition'], 'ikan kecil');
  });

  test('409 menutup kartu dari antrean', () {
    final failure = ReviewFailure(
      'Kontribusi ini sudah diproses',
      errorCode: 'CONTRIBUTION_ALREADY_REVIEWED',
    );
    expect(failure.isAlreadyDecided, isTrue);
    expect(ReviewFailure('dilarang', errorCode: 'FORBIDDEN').isForbidden, isTrue);
  });

  testWidgets('kontributor tidak lolos penjaga antrean', (tester) async {
    SharedPreferences.setMockInitialValues({
      'isAuth': true,
      'sessionUsername': 'budi',
      'sessionRole': 'contributor',
    });
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'test-access',
      'refreshToken': 'test-refresh',
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
        ],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: ReviewGate(child: Text('antrean')),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Kamu tidak berwenang meninjau usulan.'), findsOneWidget);
    expect(find.text('antrean'), findsNothing);
  });

  testWidgets('403 dari API membuka layar penghalang', (tester) async {
    SharedPreferences.setMockInitialValues({
      'isAuth': true,
      'sessionUsername': 'rina',
      'sessionRole': 'reviewer',
    });
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'test-access',
      'refreshToken': 'test-refresh',
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          reviewRepositoryProvider.overrideWithValue(
            _FakeReviewRepository(
              ReviewFailure(
                'Role tidak diizinkan mengakses endpoint ini',
                errorCode: 'FORBIDDEN',
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: ReviewQueuePage(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Kamu tidak berwenang meninjau usulan.'), findsOneWidget);
    expect(
      find.text('Role tidak diizinkan mengakses endpoint ini'),
      findsOneWidget,
    );
  });
}
