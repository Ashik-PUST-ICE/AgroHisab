class DiaryEntryModel {
  final int id;
  final String title;
  final String? notes;
  final String? eventType;
  final String eventDate;
  final String? createdAt;

  DiaryEntryModel({
    required this.id,
    required this.title,
    this.notes,
    this.eventType,
    required this.eventDate,
    this.createdAt,
  });

  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DiaryEntryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      notes: json['notes'],
      eventType: json['event_type'] ?? 'general',
      eventDate: json['event_date'] ?? json['created_at'] ?? '',
      createdAt: json['created_at'],
    );
  }
}