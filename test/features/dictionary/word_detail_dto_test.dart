import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/data/models/word_detail_dto.dart';

void main() {
  Map<String, dynamic> loadFixture(String name) {
    final file = File('test/fixtures/json/word/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  test('verified_by object → WordVerifierDto', () {
    final json = loadFixture('get-word-detail.verified-by.json');
    final dto = WordDetailDto.fromJson(json['data'] as Map<String, dynamic>);

    expect(dto.isVerified, isTrue);
    expect(dto.verifiedBy?.username, 'budi');
    expect(dto.verifiedBy?.role, 'reviewer');
    expect(dto.verifiedAt, '2026-09-12T03:00:00.000Z');
  });

  test('verified_by null saat belum diverifikasi', () {
    final json = loadFixture('get-word-detail.unverified.json');
    final dto = WordDetailDto.fromJson(json['data'] as Map<String, dynamic>);

    expect(dto.isVerified, isFalse);
    expect(dto.verifiedBy, isNull);
    expect(dto.verifiedAt, isNull);
  });
}
