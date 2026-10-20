import '../../../../core/network/api_client.dart';
import '../models/document_model.dart';

class DocumentApiService {
  final ApiClient _client = ApiClient();

  Future<List<DocumentModel>> getDocuments() async {
    final res = await _client.get('/documents');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => DocumentModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createDocument(Map<String, dynamic> body) async {
    final res = await _client.post('/documents', body: body);
    return res.success;
  }

  Future<bool> deleteDocument(int id) async {
    final res = await _client.delete('/documents/$id');
    return res.success;
  }
}