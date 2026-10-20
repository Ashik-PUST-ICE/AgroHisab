import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/expense_head_model.dart';
import '../models/shipment_model.dart';

class ChallanApiService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<ExpenseHeadModel>>> getExpenseHeads() async {
    final response = await _apiClient.get(ApiEndpoints.shipmentExpenseHeads);
    if (response.success && response.data != null) {
      final list = (response.data as List).map((e) => ExpenseHeadModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, message: response.message, data: list);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  Future<ApiResponse<List<ShipmentModel>>> getShipments({String? status, String? search}) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (search != null) query['search'] = search;

    final response = await _apiClient.get(ApiEndpoints.shipments, queryParams: query);
    if (response.success && response.data != null) {
      List<dynamic> items = [];
      if (response.data is List) {
        items = response.data;
      } else if (response.data is Map && response.data['data'] is List) {
        items = response.data['data'] as List;
      }
      final list = items.map((e) => ShipmentModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, message: response.message, data: list);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  Future<ApiResponse<ShipmentModel>> createShipment(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiEndpoints.shipments, body: data);
    if (response.success && response.data != null) {
      final model = ShipmentModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: response.message, data: model);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }
}