/// State status login app (pola jnn_mobile): dipakai Profile untuk
/// membedakan tampilan user sudah login vs tamu.
class AuthStatusState {
  const AuthStatusState({
    this.isAuth = false,
    this.username,
    this.role,
    this.isLoggingOut = false,
  });

  final bool isAuth;
  final String? username;
  final String? role;
  final bool isLoggingOut;

  AuthStatusState copyWith({
    bool? isAuth,
    String? username,
    String? role,
    bool? isLoggingOut,
  }) {
    return AuthStatusState(
      isAuth: isAuth ?? this.isAuth,
      username: username ?? this.username,
      role: role ?? this.role,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}