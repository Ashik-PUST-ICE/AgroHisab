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

  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }
}
