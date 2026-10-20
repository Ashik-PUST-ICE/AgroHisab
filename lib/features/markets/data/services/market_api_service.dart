import '../../../../core/network/api_client.dart';
import '../models/market_model.dart';

class MarketApiService {
  final ApiClient _client = ApiClient();

  Future<List<MarketModel>> getMarkets() async {
    final res = await _client.get('/markets');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => MarketModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createMarket(Map<String, dynamic> body) async {
    final res = await _client.post('/markets', body: body);
    return res.success;
  }
}