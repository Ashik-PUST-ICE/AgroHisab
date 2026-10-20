import 'package:flutter/material.dart';
import '../../data/models/remittance_model.dart';
import '../../data/services/remittance_api_service.dart';

class RemittanceProvider extends ChangeNotifier {
  final RemittanceApiService _apiService = RemittanceApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AratdarRemittanceModel> _remittances = [];
  List<AratdarRemittanceModel> get remittances => _remittances;

  Future<void> fetchRemittances() async {
    _isLoading = true;
    notifyListeners();
    try {
      _remittances = await _apiService.getRemittances();
    } catch (e) {
      debugPrint('Error fetching remittances: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordRemittance(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.createRemittance(body);
      if (ok) {
        await fetchRemittances();
      }
      return ok;
    } catch (e) {
      debugPrint('Error recording remittance: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}