import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/utils/ulid.dart';

void main() {
  test('looksLikeUlid menerima Crockford 26 char', () {
    expect(looksLikeUlid('01ARZ3NDEKTSV4RRFFQ69G5FAV'), isTrue);
    expect(looksLikeUlid('01arz3ndektsv4rrffq69g5fav'), isTrue);
  });

  test('looksLikeUlid menolak lemma biasa', () {
    expect(looksLikeUlid('makatn'), isFalse);
    expect(looksLikeUlid('miyang rabong'), isFalse);
    expect(looksLikeUlid(''), isFalse);
  });
}
