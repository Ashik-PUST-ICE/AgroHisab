import 'package:flutter/material.dart';
import '../../data/models/expense_head_model.dart';
import '../../data/models/shipment_model.dart';
import '../../data/services/challan_api_service.dart';

class ChallanProvider extends ChangeNotifier {
  final ChallanApiService _apiService = ChallanApiService();

  List<ShipmentModel> _shipments = [];
  List<ExpenseHeadModel> _expenseHeads = [];
  ShipmentModel? _selectedShipment;
  List<ShipmentSaleModel> _shipmentSales = [];
  Map<String, dynamic>? _challanPrintData;

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  List<ShipmentModel> get shipments => _shipments;
  List<ExpenseHeadModel> get expenseHeads => _expenseHeads;
  ShipmentModel? get selectedShipment => _selectedShipment;
  List<ShipmentSaleModel> get shipmentSales => _shipmentSales;
  Map<String, dynamic>? get challanPrintData => _challanPrintData;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
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

  Future<void> fetchShipmentDetails(int id) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.getShipment(id);
      if (res.success && res.data != null) {
        _selectedShipment = res.data!;
        // Also fetch sales for this shipment
        final salesRes = await _apiService.getSales(id);
        if (salesRes.success && salesRes.data != null) {
          _shipmentSales = salesRes.data!;
        }
      } else {
        _errorMessage = res.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createShipment(Map<String, dynamic> data) async {
    _isActionLoading = true;
    _errorMessage = null;
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
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> dispatchShipment(int id, {required String dispatchDate, String? vehicleNumber, String? notes}) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.dispatchShipment(id, {
        'dispatch_date': dispatchDate,
        if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
        if (notes != null) 'notes': notes,
      });

      if (res.success && res.data != null) {
        _selectedShipment = res.data!;
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
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> receiveShipment(int id, {required String receivedDate, required List<Map<String, dynamic>> items, String? notes}) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.receiveShipment(id, {
        'received_date': receivedDate,
        'items': items,
        if (notes != null) 'notes': notes,
      });

      if (res.success && res.data != null) {
        _selectedShipment = res.data!;
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
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordSale(int shipmentId, Map<String, dynamic> data) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.recordSale(shipmentId, data);
      if (res.success && res.data != null) {
        await fetchShipmentDetails(shipmentId);
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
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChallanPrintData(int shipmentId) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.getChallanData(shipmentId);
      if (res.success && res.data != null) {
        _challanPrintData = res.data!;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteShipment(int id) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.deleteShipment(id);
      if (res.success) {
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
      _isActionLoading = false;
      notifyListeners();
    }
  }
}