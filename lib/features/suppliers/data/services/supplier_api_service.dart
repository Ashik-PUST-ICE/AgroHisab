import '../../../../core/network/api_client.dart';
import '../models/supplier_model.dart';

class SupplierApiService {
  final ApiClient _client = ApiClient();

  Future<List<SupplierModel>> getSuppliers() async {
    final res = await _client.get('/suppliers');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => SupplierModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<ApiResponse<dynamic>> createSupplier(Map<String, dynamic> body) async {
    return _client.post('/suppliers', body: body);
  }

  Future<SupplierLedgerModel?> getSupplierLedger(int id) async {
    final res = await _client.get('/suppliers/$id/ledger');
    if (res.data != null && res.data is Map<String, dynamic>) {
      return SupplierLedgerModel.fromJson(res.data);
    }
    return null;
  }
}
