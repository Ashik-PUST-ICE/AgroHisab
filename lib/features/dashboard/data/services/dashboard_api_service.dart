import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_metrics_model.dart';

class DashboardApiService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<DashboardMetricsModel>> getMetrics() async {
    final response = await _apiClient.get(ApiEndpoints.dashboardMetrics);

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final model = DashboardMetricsModel.fromJson(data);
      return ApiResponse(success: true, message: response.message, data: model);
    }

    return ApiResponse(
      success: false,
      message: response.message,
      errors: response.errors,
    );
  }
}