import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _rememberKey = 'remember_me';
  static const String _savedLoginKey = 'saved_login';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setRememberMe(bool remember, String? loginIdentifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, remember);
    if (remember && loginIdentifier != null) {
      await prefs.setString(_savedLoginKey, loginIdentifier);
    } else {
      await prefs.remove(_savedLoginKey);
    }
  }

  Future<String?> getSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedLoginKey);
  }

  Future<bool> isRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberKey) ?? false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberKey) ?? false;
    final savedLogin = prefs.getString(_savedLoginKey);
    await prefs.clear();
    if (remember && savedLogin != null) {
      await prefs.setBool(_rememberKey, true);
      await prefs.setString(_savedLoginKey, savedLogin);
    }
  }
}