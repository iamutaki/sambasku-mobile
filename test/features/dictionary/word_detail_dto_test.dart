import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/data/models/word_detail_dto.dart';

/// Snapshot dari docs/json/word (repo mandiri, tanpa monorepo docs/).
void main() {
  test('get-word-detail.200.json → WordDetailDto + relasi', () {
    final file = File('test/fixtures/json/word/get-word-detail.200.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final dto = WordDetailDto.fromJson(json['data'] as Map<String, dynamic>);

    expect(dto.lemma, 'makatn');
    expect(dto.meanings, isNotEmpty);
    expect(dto.meanings.first.translations.first.translationText, 'makan');
    expect(dto.relatedWords.first.relationType, 'synonym');
    expect(dto.variants.first.form, 'memakan');
    expect(dto.isVerified, isTrue);
  });
}
