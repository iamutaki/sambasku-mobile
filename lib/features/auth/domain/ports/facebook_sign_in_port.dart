/// Wrap SDK Facebook Login. `null` = user batal / dismiss sheet.
abstract interface class FacebookSignInPort {
  Future<String?> authenticate();
}
