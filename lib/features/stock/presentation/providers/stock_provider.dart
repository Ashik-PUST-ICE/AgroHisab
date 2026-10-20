import 'package:flutter/material.dart';
import '../../data/models/stock_model.dart';
import '../../data/services/stock_api_service.dart';

class StockProvider extends ChangeNotifier {
  final StockApiService _apiService = StockApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StockBalanceModel> _balances = [];
  List<StockBalanceModel> get balances => _balances;

  List<StockMovementModel> _movements = [];
  List<StockMovementModel> get movements => _movements;

  List<StockAdjustmentModel> _adjustments = [];
  List<StockAdjustmentModel> get adjustments => _adjustments;

  Future<void> fetchStockData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.getStockBalances(),
        _apiService.getStockMovements(),
        _apiService.getStockAdjustments(),
      ]);
      _balances = results[0] as List<StockBalanceModel>;
      _movements = results[1] as List<StockMovementModel>;
      _adjustments = results[2] as List<StockAdjustmentModel>;
    } catch (e) {
      debugPrint('Error fetching stock data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordAdjustment(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.createAdjustment(body);
      if (ok) {
        await fetchStockData();
      }
      return ok;
    } catch (e) {
      debugPrint('Error recording adjustment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}