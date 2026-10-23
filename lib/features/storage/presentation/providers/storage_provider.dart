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

  String? _message;
  String? get message => _message;
  bool _lastActionSuccessful = false;
  bool get lastActionSuccessful => _lastActionSuccessful;

  void clearMessage() {
    _message = null;
    notifyListeners();
  }

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
      _message = _testResult?.message;
      _lastActionSuccessful = _testResult?.status == 'success';
    } catch (e) {
      debugPrint('Error testing storage connection: $e');
      _message = e.toString();
      _lastActionSuccessful = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings({required String provider, Map<String, dynamic>? credentials, String? root, String? publicUrl}) async {
    _isLoading = true;
    _message = null;
    notifyListeners();
    try {
      final response = await _apiService.updateSettings(provider: provider, credentials: credentials, root: root, publicUrl: publicUrl);
      _lastActionSuccessful = response.success;
      _message = response.message;
      if (response.success) await fetchStorageInfo();
    } catch (e) {
      debugPrint('Error updating storage provider: $e');
      _message = e.toString();
      _lastActionSuccessful = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
