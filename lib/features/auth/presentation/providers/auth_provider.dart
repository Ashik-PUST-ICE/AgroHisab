import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _authService = AuthApiService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> register({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final response = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation);
    _isLoading = false;
    _errorMessage = response.success ? null : response.message;
    notifyListeners();
    return response.success;
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final response = await _authService.forgotPassword(email);
    _isLoading = false;
    _errorMessage = response.success ? null : response.message;
    notifyListeners();
    return response.success;
  }

  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _currentUser = await _authService.getLoggedInUser();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _currentUser != null;
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _authService.getProfile();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Profile refresh failed: $e');
    }
  }

  /// PUT /api/v1/profile — update trader name, contact, locale, and optional avatar image.
  Future<bool> updateProfile({
    required String firstName,
    String? lastName,
    required String email,
    String? mobile,
    String? locale,
    File? image,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final response = await _authService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobile: mobile,
      locale: locale,
      image: image,
    );
    if (response.success && response.data != null) _currentUser = response.data;
    _errorMessage = response.success ? null : response.message;
    _isLoading = false;
    notifyListeners();
    return response.success;
  }

  /// POST /api/v1/auth/change-password
  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final response = await _authService.changePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    _errorMessage = response.success ? null : response.message;
    _isLoading = false;
    notifyListeners();
    return response.success;
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        emailOrPhone: emailOrPhone,
        password: password,
        rememberMe: rememberMe,
      );

      if (response.success && response.data != null) {
        _currentUser = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          final firstError = response.errors!.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            _errorMessage = firstError.first.toString();
          }
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'লগইন ব্যর্থ হয়েছে: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
