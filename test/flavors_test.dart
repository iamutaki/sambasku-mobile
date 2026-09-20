import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/flavors.dart';

void main() {
  test('staging memakai logo.staging, production memakai logo.png', () {
    F.appFlavor = Flavor.staging;
    expect(F.logoAsset, 'assets/icons/logo.staging.png');

    F.appFlavor = Flavor.production;
    expect(F.logoAsset, 'assets/icons/logo.png');
  });
}
