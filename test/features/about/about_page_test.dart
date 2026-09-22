import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/about/presentation/pages/about_page.dart';
import 'package:sambasku_mobile/flavors.dart';

void main() {
  setUpAll(() => F.appFlavor = Flavor.production);

  testWidgets('menampilkan fitur tanpa seksi pengembang', (tester) async {
    // Logo + blok fitur lebih tinggi dari viewport default 800×600;
    // ListView tidak membangun "Usulkan" / "Bagikan kartu" di bawah fold.
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        home: FTheme(data: FThemes.zinc.light.touch, child: const AboutPage()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Pengembang'), findsNothing);
    expect(find.text('Ibnul Mutaki'), findsNothing);
    expect(find.text('Tentang'), findsWidgets);
    expect(find.text('Tim Kami'), findsOneWidget);
    expect(find.text('Apa itu SambasKu?'), findsOneWidget);
    expect(find.text('Cari kosakata'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);

    final aboutList = find.descendant(
      of: find.byType(TabBarView),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Usulkan'),
      200,
      scrollable: aboutList.last,
    );
    expect(find.text('Usulkan'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Bagikan kartu'),
      200,
      scrollable: aboutList.last,
    );
    expect(find.text('Bagikan kartu'), findsOneWidget);

    await tester.tap(find.text('Tim Kami'));
    await tester.pumpAndSettle();

    expect(find.text('Bersama warga Sambas'), findsOneWidget);
    expect(find.text('Pengusul'), findsOneWidget);
    expect(find.text('Verifikator'), findsOneWidget);
    expect(find.text('Kontributor pelafalan'), findsOneWidget);
  });
}
