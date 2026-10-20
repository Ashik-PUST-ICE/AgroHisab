import '../../../../core/network/api_client.dart';
import '../models/diary_model.dart';

class DiaryApiService {
  final ApiClient _client = ApiClient();

  Future<List<DiaryEntryModel>> getEntries() async {
    final res = await _client.get('/diary');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => DiaryEntryModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createEntry(Map<String, dynamic> body) async {
    final res = await _client.post('/diary', body: body);
    return res.success;
  }

  Future<bool> deleteEntry(int id) async {
    final res = await _client.delete('/diary/$id');
    return res.success;
  }
}