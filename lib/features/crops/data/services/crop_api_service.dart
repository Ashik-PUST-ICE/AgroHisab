import '../../../../core/network/api_client.dart';
import '../models/crop_model.dart';
import '../models/product_category_model.dart';

class CropApiService {
  final ApiClient _client = ApiClient();

  Future<List<CropModel>> getCrops() async {
    final res = await _client.get('/products');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => CropModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ProductCategoryModel>> getCategories() async {
    final res = await _client.get('/product-categories');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) return list.map((e) => ProductCategoryModel.fromJson(Map<String, dynamic>.from(e))).toList();
    return [];
  }

  Future<ApiResponse<dynamic>> createCrop(Map<String, dynamic> body) {
    return _client.post('/products', body: body);
  }
}
