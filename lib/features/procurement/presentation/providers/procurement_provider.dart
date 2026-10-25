import 'package:flutter/material.dart';
import '../../data/models/calculator_result_model.dart';
import '../../data/models/purchase_model.dart';
import '../../data/services/procurement_api_service.dart';

class ProcurementProvider extends ChangeNotifier {
  final ProcurementApiService _apiService = ProcurementApiService();

  List<PurchaseModel> _purchases = [];
  List<PurchasePaymentModel> _purchasePayments = [];
  CalculatorResultModel? _lastResult;
  bool _isLoading = false;
  bool _isPaymentLoading = false;
  String? _errorMessage;

  List<PurchaseModel> get purchases => _purchases;
  List<PurchasePaymentModel> get purchasePayments => _purchasePayments;
  CalculatorResultModel? get lastResult => _lastResult;
  CalculatorResultModel? get calculationResult => _lastResult;
  bool get isLoading => _isLoading;
  bool get isPaymentLoading => _isPaymentLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> calculate({
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
        _lastResult = response.data;
        if (savePurchase) {
          await fetchPurchases();
        }
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  // Fetch payments for a purchase
  Future<void> fetchPurchasePayments(int purchaseId) async {
    _isPaymentLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getPurchasePayments(purchaseId);
      if (response.success && response.data != null) {
        _purchasePayments = response.data!;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  // Store farmer payment under purchase
  Future<bool> storePurchasePayment(int purchaseId, {
    required int accountId,
    required double amount,
    required String paymentDate,
    String? referenceNumber,
    String? notes,
  }) async {
    _isPaymentLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.storePurchasePayment(purchaseId, {
        'account_id': accountId,
        'amount': amount,
        'payment_date': paymentDate,
        if (referenceNumber != null && referenceNumber.isNotEmpty) 'reference_number': referenceNumber,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });

      if (response.success) {
        await fetchPurchasePayments(purchaseId);
        await fetchPurchases();
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }
}