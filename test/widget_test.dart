import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/app.dart';
import 'package:sambasku_mobile/flavors.dart';

void main() {
  // test tidak melewati main() - flavor wajib di-init manual
  setUpAll(() => F.appFlavor = Flavor.staging);

  testWidgets('App bootstrap - HOME tab terender tanpa error', (
    WidgetTester tester,
  ) async {
    // plugin SharedPreferences tidak tersedia di test env - mock values
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pump();

    // cold start langsung HOME (FScaffold shell + header Kamus Sambas)
    expect(find.byType(FScaffold), findsWidgets);
    expect(find.text('Kamus Sambas'), findsOneWidget);
  });
}
