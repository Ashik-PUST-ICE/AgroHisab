import 'package:flutter/material.dart';
import '../../data/models/aratdar_agreement_model.dart';
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

  // Agreement state
  AratdarAgreementModel? _currentAgreement;
  bool _isAgreementLoading = false;
  String? _agreementError;

  AratdarAgreementModel? get currentAgreement => _currentAgreement;
  bool get isAgreementLoading => _isAgreementLoading;
  String? get agreementError => _agreementError;

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

  // API 11: Fetch Agreement
  Future<void> fetchAgreement(int aratdarId) async {
    _isAgreementLoading = true;
    _agreementError = null;
    _currentAgreement = null;
    notifyListeners();

    try {
      final res = await _apiService.getAgreement(aratdarId);
      if (res.success && res.data != null) {
        _currentAgreement = res.data;
      } else {
        _agreementError = res.message;
      }
    } catch (e) {
      _agreementError = e.toString();
    } finally {
      _isAgreementLoading = false;
      notifyListeners();
    }
  }

  // API 12: Update Agreement
  Future<bool> updateAgreement(int aratdarId, Map<String, dynamic> body) async {
    _isAgreementLoading = true;
    _agreementError = null;
    notifyListeners();

    try {
      final res = await _apiService.updateAgreement(aratdarId, body);
      if (res.success && res.data != null) {
        _currentAgreement = res.data;
        // Also refresh list to reflect new commission rate
        await fetchAratdars();
        return true;
      } else {
        _agreementError = res.message;
        return false;
      }
    } catch (e) {
      _agreementError = e.toString();
      return false;
    } finally {
      _isAgreementLoading = false;
      notifyListeners();
    }
  }
}