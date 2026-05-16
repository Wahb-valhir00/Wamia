import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';

  // On web, use SharedPreferences (plain localStorage) — Web Crypto API is unreliable in dev.
  // On mobile/desktop, use flutter_secure_storage.
  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      return _secureStorage.read(key: key);
    }
  }

  Future<void> _deleteAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_roleKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
    } else {
      await _secureStorage.deleteAll();
    }
  }

  Future<void> saveToken(String token) => _write(_tokenKey, token);
  Future<String?> getToken() => _read(_tokenKey);

  Future<void> saveRole(String role) => _write(_roleKey, role);
  Future<String?> getRole() => _read(_roleKey);

  Future<void> saveUserId(int id) => _write(_userIdKey, id.toString());
  Future<int?> getUserId() async {
    final val = await _read(_userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  Future<void> saveUserName(String name) => _write(_userNameKey, name);
  Future<String?> getUserName() => _read(_userNameKey);

  Future<void> saveAuthData({
    required String token,
    required String role,
    required int userId,
    required String userName,
  }) async {
    await Future.wait([
      saveToken(token),
      saveRole(role),
      saveUserId(userId),
      saveUserName(userName),
    ]);
  }

  Future<void> clearAll() => _deleteAll();

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
