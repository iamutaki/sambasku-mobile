/// Failure auth - pesan siap tampil (sudah generik dari backend,
/// anti-enumeration). `errorCode` opsional untuk penanganan spesifik
/// (mis. RATE_LIMITED -> toast hitung mundur).
class AuthFailure {
  const AuthFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;
}
