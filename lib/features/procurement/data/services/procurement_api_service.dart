import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/calculator_result_model.dart';
import '../models/purchase_model.dart';

class ProcurementApiService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<CalculatorResultModel>> calculate({
    required double actualWeight,
    double deductedWeight = 0,
    required double monRate,
    double monSize = 40.0,
    double paidAmount = 0,
    int? productId,
    int? supplierId,
    bool savePurchase = false,
  }) async {
    final body = {
      'actual_weight': actualWeight,
      'deducted_weight': deductedWeight,
      'mon_rate': monRate,
      'mon_size': monSize,
      'paid_amount': paidAmount,
      if (productId != null) 'product_id': productId,
      if (supplierId != null) 'supplier_id': supplierId,
      'save_purchase': savePurchase,
    };

    final response = await _apiClient.post(ApiEndpoints.calculateProcurement, body: body);

    if (response.success && response.data != null) {
      final model = CalculatorResultModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: response.message, data: model);
    }

    return ApiResponse(
      success: false,
      message: response.message,
      errors: response.errors,
    );
  }

  Future<ApiResponse<List<PurchaseModel>>> getPurchases({String? search}) async {
    final query = <String, String>{};
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _apiClient.get(ApiEndpoints.purchases, queryParams: query);

    if (response.success && response.data != null) {
      final dynamic listData = response.data;
      List<dynamic> items = [];
      if (listData is List) {
        items = listData;
      } else if (listData is Map && listData['data'] is List) {
        items = listData['data'] as List;
      }

      final list = items.map((e) => PurchaseModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, message: response.message, data: list);
    }

    return ApiResponse(
      success: false,
      message: response.message,
      errors: response.errors,
    );
  }

  // API 8: View farmer payment transaction receipts under purchase
  Future<ApiResponse<List<PurchasePaymentModel>>> getPurchasePayments(int purchaseId) async {
    final response = await _apiClient.get('/purchases/$purchaseId/payments');

    if (response.success && response.data != null) {
      List<dynamic> items = [];
      if (response.data is List) {
        items = response.data as List;
      } else if (response.data is Map && response.data['data'] is List) {
        items = response.data['data'] as List;
      }
      final list = items.map((e) => PurchasePaymentModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, message: response.message, data: list);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  // API 7: Pay farmer from selected cash/bank account
  Future<ApiResponse<PurchasePaymentModel>> storePurchasePayment(int purchaseId, Map<String, dynamic> body) async {
    final response = await _apiClient.post('/purchases/$purchaseId/payments', body: body);
    if (response.success && response.data != null) {
      final model = PurchasePaymentModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: response.message, data: model);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }
}