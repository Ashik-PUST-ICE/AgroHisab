import '../../../../core/network/api_client.dart';
import '../models/market_model.dart';
import '../models/price_observation_model.dart';

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

  // API 9: GET /api/v1/markets/{market}/price-observations
  Future<List<PriceObservationModel>> getPriceObservations(
    int marketId, {
    int? productId,
    String? fromDate,
    String? toDate,
  }) async {
    final Map<String, String> query = {};
    if (productId != null) query['product_id'] = productId.toString();
    if (fromDate != null && fromDate.isNotEmpty) query['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) query['to_date'] = toDate;

    final res = await _client.get(
      '/markets/$marketId/price-observations',
      queryParams: query.isNotEmpty ? query : null,
    );
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => PriceObservationModel.fromJson(e)).toList();
    }
    return [];
  }

  // API 10: POST /api/v1/markets/{market}/price-observations
  Future<bool> storePriceObservation(int marketId, Map<String, dynamic> body) async {
    final res = await _client.post('/markets/$marketId/price-observations', body: body);
    return res.success;
  }

  // API 24: DELETE /api/v1/price-observations/{priceObservation}
  Future<bool> deletePriceObservation(int observationId) async {
    final res = await _client.delete('/price-observations/$observationId');
    return res.success;
  }
}