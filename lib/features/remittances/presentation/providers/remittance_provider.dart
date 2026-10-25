import 'package:flutter/material.dart';
import '../../data/models/remittance_model.dart';
import '../../data/services/remittance_api_service.dart';

class RemittanceProvider extends ChangeNotifier {
  final RemittanceApiService _apiService = RemittanceApiService();

  List<AratdarRemittanceModel> _remittances = [];
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  List<AratdarRemittanceModel> get remittances => _remittances;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRemittances() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _remittances = await _apiService.getRemittances();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRemittance(Map<String, dynamic> body) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.createRemittance(body);
      if (res.success) {
        await fetchRemittances();
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

  // Allocate remittance to shipment
  Future<bool> allocateRemittance(int remittanceId, int shipmentId, double amount, {String? notes}) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.allocateRemittance(remittanceId, [
        {
          'shipment_id': shipmentId,
          'amount': amount,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        }
      ]);

      if (res.success) {
        await fetchRemittances();
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