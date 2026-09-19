/// State status login app (pola jnn_mobile): dipakai Profile untuk
/// membedakan tampilan user sudah login vs tamu.
class AuthStatusState {
  const AuthStatusState({
    this.isAuth = false,
    this.username,
    this.role,
    this.userId,
    this.isLoggingOut = false,
  });

  final bool isAuth;
  final String? username;
  final String? role;
  final String? userId;
  final bool isLoggingOut;

  AuthStatusState copyWith({
    bool? isAuth,
    String? username,
    String? role,
    String? userId,
    bool? isLoggingOut,
  }) {
    return AuthStatusState(
      isAuth: isAuth ?? this.isAuth,
      username: username ?? this.username,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}