import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/models/api_response.dart';
import 'package:sambasku_mobile/features/contribution/domain/failures/contribution_failure.dart';

/// Failure: mapping VALIDATION_ERROR backend bertingkat `meanings.N.*`
/// ke nama field inline form (mobile-base-stack Section 11).
void main() {
  const failure = ContributionFailure(
    'Gagal validasi',
    errorCode: 'VALIDATION_ERROR',
    details: [
      ApiErrorDetail(field: 'lemma', message: 'Kata tidak boleh kosong'),
      ApiErrorDetail(
        field: 'meanings.0.word_class_id',
        message: 'ID kelas kata tidak valid',
      ),
      ApiErrorDetail(
        field: 'meanings.0.definition',
        message: 'Definisi tidak boleh kosong',
      ),
      ApiErrorDetail(
        field: 'meanings.0.translations.0.language_id',
        message: 'Bahasa target terjemahan tidak dikenal',
      ),
      ApiErrorDetail(
        field: 'meanings.0.translations.0.translation_text',
        message: 'Terjemahan tidak boleh kosong',
      ),
    ],
  );

  test('field polos tetap cocok langsung', () {
    expect(failure.errorFor('lemma'), 'Kata tidak boleh kosong');
  });

  test('meanings.N.<field> dipetakan ke field form sejajar', () {
    expect(failure.errorFor('word_class_id'), 'ID kelas kata tidak valid');
    expect(failure.errorFor('definition'), 'Definisi tidak boleh kosong');
  });

  test('error translations.* muncul di kolom translation_texts', () {
    // sesuai urutan detail[]: yang cocok pertama = language_id
    expect(
      failure.errorFor('translation_texts'),
      'Bahasa target terjemahan tidak dikenal',
    );
  });

  test('field yang tidak ada errornya → null', () {
    expect(failure.errorFor('dialect_id'), isNull);
    expect(failure.errorFor('notes'), isNull);
  });
}