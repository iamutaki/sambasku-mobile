import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/widgets/cached_network_image_with_fallback.dart';

void main() {
  group('isSvgNetworkUrl', () {
    test('https svg path is true', () {
      expect(
        isSvgNetworkUrl('https://cdn.example.com/logos/shopee.svg'),
        isTrue,
      );
    });

    test('svg path with query string is true', () {
      expect(
        isSvgNetworkUrl('https://cdn.example.com/logos/shopee.svg?v=1'),
        isTrue,
      );
    });

    test('png path is false', () {
      expect(
        isSvgNetworkUrl('https://cdn.example.com/logos/shopee.png'),
        isFalse,
      );
    });

    test('empty string is false', () {
      expect(isSvgNetworkUrl(''), isFalse);
    });
  });
}
