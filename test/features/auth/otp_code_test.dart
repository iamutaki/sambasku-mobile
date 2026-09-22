import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/auth/otp_code.dart';

void main() {
  group('otp_code', () {
    test('normalize huruf kecil dan tanda hubung', () {
      expect(normalizeOtpInput('a4k9-m2xp'), 'A4K9M2XP');
      expect(normalizeOtpInput('A4K9M2XP'), 'A4K9M2XP');
    });

    test('format tampilan XXXX-XXXX', () {
      expect(formatOtpDisplay('a4k9m2xp'), 'A4K9-M2XP');
      expect(formatOtpDisplay('A4K9'), 'A4K9');
      expect(formatOtpDisplay('A4K9M2XPZZ'), 'A4K9-M2XP');
    });
  });
}
