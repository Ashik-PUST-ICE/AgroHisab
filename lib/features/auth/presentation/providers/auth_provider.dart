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
      _errorMessage = 'লগইন ব্যর্থ হয়েছে: ${e.toString()}';
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