/// Wrap SDK Google Sign-In. `null` = user batal / dismiss sheet.
abstract interface class GoogleSignInPort {
  Future<String?> authenticate();
}
