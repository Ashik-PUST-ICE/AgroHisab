import '../../../../core/network/api_client.dart';
import '../models/reports_model.dart';

class ReportsApiService {
  final ApiClient _client = ApiClient();

  Future<ProfitabilityReportModel?> getProfitability() async {
    final res = await _client.get('/reports/profitability');
    if (res.data != null && res.data is Map<String, dynamic>) {
      return ProfitabilityReportModel.fromJson(res.data);
    }
    return null;
  }

  Future<List<InventoryValuationItemModel>> getInventoryValuation() async {
    final res = await _client.get('/reports/inventory-valuation');
    final data = res.data;
    final list = data is Map ? (data['items'] ?? data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => InventoryValuationItemModel.fromJson(e)).toList();
    }
    return [];
  }
}