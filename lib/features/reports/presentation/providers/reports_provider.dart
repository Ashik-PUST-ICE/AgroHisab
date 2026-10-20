import 'package:flutter/material.dart';
import '../../data/models/reports_model.dart';
import '../../data/services/reports_api_service.dart';

class ReportsProvider extends ChangeNotifier {
  final ReportsApiService _apiService = ReportsApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProfitabilityReportModel? _profitability;
  ProfitabilityReportModel? get profitability => _profitability;

  List<InventoryValuationItemModel> _inventoryValuation = [];
  List<InventoryValuationItemModel> get inventoryValuation => _inventoryValuation;

  Future<void> fetchReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.getProfitability(),
        _apiService.getInventoryValuation(),
      ]);
      _profitability = results[0] as ProfitabilityReportModel?;
      _inventoryValuation = results[1] as List<InventoryValuationItemModel>;
    } catch (e) {
      debugPrint('Error loading reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}