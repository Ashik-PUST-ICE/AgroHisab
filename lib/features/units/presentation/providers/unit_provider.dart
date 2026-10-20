import 'package:flutter/material.dart';
import '../../data/models/unit_model.dart';
import '../../data/services/unit_api_service.dart';

class UnitProvider extends ChangeNotifier {
  final UnitApiService _apiService = UnitApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<UnitModel> _units = [];
  List<UnitModel> get units => _units;

  Future<void> fetchUnits() async {
    _isLoading = true;
    notifyListeners();
    try {
      _units = await _apiService.getUnits();
    } catch (e) {
      debugPrint('Error loading units: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}