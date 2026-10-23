import 'package:flutter/material.dart';
import '../../data/models/supplier_model.dart';
import '../../data/services/supplier_api_service.dart';

class SupplierProvider extends ChangeNotifier {
  final SupplierApiService _apiService = SupplierApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SupplierModel> _suppliers = [];
  List<SupplierModel> get suppliers => _suppliers;

  SupplierLedgerModel? _ledger;
  SupplierLedgerModel? get ledger => _ledger;

  SupplierModel? _selectedSupplier;
  SupplierModel? get selectedSupplier => _selectedSupplier;

  Future<void> fetchSuppliers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _suppliers = await _apiService.getSuppliers();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading suppliers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ensures every account has one reusable generic farmer for quick purchases.
  /// Named farmers can still be added alongside this default entry.
  Future<SupplierModel?> ensureDefaultFarmer() async {
    const defaultName = 'সাধারণ কৃষক';
    await fetchSuppliers();

    for (final supplier in _suppliers) {
      if (supplier.name.trim() == defaultName) return supplier;
    }

    final created = await createSupplier({'name': defaultName});
    if (!created) return null;
    for (final supplier in _suppliers) {
      if (supplier.name.trim() == defaultName) return supplier;
    }
    return null;
  }

  Future<bool> createSupplier(Map<String, dynamic> body) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService.createSupplier(body);
      if (response.success) {
        await fetchSuppliers();
      }
      if (!response.success) {
        _errorMessage = _formatError(response.message, response.errors);
      }
      return response.success;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error creating supplier: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatError(String message, Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return message;
    final details = errors.values
        .expand((value) => value is List ? value : [value])
        .map((value) => value.toString())
        .join('\n');
    return details.isEmpty ? message : details;
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
