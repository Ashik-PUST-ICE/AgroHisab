import '../../../../core/network/api_client.dart';
import '../models/settlement_preview_model.dart';

class SettlementApiService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<SettlementPreviewModel>> getSettlementPreview(int shipmentId) async {
    final res = await _apiClient.get('/shipments/$shipmentId/settlement-preview');
    if (res.success && res.data != null) {
      final model = SettlementPreviewModel.fromJson(res.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: res.message, data: model);
    }
    return ApiResponse(success: false, message: res.message, errors: res.errors);
  }
}