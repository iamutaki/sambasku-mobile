/// Failure operasi bookmark. `errorCode` membawa kode backend untuk
/// penanganan spesifik (mis. WORD_NOT_FOUND -> kata sudah tidak ada).
///
/// extends Error DELIBERAT: Riverpod 3 auto-retry (defaultRetry) hanya
/// berlaku untuk exception non-Error - failure domain 4xx (401/404/429)
/// bersifat terminal, retry 10x hanya bikin halaman stuck loading +
/// spam request. Sebagai Error, build yang throw langsung jadi AsyncError
/// → UI error message.
class BookmarkFailure extends Error {
  BookmarkFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  bool get isNotFound => errorCode == 'WORD_NOT_FOUND';
  bool get isRateLimited => errorCode == 'RATE_LIMITED';

  @override
  String toString() => 'BookmarkFailure($errorCode): $message';
}
