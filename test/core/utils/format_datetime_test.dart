import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/utils/format_datetime.dart';

void main() {
  test('formatDateYmd: YYYY-MM-DD tanpa geser zona', () {
    expect(formatDateYmd('2026-09-21'), '21 Sep 2026');
    expect(formatDateYmd('2026-08-02'), '2 Agu 2026');
    expect(formatDateYmd(null), '');
    expect(formatDateYmd('bukan-tanggal'), '');
  });
}
