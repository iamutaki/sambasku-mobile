import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan token sesi (pola jnn_mobile): access/refresh di
/// flutter_secure_storage (Keychain/Keystore), flag isAuth di
/// shared_preferences untuk redirect router yang cepat.
class AuthTokenStorage {
  AuthTokenStorage({FlutterSecureStorage? storage, SharedPreferences? prefs})
    : _storage = storage ?? const FlutterSecureStorage(),
      _resolvedPrefs = prefs;

  static AuthTokenStorage? _instance;

  static AuthTokenStorage get instance => _instance ??= AuthTokenStorage();

  final FlutterSecureStorage _storage;
  SharedPreferences? _resolvedPrefs;

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _isAuthKey = 'isAuth';
  static const _usernameKey = 'sessionUsername';
  static const _roleKey = 'sessionRole';

  Future<SharedPreferences> get _sharedPrefs async =>
      _resolvedPrefs ??= await SharedPreferences.getInstance();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw ArgumentError(
        'accessToken dan refreshToken wajib non-empty (varian mobile)',
      );
    }
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    final value = await _storage.read(key: _accessTokenKey);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<String?> getRefreshToken() async {
    final value = await _storage.read(key: _refreshTokenKey);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
    final prefs = await _sharedPrefs;
    await Future.wait([
      prefs.remove(_usernameKey),
      prefs.remove(_roleKey),
    ]);
    await setIsAuth(false);
  }

  /// Simpan info user dari response login (backend tak punya endpoint
  /// "profile/me", jadi username + role dipakai untuk info user di Profil).
  Future<void> saveSessionUser({
    required String username,
    required String? role,
  }) async {
    final prefs = await _sharedPrefs;
    await Future.wait([
      prefs.setString(_usernameKey, username),
      if (role != null && role.isNotEmpty) prefs.setString(_roleKey, role),
    ]);
  }

  Future<({String? username, String? role})> getSessionUser() async {
    final prefs = await _sharedPrefs;
    return (
      username: prefs.getString(_usernameKey),
      role: prefs.getString(_roleKey),
    );
  }

  Future<bool> getIsAuth() async => (await _sharedPrefs).getBool(_isAuthKey) ?? false;

  Future<void> setIsAuth(bool value) async =>
      (await _sharedPrefs).setBool(_isAuthKey, value);
}
