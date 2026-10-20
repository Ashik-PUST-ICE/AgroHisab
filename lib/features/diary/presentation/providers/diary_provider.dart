import 'package:flutter/material.dart';
import '../../data/models/diary_model.dart';
import '../../data/services/diary_api_service.dart';

class DiaryProvider extends ChangeNotifier {
  final DiaryApiService _apiService = DiaryApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<DiaryEntryModel> _entries = [];
  List<DiaryEntryModel> get entries => _entries;

  Future<void> fetchEntries() async {
    _isLoading = true;
    notifyListeners();
    try {
      _entries = await _apiService.getEntries();
    } catch (e) {
      debugPrint('Error loading diary: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEntry(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.createEntry(body);
      if (ok) {
        await fetchEntries();
      }
      return ok;
    } catch (e) {
      debugPrint('Error adding diary: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEntry(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.deleteEntry(id);
      if (ok) {
        await fetchEntries();
      }
      return ok;
    } catch (e) {
      debugPrint('Error deleting diary: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}