import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/crop_model.dart';
import '../../data/services/crop_api_service.dart';
import '../../data/models/product_category_model.dart';

class CropProvider extends ChangeNotifier {
  final CropApiService _apiService = CropApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CropModel> _crops = [];
  List<CropModel> get crops => _crops;
  List<ProductCategoryModel> _categories = [];
  List<ProductCategoryModel> get categories => _categories;

  Future<void> fetchCrops() async {
    _isLoading = true;
    notifyListeners();
    try {
      _crops = await _apiService.getCrops();
    } catch (e) {
      debugPrint('Error loading crops: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _apiService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading product categories: $e');
    }
  }

  Future<bool> addCrop(Map<String, dynamic> body) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService.createCrop(body);
      if (response.success) {
        await fetchCrops();
      }
      else _errorMessage = _formatError(response);
      return response.success;
    } catch (e) {
      debugPrint('Error adding crop: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatError(ApiResponse<dynamic> response) {
    if (response.errors != null && response.errors!.isNotEmpty) {
      final first = response.errors!.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    return response.message;
  }
}
