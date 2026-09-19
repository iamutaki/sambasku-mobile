/// Failure ubah password - pesan siap tampil (sudah ramah user dari
/// backend, mis. "Password lama salah"). `errorCode` opsional untuk
/// penanganan spesifik (VALIDATION_ERROR → inline field, dsb.).
class ChangePasswordFailure {
  const ChangePasswordFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;
}
