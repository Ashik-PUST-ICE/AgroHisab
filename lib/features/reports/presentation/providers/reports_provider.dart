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

  // API 13: Cashbook
  CashbookReportModel? _cashbook;
  bool _isCashbookLoading = false;
  CashbookReportModel? get cashbook => _cashbook;
  bool get isCashbookLoading => _isCashbookLoading;

  // API 14: Receivables Aging
  ReceivablesAgingReportModel? _receivablesAging;
  bool _isReceivablesLoading = false;
  ReceivablesAgingReportModel? get receivablesAging => _receivablesAging;
  bool get isReceivablesLoading => _isReceivablesLoading;

  // API 15: Payables Aging
  PayablesAgingReportModel? _payablesAging;
  bool _isPayablesLoading = false;
  PayablesAgingReportModel? get payablesAging => _payablesAging;
  bool get isPayablesLoading => _isPayablesLoading;

  // API 16: Sales By Product
  SalesByProductReportModel? _salesByProduct;
  bool _isSalesByProductLoading = false;
  SalesByProductReportModel? get salesByProduct => _salesByProduct;
  bool get isSalesByProductLoading => _isSalesByProductLoading;

  Future<void> fetchReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.getProfitability(),
        _apiService.getInventoryValuation(),
        _apiService.getCashbook(),
        _apiService.getReceivablesAging(),
        _apiService.getPayablesAging(),
        _apiService.getSalesByProduct(),
      ]);
      _profitability = results[0] as ProfitabilityReportModel?;
      _inventoryValuation = results[1] as List<InventoryValuationItemModel>;
      _cashbook = results[2] as CashbookReportModel?;
      _receivablesAging = results[3] as ReceivablesAgingReportModel?;
      _payablesAging = results[4] as PayablesAgingReportModel?;
      _salesByProduct = results[5] as SalesByProductReportModel?;
    } catch (e) {
      debugPrint('Error loading reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Cashbook with filters
  Future<void> fetchCashbook({int? accountId, String? fromDate, String? toDate}) async {
    _isCashbookLoading = true;
    notifyListeners();
    try {
      _cashbook = await _apiService.getCashbook(
        accountId: accountId,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      debugPrint('Error loading cashbook: $e');
    } finally {
      _isCashbookLoading = false;
      notifyListeners();
    }
  }

  // Fetch Receivables Aging with filters
  Future<void> fetchReceivablesAging({int? aratdarId}) async {
    _isReceivablesLoading = true;
    notifyListeners();
    try {
      _receivablesAging = await _apiService.getReceivablesAging(aratdarId: aratdarId);
    } catch (e) {
      debugPrint('Error loading receivables aging: $e');
    } finally {
      _isReceivablesLoading = false;
      notifyListeners();
    }
  }

  // Fetch Payables Aging with filters
  Future<void> fetchPayablesAging({int? supplierId}) async {
    _isPayablesLoading = true;
    notifyListeners();
    try {
      _payablesAging = await _apiService.getPayablesAging(supplierId: supplierId);
    } catch (e) {
      debugPrint('Error loading payables aging: $e');
    } finally {
      _isPayablesLoading = false;
      notifyListeners();
    }
  }

  // Fetch Sales By Product with filters
  Future<void> fetchSalesByProduct({
    int? productId,
    String? fromDate,
    String? toDate,
    int? aratdarId,
  }) async {
    _isSalesByProductLoading = true;
    notifyListeners();
    try {
      _salesByProduct = await _apiService.getSalesByProduct(
        productId: productId,
        fromDate: fromDate,
        toDate: toDate,
        aratdarId: aratdarId,
      );
    } catch (e) {
      debugPrint('Error loading sales by product: $e');
    } finally {
      _isSalesByProductLoading = false;
      notifyListeners();
    }
  }
}