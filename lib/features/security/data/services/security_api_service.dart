import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/security_settings_model.dart';

class SecurityApiService {
  final ApiClient _apiClient = ApiClient();

  /// GET /api/v1/security-settings
  Future<SecuritySettingsModel?> getSecuritySettings() async {
    final response = await _apiClient.get(ApiEndpoints.securitySettings);
    if (!response.success || response.data == null) return null;
    final raw = response.data is Map<String, dynamic>
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    // Backend wraps data in a 'data' key sometimes
    final payload = raw['data'] is Map ? Map<String, dynamic>.from(raw['data'] as Map) : raw;
    return SecuritySettingsModel.fromJson(payload);
  }

  /// POST /api/v1/security-settings/change-pin
  /// [currentPin] can be null when no PIN is set yet (first-time setup).
  Future<ApiResponse<dynamic>> changePin({
    String? currentPin,
    required String newPin,
  }) {
    return _apiClient.post(ApiEndpoints.securityChangePin, body: {
      if (currentPin != null && currentPin.isNotEmpty) 'current_pin': currentPin,
      'new_pin': newPin,
    });
  }

  /// PUT /api/v1/security-settings/biometric
  Future<ApiResponse<dynamic>> updateBiometric({required bool enabled}) {
    return _apiClient.put(ApiEndpoints.securityBiometric, body: {
      'enabled': enabled,
    });
  }
}
