import '../../../../core/network/api_client.dart';
import '../models/unit_model.dart';

class UnitApiService {
  final ApiClient _client = ApiClient();

  Future<List<UnitModel>> getUnits() async {
    final res = await _client.get('/units');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => UnitModel.fromJson(e)).toList();
    }
    return [];
  }
}