/// State halaman form `/contribute` (submit kata anonim).
///
/// Dipakai oleh `SubmitWordNotifier` (@riverpod). Error inline per field
/// di-baca dari `failure?.errorFor('lemma')` dan teman-temannya.
///
/// - `initialLemma / initialSearchIn`: di-set dari GoRouter queryParams
///   (saat navigate via CTA banner search-miss / empty state).
class SubmitWordState {
  const SubmitWordState({
    this.initialLemma,
    this.initialSearchIn,
    this.failure,
    this.result,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String? initialLemma;
  final String? initialSearchIn;

  final bool isSubmitting;

  /// Error global (bukan field-specific), misal 429 rate limit,
  /// 500 server error, timeout connection, dll.
  final String? errorMessage;

  /// Failure detail (termasuk details[] inline VALIDATION_ERROR per field).
  final Object? failure;

  /// Hasil submit SUCCESS, untuk tampilkan dialog sukses / navigate ke
  /// halaman menunggu verifikasi.
  final Object? result;

  bool get hasResult => result != null;
  bool get hasValidationError => failure != null;

  /// Shortcut untuk UI: baca result sebagai SubmitWordResult.
  /// Null jika result belum ada / tipe tidak sesuai.
  dynamic get successResult {
    final r = result;
    if (r == null) return null;
    try {
      return r as dynamic;
    } catch (_) {
      return null;
    }
  }

  SubmitWordState copyWith({
    String? initialLemma,
    String? initialSearchIn,
    bool? isSubmitting,
    String? errorMessage,
    Object? failure,
    Object? result,
    bool clearFailure = false,
    bool clearResult = false,
    bool clearErrorMessage = false,
  }) {
    return SubmitWordState(
      initialLemma: initialLemma ?? this.initialLemma,
      initialSearchIn: initialSearchIn ?? this.initialSearchIn,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      failure: clearFailure ? null : (failure ?? this.failure),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}
