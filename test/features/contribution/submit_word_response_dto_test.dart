import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/contribution/data/models/submit_word_response_dto.dart';

/// Snapshot response 201 POST /api/v1/contributions/words.
/// Path: test/fixtures/json/contribution/submit-word.201.json
void main() {
  Map<String, dynamic> loadEnvelope(String name) {
    final file = File('test/fixtures/json/contribution/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  test('submit-word.201.json → SubmitWordResponseDto', () {
    final json = loadEnvelope('submit-word.201.json');
    final data = json['data'] as Map<String, dynamic>;
    final dto = SubmitWordResponseDto.fromJson(data);

    expect(dto.wordId, '01ARZ3NDEKTSV4RRFFQ69G5FAV');
    expect(dto.status, 'pending_review');
  });

  test('konstruktor + toJson round-trip', () {
    final dto = const SubmitWordResponseDto(
      wordId: '01X',
      status: 'pending_review',
    );
    final encoded = dto.toJson();

    expect(encoded['word_id'], '01X');
    expect(encoded['status'], 'pending_review');
  });
}