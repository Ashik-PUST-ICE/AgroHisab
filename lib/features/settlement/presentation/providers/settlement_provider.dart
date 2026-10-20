import 'package:flutter/material.dart';
import '../../data/models/settlement_preview_model.dart';
import '../../data/services/settlement_api_service.dart';

class SettlementProvider extends ChangeNotifier {
  final SettlementApiService _apiService = SettlementApiService();

  SettlementPreviewModel? _preview;
  bool _isLoading = false;
  String? _errorMessage;

  SettlementPreviewModel? get preview => _preview;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPreview(int shipmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.getSettlementPreview(shipmentId);
      if (res.success && res.data != null) {
        _preview = res.data;
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
}