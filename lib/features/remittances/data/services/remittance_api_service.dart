import '../../../../core/network/api_client.dart';
import '../models/remittance_model.dart';

class RemittanceApiService {
  final ApiClient _client = ApiClient();

  Future<List<AratdarRemittanceModel>> getRemittances() async {
    final res = await _client.get('/payments/aratdar-remittance');
    final data = res.data;
    List<dynamic> items = [];
    if (data is List) {
      items = data;
    } else if (data is Map && data['data'] is List) {
      items = data['data'] as List;
    }
    return items.map((e) => AratdarRemittanceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ApiResponse<AratdarRemittanceModel>> createRemittance(Map<String, dynamic> body) async {
    final res = await _client.post('/payments/aratdar-remittance', body: body);
    if (res.success && res.data != null) {
      final model = AratdarRemittanceModel.fromJson(res.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: res.message, data: model);
    }
    return ApiResponse(success: false, message: res.message, errors: res.errors);
  }

  // API 5: Allocate remittance across specific open shipments
  Future<ApiResponse<AratdarRemittanceModel>> allocateRemittance(
    int remittanceId,
    List<Map<String, dynamic>> allocations,
  ) async {
    final res = await _client.post('/payments/$remittanceId/allocate', body: {
      'allocations': allocations,
    });
    if (res.success && res.data != null) {
      final model = AratdarRemittanceModel.fromJson(res.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: res.message, data: model);
    }
    return ApiResponse(success: false, message: res.message, errors: res.errors);
  }
}