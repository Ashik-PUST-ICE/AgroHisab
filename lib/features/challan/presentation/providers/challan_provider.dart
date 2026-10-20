import 'package:flutter/material.dart';
import '../../data/models/expense_head_model.dart';
import '../../data/models/shipment_model.dart';
import '../../data/services/challan_api_service.dart';

class ChallanProvider extends ChangeNotifier {
  final ChallanApiService _apiService = ChallanApiService();

  List<ShipmentModel> _shipments = [];
  List<ExpenseHeadModel> _expenseHeads = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ShipmentModel> get shipments => _shipments;
  List<ExpenseHeadModel> get expenseHeads => _expenseHeads;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchExpenseHeads() async {
    if (_expenseHeads.isNotEmpty) return;
    final res = await _apiService.getExpenseHeads();
    if (res.success && res.data != null) {
      _expenseHeads = res.data!;
      notifyListeners();
    }
  }

  Future<void> fetchShipments({String? status, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.getShipments(status: status, search: search);
      if (res.success && res.data != null) {
        _shipments = res.data!;
      } else {
        _errorMessage = res.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createShipment(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.createShipment(data);
      if (res.success && res.data != null) {
        await fetchShipments();
        return true;
      } else {
        _errorMessage = res.message;
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
}