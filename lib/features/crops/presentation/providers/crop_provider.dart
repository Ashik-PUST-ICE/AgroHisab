import 'package:flutter/material.dart';
import '../../data/models/crop_model.dart';
import '../../data/services/crop_api_service.dart';

class CropProvider extends ChangeNotifier {
  final CropApiService _apiService = CropApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CropModel> _crops = [];
  List<CropModel> get crops => _crops;

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