class NotificationModel {
  final int id;
  final String? type;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      type: json['type'],
      title: json['title'] ?? 'ব্যবসায়িক আপডেট',
      message: json['message'] ?? '',
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }
}