import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationApiService _apiService = NotificationApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _apiService.getNotifications();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _apiService.markAllRead();
    await fetchNotifications();
  }
}