import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/app.dart';
import 'package:sambasku_mobile/core/theme/forui_palette_controller.dart';
import 'package:sambasku_mobile/core/theme/theme_mode_controller.dart';
import 'package:sambasku_mobile/features/onboarding/data/onboarding_prefs.dart';
import 'package:sambasku_mobile/features/search_miss/domain/entities/search_miss.dart';
import 'package:sambasku_mobile/features/search_miss/domain/failures/search_miss_failure.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_of_day_providers.dart';
import 'package:sambasku_mobile/features/search_miss/domain/providers/search_miss_domain_providers.dart';
import 'package:sambasku_mobile/features/search_miss/domain/usecases/list_search_misses_use_case.dart';
import 'package:sambasku_mobile/flavors.dart';

class _FakeListSearchMissesUseCase implements ListSearchMissesUseCase {
  const _FakeListSearchMissesUseCase();

  @override
  Future<Either<SearchMissFailure, List<SearchMiss>>> call(
    ListSearchMissesParams params,
  ) async =>
      Either.right(<SearchMiss>[]);
}

void main() {
  // test tidak melewati main() - flavor + onboarding wajib di-init manual
  setUpAll(() {
    F.appFlavor = Flavor.staging;
    OnboardingPrefs.done = true;
  });

  testWidgets('App bootstrap - HOME tab terender tanpa error', (
    WidgetTester tester,
  ) async {
    // plugin SharedPreferences tidak tersedia di test env - mock values
    SharedPreferences.setMockInitialValues({});
    await ThemeModeController.preload();
    await ForuiPaletteController.preload();
    // banner search-miss memakai jaringan; override usecase supaya test
    // deterministik tanpa pending Timer (dio timeout) di fake-async zone.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listSearchMissesUseCaseProvider
              .overrideWithValue(const _FakeListSearchMissesUseCase()),
          // Kata hari ini juga hit Dio; tanpa stub, connectTimeout
          // menyisakan pending Timer di fake-async.
          wordOfDayProvider.overrideWith((ref) async => null),
        ],
        child: const App(),
      ),
    );
    await tester.pump();
    // redirect GoRouter (getIsAuth) selesai di frame berikutnya
    await tester.pump();

    // cold start langsung HOME (FScaffold shell + header Kamus Sambas)
    expect(find.byType(FScaffold), findsWidgets);
    expect(find.text('Kamus Sambas'), findsOneWidget);
  });
}