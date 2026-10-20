import 'package:flutter/material.dart';
import '../../data/models/supplier_model.dart';
import '../../data/services/supplier_api_service.dart';

class SupplierProvider extends ChangeNotifier {
  final SupplierApiService _apiService = SupplierApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SupplierModel> _suppliers = [];
  List<SupplierModel> get suppliers => _suppliers;

  SupplierLedgerModel? _ledger;
  SupplierLedgerModel? get ledger => _ledger;

  SupplierModel? _selectedSupplier;
  SupplierModel? get selectedSupplier => _selectedSupplier;

  Future<void> fetchSuppliers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _suppliers = await _apiService.getSuppliers();
    } catch (e) {
      debugPrint('Error loading suppliers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSupplier(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.createSupplier(body);
      if (ok) {
        await fetchSuppliers();
      }
      return ok;
    } catch (e) {
      debugPrint('Error creating supplier: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSupplierLedger(SupplierModel supplier) async {
    _selectedSupplier = supplier;
    _isLoading = true;
    notifyListeners();
    try {
      _ledger = await _apiService.getSupplierLedger(supplier.id);
    } catch (e) {
      debugPrint('Error loading supplier ledger: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}