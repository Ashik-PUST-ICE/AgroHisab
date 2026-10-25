import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/aratdar_agreement_model.dart';
import '../models/aratdar_model.dart';

class AratdarApiService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<AratdarModel>>> getAratdars() async {
    final res = await _apiClient.get(ApiEndpoints.aratdars);
    if (res.success && res.data != null) {
      List<dynamic> items = [];
      if (res.data is List) {
        items = res.data;
      } else if (res.data is Map && res.data['data'] is List) {
        items = res.data['data'] as List;
      }
      final list = items.map((e) => AratdarModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, message: res.message, data: list);
    }
    return ApiResponse(success: false, message: res.message, errors: res.errors);
  }

  // API 11: GET /api/v1/aratdars/{aratdar}/agreement
  Future<ApiResponse<AratdarAgreementModel>> getAgreement(int aratdarId) async {
    final res = await _apiClient.get('${ApiEndpoints.aratdars}/$aratdarId/agreement');
    if (res.success && res.data != null) {
      final map = res.data is Map && res.data['data'] != null ? res.data['data'] : res.data;
      if (map is Map<String, dynamic>) {
        return ApiResponse(
          success: true,
          message: res.message,
          data: AratdarAgreementModel.fromJson(map),
        );
      }
    }
    return ApiResponse(success: false, message: res.message, errors: res.errors);
  }

  // API 12: PUT /api/v1/aratdars/{aratdar}/agreement
  Future<ApiResponse<AratdarAgreementModel>> updateAgreement(
    int aratdarId,
    Map<String, dynamic> body,
  ) async {
    final res = await _apiClient.put('${ApiEndpoints.aratdars}/$aratdarId/agreement', body: body);
    if (res.success && res.data != null) {
      final map = res.data is Map && res.data['data'] != null ? res.data['data'] : res.data;
      if (map is Map<String, dynamic>) {
        return ApiResponse(
          success: true,
          message: res.message,
          data: AratdarAgreementModel.fromJson(map),
        );
      }
    }
    return ApiResponse(success: false, message: res.message, errors: res.errors);
  }
}