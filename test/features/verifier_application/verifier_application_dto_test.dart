import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/verifier_application/data/models/verifier_application_dto.dart';

void main() {
  Map<String, dynamic> loadFixture(String name) {
    final file = File('test/fixtures/json/verifier-applications/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  test('get-me.200.json → VerifierApplicationDto', () {
    final json = loadFixture('get-me.200.json');
    final dto = VerifierApplicationDto.fromJson(
      json['data'] as Map<String, dynamic>,
    );

    expect(dto.id, '01JDVA00000000000000000000');
    expect(dto.status, 'pending');
    expect(dto.phone, '6281234567890');
    expect(dto.address, contains('Sambas'));
    expect(dto.socialLinks, hasLength(1));
    expect(dto.socialLinks.first.platform, 'instagram');
    expect(dto.adminComment, isNull);
  });

  test('get-me.404.json → VERIFIER_APPLICATION_NOT_FOUND', () {
    final json = loadFixture('get-me.404.json');
    expect(json['success'], isFalse);
    expect(json['error_code'], 'VERIFIER_APPLICATION_NOT_FOUND');
  });
}
