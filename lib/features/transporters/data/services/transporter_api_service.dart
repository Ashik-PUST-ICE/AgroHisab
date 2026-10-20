import '../../../../core/network/api_client.dart';
import '../models/transporter_model.dart';

class TransporterApiService {
  final ApiClient _client = ApiClient();

  Future<List<TransporterModel>> getTransporters() async {
    final res = await _client.get('/transporters');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => TransporterModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createTransporter(Map<String, dynamic> body) async {
    final res = await _client.post('/transporters', body: body);
    return res.success;
  }
}