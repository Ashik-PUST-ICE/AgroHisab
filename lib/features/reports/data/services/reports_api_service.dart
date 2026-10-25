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

  // API 13: GET /api/v1/reports/cashbook
  Future<CashbookReportModel?> getCashbook({
    int? accountId,
    String? fromDate,
    String? toDate,
  }) async {
    final Map<String, String> query = {};
    if (accountId != null) query['account_id'] = accountId.toString();
    if (fromDate != null && fromDate.isNotEmpty) query['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) query['to_date'] = toDate;

    final res = await _client.get('/reports/cashbook', queryParams: query.isNotEmpty ? query : null);
    if (res.success && res.data != null) {
      final map = res.data is Map && res.data['data'] != null ? res.data['data'] : res.data;
      if (map is Map<String, dynamic>) {
        return CashbookReportModel.fromJson(map);
      }
    }
    return null;
  }

  // API 14: GET /api/v1/reports/receivables
  Future<ReceivablesAgingReportModel?> getReceivablesAging({
    int? aratdarId,
  }) async {
    final Map<String, String> query = {};
    if (aratdarId != null) query['aratdar_id'] = aratdarId.toString();

    final res = await _client.get('/reports/receivables', queryParams: query.isNotEmpty ? query : null);
    if (res.success && res.data != null) {
      final map = res.data is Map && res.data['data'] != null ? res.data['data'] : res.data;
      if (map is Map<String, dynamic>) {
        return ReceivablesAgingReportModel.fromJson(map);
      }
    }
    return null;
  }

  // API 15: GET /api/v1/reports/payables
  Future<PayablesAgingReportModel?> getPayablesAging({
    int? supplierId,
  }) async {
    final Map<String, String> query = {};
    if (supplierId != null) query['supplier_id'] = supplierId.toString();

    final res = await _client.get('/reports/payables', queryParams: query.isNotEmpty ? query : null);
    if (res.success && res.data != null) {
      final map = res.data is Map && res.data['data'] != null ? res.data['data'] : res.data;
      if (map is Map<String, dynamic>) {
        return PayablesAgingReportModel.fromJson(map);
      }
    }
    return null;
  }

  // API 16: GET /api/v1/reports/sales-by-product
  Future<SalesByProductReportModel?> getSalesByProduct({
    int? productId,
    String? fromDate,
    String? toDate,
    int? aratdarId,
  }) async {
    final Map<String, String> query = {};
    if (productId != null) query['product_id'] = productId.toString();
    if (fromDate != null && fromDate.isNotEmpty) query['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) query['to_date'] = toDate;
    if (aratdarId != null) query['aratdar_id'] = aratdarId.toString();

    final res = await _client.get('/reports/sales-by-product', queryParams: query.isNotEmpty ? query : null);
    if (res.success && res.data != null) {
      final map = res.data is Map && res.data['data'] != null ? res.data['data'] : res.data;
      if (map is Map<String, dynamic>) {
        return SalesByProductReportModel.fromJson(map);
      }
    }
    return null;
  }
}