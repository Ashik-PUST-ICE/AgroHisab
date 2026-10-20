import 'package:flutter/material.dart';
import '../../data/models/aratdar_model.dart';
import '../../data/services/aratdar_api_service.dart';

class AratdarProvider extends ChangeNotifier {
  final AratdarApiService _apiService = AratdarApiService();

  List<AratdarModel> _aratdars = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AratdarModel> get aratdars => _aratdars;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAratdars() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.getAratdars();
      if (res.success && res.data != null) {
        _aratdars = res.data!;
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