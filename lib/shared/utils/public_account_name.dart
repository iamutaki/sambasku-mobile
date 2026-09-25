/// Sama dengan `DELETED_ACCOUNT_LABEL` di API. Bukan username yang bisa dibuka.
const deletedAccountLabel = 'Akun tidak ditemukan';

bool isLinkablePublicUsername(String? username) {
  if (username == null || username.isEmpty) return false;
  if (username == 'anonim' || username == deletedAccountLabel) return false;
  if (username.startsWith('dihapus-')) return false;
  return true;
}

String displayPublicUsername(String? username) {
  if (username == null || username.isEmpty || username.startsWith('dihapus-')) {
    return deletedAccountLabel;
  }
  return username;
}
