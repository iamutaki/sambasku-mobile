import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/auth/data/providers/auth_data_providers.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, void>> logout() async => Either.right(null);
}

/// Widget test Profile (mobile-base-stack Section 10): status login vs
/// tamu menentukan tombol "Keluar" / "Masuk / Login", dan logout berfungsi.
void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const ProfilePage(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('tamu - menampilkan ajakan masuk tanpa tombol Keluar', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('Belum masuk'), findsOneWidget);
    expect(find.text('Masuk / Login'), findsOneWidget);
    expect(find.text('Keluar'), findsNothing);
  });

  testWidgets('sudah login - tombol Keluar tampil dan logout berfungsi', (
    tester,
  ) async {
    await pumpProfile(tester, prefs: {
      'isAuth': true,
      'sessionUsername': 'budi',
      'sessionRole': 'contributor',
    });

    expect(find.text('Masuk sebagai budi'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);

    await tester.tap(find.text('Keluar'));
    await tester.pump();
    // Forui FButton memakai Future.delayed untuk pressedEnter/Exit -
    // majukan waktu supaya Timer-nya habis (hindari pending timer test).
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Belum masuk'), findsOneWidget);
    expect(find.text('Masuk / Login'), findsOneWidget);
    expect(find.text('Keluar'), findsNothing);
  });
}