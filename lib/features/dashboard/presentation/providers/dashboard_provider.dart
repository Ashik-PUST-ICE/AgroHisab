import 'package:flutter/material.dart';
import '../../data/models/dashboard_metrics_model.dart';
import '../../data/services/dashboard_api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardApiService _apiService = DashboardApiService();

  DashboardMetricsModel? _metrics;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardMetricsModel? get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMetrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getMetrics();
      if (response.success && response.data != null) {
        _metrics = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'মেট্রিক্স লোড করতে ব্যর্থ হয়েছে: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}