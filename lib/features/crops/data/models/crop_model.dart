class CropModel {
  final int id;
  final String name;
  final String? variety;
  final String? description;
  final int status;
  final String statusLabel;

  CropModel({
    required this.id,
    required this.name,
    this.variety,
    this.description,
    required this.status,
    required this.statusLabel,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      variety: json['variety'],
      description: json['description'],
      status: (json['status'] as num?)?.toInt() ?? 1,
      statusLabel: json['status_label'] ?? 'সক্রিয়',
    );
  }
}