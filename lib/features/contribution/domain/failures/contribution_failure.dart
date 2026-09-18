import '../../../../core/models/api_response.dart';

/// Failure untuk operasi submit kata (anonim / login).
///
/// Mendukung:
/// - 400 VALIDATION_ERROR: `details[]` berisi error inline per field
///   → di UI tampilkan di bawah FTextField yang sesuai (mobile-base-stack
///   Section 11 mapping VALIDATION_ERROR).
/// - 429 RATE_LIMITED: IP user anonim sudah > 5 submit/jam → toast
///   "Kirim terlalu sering, coba lagi 1 jam".
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
  String? errorFor(String field) {
    for (final d in details) {
      if (d.field == field) return d.message;
    }
    return null;
  }

  bool get isRateLimited => errorCode == 'RATE_LIMITED';
  bool get isValidationError => errorCode == 'VALIDATION_ERROR';
}
