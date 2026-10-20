import 'package:flutter/material.dart';
import '../../data/models/calculator_result_model.dart';
import '../../data/models/purchase_model.dart';
import '../../data/services/procurement_api_service.dart';

class ProcurementProvider extends ChangeNotifier {
  final ProcurementApiService _apiService = ProcurementApiService();

  List<PurchaseModel> _purchases = [];
  CalculatorResultModel? _calculationResult;
  bool _isLoading = false;
  String? _errorMessage;

  List<PurchaseModel> get purchases => _purchases;
  CalculatorResultModel? get calculationResult => _calculationResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPurchases({String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getPurchases(search: search);
      if (response.success && response.data != null) {
        _purchases = response.data!;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CalculatorResultModel?> calculate({
    required double actualWeight,
    double deductedWeight = 0,
    required double monRate,
    double monSize = 40.0,
    double paidAmount = 0,
    int? productId,
    int? supplierId,
    bool savePurchase = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.calculate(
        actualWeight: actualWeight,
        deductedWeight: deductedWeight,
        monRate: monRate,
        monSize: monSize,
        paidAmount: paidAmount,
        productId: productId,
        supplierId: supplierId,
        savePurchase: savePurchase,
      );

      if (response.success && response.data != null) {
        _calculationResult = response.data;
        if (savePurchase) {
          fetchPurchases(); // refresh purchases list
        }
        return _calculationResult;
      } else {
        _errorMessage = response.message;
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}