/// Failure untuk module SearchMiss. Semua operasi gagal baca data
/// banner pencarian populer. Simpel: cuma punya message + optional
/// error_code dari envelope backend.
class SearchMissFailure {
  const SearchMissFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;
}
