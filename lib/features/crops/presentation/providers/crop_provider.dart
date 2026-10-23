import 'package:flutter/material.dart';
import '../../data/models/crop_model.dart';
import '../../data/services/crop_api_service.dart';
import '../../data/models/product_category_model.dart';

class CropProvider extends ChangeNotifier {
  final CropApiService _apiService = CropApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
    notifyListeners();
    try {
      final ok = await _apiService.createCrop(body);
      if (ok) {
        await fetchCrops();
      }
      return ok;
    } catch (e) {
      debugPrint('Error adding crop: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
