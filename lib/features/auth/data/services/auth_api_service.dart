import 'dart:io';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthApiService {
  final ApiClient _apiClient = ApiClient();
  final TokenStorage _storage = TokenStorage();

  Future<ApiResponse<dynamic>> register({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _apiClient.post(ApiEndpoints.register, body: {
      'first_name': firstName,
      if (lastName != null && lastName.trim().isNotEmpty) 'last_name': lastName.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<ApiResponse<dynamic>> forgotPassword(String email) {
    return _apiClient.post(ApiEndpoints.forgotPassword, body: {'email': email.trim()});
  }

  Future<ApiResponse<UserModel>> login({
    required String emailOrPhone,
    required String password,
    bool rememberMe = true,
  }) async {
    final response = await _apiClient.post(ApiEndpoints.login, body: {
      'email': emailOrPhone,
      'password': password,
    });

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;

      // Extract JWT token
      String? token;
      if (data['token'] is Map) {
        token = data['token']['access_token'] ?? data['token']['token'];
      } else if (data['token'] is String) {
        token = data['token'];
      } else if (data['access_token'] is String) {
        token = data['access_token'];
      }

      if (token != null) {
        await _storage.saveToken(token);
      }

      // Extract User
      Map<String, dynamic> userData = {};
      if (data['user'] is Map) {
        userData = Map<String, dynamic>.from(data['user'] as Map);
      } else {
        userData = data;
      }

      final user = UserModel.fromJson(userData);
      await _storage.saveUser(user.toJson());
      await _storage.setRememberMe(rememberMe, emailOrPhone);

      return ApiResponse(success: true, message: response.message, data: user);
    }

    return ApiResponse(
      success: false,
      message: response.message,
      errors: response.errors,
    );
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {}
    await _storage.clear();
  }

  Future<UserModel?> getLoggedInUser() async {
    final userData = await _storage.getUser();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  Future<UserModel?> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    if (!response.success || response.data == null) return null;
    final raw = response.data is Map<String, dynamic>
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    final data = raw['user'] is Map
        ? Map<String, dynamic>.from(raw['user'] as Map)
        : raw;
    final user = UserModel.fromJson(data);
    await _storage.saveUser(user.toJson());
    return user;
  }

  /// PUT /api/v1/profile
  /// Supports optional [image] file upload (multipart) alongside text fields.
  /// When [image] is provided the request is sent as multipart/form-data with
  /// a _method=PUT override so Laravel's FormRequest receives it correctly.
  Future<ApiResponse<UserModel>> updateProfile({
    required String firstName,
    String? lastName,
    required String email,
    String? mobile,
    String? locale,
    File? image,
  }) async {
    ApiResponse<dynamic> response;

    if (image != null) {
      // Multipart upload with _method override (POST tunnelled as PUT)
      response = await _apiClient.uploadMultipart(
        ApiEndpoints.profile,
        file: image,
        fileField: 'image',
        fields: {
          '_method': 'PUT',
          'first_name': firstName.trim(),
          if (lastName != null && lastName.trim().isNotEmpty) 'last_name': lastName.trim(),
          'email': email.trim(),
          if (mobile != null && mobile.trim().isNotEmpty) 'mobile': mobile.trim(),
          if (locale != null) 'locale': locale,
        },
      );
    } else {
      response = await _apiClient.put(ApiEndpoints.profile, body: {
        'first_name': firstName.trim(),
        if (lastName != null && lastName.trim().isNotEmpty) 'last_name': lastName.trim(),
        'email': email.trim(),
        if (mobile != null && mobile.trim().isNotEmpty) 'mobile': mobile.trim(),
        if (locale != null) 'locale': locale,
      });
    }

    if (!response.success || response.data == null) {
      return ApiResponse(
          success: false, message: response.message, errors: response.errors);
    }
    final raw = response.data is Map<String, dynamic>
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    final user = UserModel.fromJson(
        raw['user'] is Map ? Map<String, dynamic>.from(raw['user'] as Map) : raw);
    await _storage.saveUser(user.toJson());
    return ApiResponse(success: true, message: response.message, data: user);
  }

  /// POST /api/v1/auth/change-password
  /// Fields: current_password, password, password_confirmation
  Future<ApiResponse<dynamic>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _apiClient.post(ApiEndpoints.changePassword, body: {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }
}
