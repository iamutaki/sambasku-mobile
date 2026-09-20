import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/about/presentation/pages/about_page.dart';
import 'package:sambasku_mobile/flavors.dart';

void main() {
  setUpAll(() => F.appFlavor = Flavor.production);

  testWidgets('menampilkan section pengembang Ibnul Mutaki', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        home: FTheme(
          data: FThemes.zinc.light.touch,
          child: const AboutPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Pengembang'), findsOneWidget);
    expect(find.text('Ibnul Mutaki'), findsOneWidget);
    expect(find.text('IM'), findsOneWidget);
  });
}
