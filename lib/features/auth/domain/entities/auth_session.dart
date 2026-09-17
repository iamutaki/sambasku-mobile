/// Entity domain - sesi user setelah login (murni Dart, tanpa JSON).
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.username,
    required this.role,
  });

  final String userId;
  final String username;
  final String role;

  /// Role verifikator (base-stack Section 22) - dipakai UI menyembunyikan
  /// aksi khusus (antrean review, dsb)
  bool get isVerifier => role == 'admin' || role == 'root' || role == 'reviewer';
}
