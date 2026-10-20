import '../../../../core/network/api_client.dart';
import '../models/crop_model.dart';

class CropApiService {
  final ApiClient _client = ApiClient();

  Future<List<CropModel>> getCrops() async {
    final res = await _client.get('/products');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => CropModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createCrop(Map<String, dynamic> body) async {
    final res = await _client.post('/products', body: body);
    return res.success;
  }
}