class ProductCategoryModel {
  final int id;
  final String name;
  final String? description;
  final int status;

  ProductCategoryModel({required this.id, required this.name, this.description, required this.status});

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) => ProductCategoryModel(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
    name: json['name'] ?? '',
    description: json['description'],
    status: (json['status'] as num?)?.toInt() ?? 1,
  );
}
