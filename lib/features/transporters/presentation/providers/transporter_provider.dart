import 'package:flutter/material.dart';
import '../../data/models/transporter_model.dart';
import '../../data/services/transporter_api_service.dart';

class TransporterProvider extends ChangeNotifier {
  final TransporterApiService _apiService = TransporterApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TransporterModel> _transporters = [];
  List<TransporterModel> get transporters => _transporters;

  Future<void> fetchTransporters() async {
    _isLoading = true;
    notifyListeners();
    try {
      _transporters = await _apiService.getTransporters();
    } catch (e) {
      debugPrint('Error loading transporters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransporter(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.createTransporter(body);
      if (ok) {
        await fetchTransporters();
      }
      return ok;
    } catch (e) {
      debugPrint('Error creating transporter: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}