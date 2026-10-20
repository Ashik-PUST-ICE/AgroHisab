import 'package:flutter/material.dart';
import '../../data/models/document_model.dart';
import '../../data/services/document_api_service.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentApiService _apiService = DocumentApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<DocumentModel> _documents = [];
  List<DocumentModel> get documents => _documents;

  Future<void> fetchDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      _documents = await _apiService.getDocuments();
    } catch (e) {
      debugPrint('Error loading documents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDocument(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.createDocument(body);
      if (ok) {
        await fetchDocuments();
      }
      return ok;
    } catch (e) {
      debugPrint('Error adding document: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}