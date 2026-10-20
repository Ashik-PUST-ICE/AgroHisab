import '../../../../core/network/api_client.dart';
import '../models/remittance_model.dart';

class RemittanceApiService {
  final ApiClient _client = ApiClient();

  Future<List<AratdarRemittanceModel>> getRemittances() async {
    final res = await _client.get('/payments/aratdar-remittance');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => AratdarRemittanceModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createRemittance(Map<String, dynamic> body) async {
    final res = await _client.post('/payments/aratdar-remittance', body: body);
    return res.success;
  }
}