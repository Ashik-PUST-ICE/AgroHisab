import '../../../../core/network/api_client.dart';
import '../models/stock_model.dart';

class StockApiService {
  final ApiClient _client = ApiClient();

  Future<List<StockBalanceModel>> getStockBalances() async {
    final res = await _client.get('/stock-movements/balance');
    final data = res.data;
    if (data is List) {
      return data.map((e) => StockBalanceModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<StockMovementModel>> getStockMovements() async {
    final res = await _client.get('/stock-movements');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => StockMovementModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<StockAdjustmentModel>> getStockAdjustments() async {
    final res = await _client.get('/stock-adjustments');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => StockAdjustmentModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createAdjustment(Map<String, dynamic> body) async {
    final res = await _client.post('/stock-adjustments', body: body);
    return res.success;
  }
}