import '../../../../core/network/api_client.dart';
import '../models/expense_head_model.dart';
import '../models/shipment_model.dart';

class ChallanApiService {
  final ApiClient _apiClient = ApiClient();

  // 1. Expense heads
  Future<ApiResponse<List<ExpenseHeadModel>>> getExpenseHeads() async {
    final response = await _apiClient.get('/shipments/expense-heads');
    if (response.success && response.data != null) {
      final list = (response.data as List).map((e) => ExpenseHeadModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, message: response.message, data: list);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  // 2. Shipments list
  Future<ApiResponse<List<ShipmentModel>>> getShipments({String? status, String? search}) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'all') query['status'] = status;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _apiClient.get('/shipments', queryParams: query);
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

  // 3. Single Shipment details
  Future<ApiResponse<ShipmentModel>> getShipment(int id) async {
    final response = await _apiClient.get('/shipments/$id');
    if (response.success && response.data != null) {
      final model = ShipmentModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: response.message, data: model);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  // 4. Create shipment / challan
  Future<ApiResponse<ShipmentModel>> createShipment(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/shipments', body: data);
    if (response.success && response.data != null) {
      final model = ShipmentModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: response.message, data: model);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  // 5. Dispatch shipment (Transition to In-Transit / Dispatched)
  Future<ApiResponse<ShipmentModel>> dispatchShipment(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.post('/shipments/$id/dispatch', body: data);
    if (response.success && response.data != null) {
      final model = ShipmentModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: response.message, data: model);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  // 6. Receive at Arat (Record actual arrival weight & shortage)
  Future<ApiResponse<ShipmentModel>> receiveShipment(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.post('/shipments/$id/receive', body: data);
    if (response.success && response.data != null) {
      final model = ShipmentModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: response.message, data: model);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  // 7. Get multi-date arat sales list
  Future<ApiResponse<List<ShipmentSaleModel>>> getSales(int shipmentId) async {
    final response = await _apiClient.get('/shipments/$shipmentId/sales');
    if (response.success && response.data != null) {
      List<dynamic> items = [];
      if (response.data is List) {
        items = response.data;
      } else if (response.data is Map && response.data['data'] is List) {
        items = response.data['data'] as List;
      }
      final list = items.map((e) => ShipmentSaleModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, message: response.message, data: list);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  // 8. Record daily partial sale at arat
  Future<ApiResponse<ShipmentSaleModel>> recordSale(int shipmentId, Map<String, dynamic> data) async {
    final response = await _apiClient.post('/shipments/$shipmentId/sales', body: data);
    if (response.success && response.data != null) {
      final model = ShipmentSaleModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(success: true, message: response.message, data: model);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  // 9. Get Delivery Challan printable data
  Future<ApiResponse<Map<String, dynamic>>> getChallanData(int shipmentId) async {
    final response = await _apiClient.get('/shipments/$shipmentId/challan');
    if (response.success && response.data != null) {
      return ApiResponse(success: true, message: response.message, data: response.data as Map<String, dynamic>);
    }
    return ApiResponse(success: false, message: response.message, errors: response.errors);
  }

  // 10. Delete draft shipment
  Future<ApiResponse<dynamic>> deleteShipment(int id) async {
    return await _apiClient.delete('/shipments/$id');
  }
}