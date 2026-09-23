/// Wrap SDK Google Sign-In.
/// `null` = user batal / dismiss sheet (bukan misconfig).
abstract interface class GoogleSignInPort {
  Future<String?> authenticate();
}
