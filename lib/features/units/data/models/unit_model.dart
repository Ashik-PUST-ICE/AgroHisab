class UnitModel {
  final int id;
  final String name;
  final String code;
  final bool isBaseUnit;

  UnitModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isBaseUnit,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      isBaseUnit: json['is_base_unit'] == true || json['is_base_unit'] == 1,
    );
  }
}