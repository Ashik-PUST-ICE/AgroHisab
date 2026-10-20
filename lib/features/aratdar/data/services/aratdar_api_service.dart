import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
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
}