import '../../../../core/models/api_response.dart';

/// Failure untuk operasi submit kata (anonim / login).
///
/// Mendukung:
/// - 400 VALIDATION_ERROR: `details[]` berisi error inline per field
///   → di UI tampilkan di bawah FTextField yang sesuai (mobile-base-stack
///   Section 11 mapping VALIDATION_ERROR).
/// - 429 RATE_LIMITED: usulan dikirim terlalu sering → toast
///   "Terlalu banyak usulan dikirim. Coba lagi nanti".
class ContributionFailure {
  const ContributionFailure(
    this.message, {
    this.errorCode,
    this.details = const <ApiErrorDetail>[],
  });

  final String message;
  final String? errorCode;
  final List<ApiErrorDetail> details;

  /// Cari error inline untuk field tertentu. Kosong = tidak ada error.
  /// Dipakai UI: `Text(failure.errorFor('lemma') ?? '')` di bawah input.
  ///
  /// Field backend bertingkat di-normal-kan ke padanan field form:
  /// - `meanings.0.word_class_id` → `word_class_id`
  /// - `meanings.0.definition` → `definition`
  /// - `meanings.0.translations.0.language_id` → `translation_texts`
  String? errorFor(String field) {
    for (final d in details) {
      if (_displayField(d.field) == field) return d.message;
    }
    return null;
  }

  /// Normalisasi jalur field dari VALIDATION_ERROR backend (`meanings.N.*`)
  /// ke nama field UI; buang index array supaya `meanings.0.definition`
  /// dan `meanings.1.definition` sama-sama tampil di kolom definisi.
  String _displayField(String path) {
    final parts = path
        .split('.')
        .where((p) => int.tryParse(p) == null)
        .toList(growable: false);
    final flat = parts.join('.');
    if (flat.startsWith('meanings.')) {
      final inner = flat.substring('meanings.'.length);
      if (inner == 'translations' || inner.startsWith('translations.')) {
        return 'translation_texts';
      }
      return inner;
    }
    return flat;
  }

  bool get isRateLimited => errorCode == 'RATE_LIMITED';
  bool get isValidationError => errorCode == 'VALIDATION_ERROR';
}
