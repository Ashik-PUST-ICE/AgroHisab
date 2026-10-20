import 'package:flutter/material.dart';
import '../../data/models/storage_model.dart';
import '../../data/services/storage_api_service.dart';

class StorageProvider extends ChangeNotifier {
  final StorageApiService _apiService = StorageApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StorageInfoModel? _info;
  StorageInfoModel? get info => _info;

  StorageTestResultModel? _testResult;
  StorageTestResultModel? get testResult => _testResult;

  Future<void> fetchStorageInfo() async {
    _isLoading = true;
    notifyListeners();
    try {
      _info = await _apiService.getStorageInfo();
    } catch (e) {
      debugPrint('Error loading storage info: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> testConnection() async {
    _isLoading = true;
    notifyListeners();
    try {
      _testResult = await _apiService.testStorageConnection();
    } catch (e) {
      debugPrint('Error testing storage connection: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}