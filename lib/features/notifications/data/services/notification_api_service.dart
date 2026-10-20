import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationApiService {
  final ApiClient _client = ApiClient();

  Future<List<NotificationModel>> getNotifications() async {
    final res = await _client.get('/notifications');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> markAllRead() async {
    final res = await _client.post('/notifications/read-all');
    return res.success;
  }
}