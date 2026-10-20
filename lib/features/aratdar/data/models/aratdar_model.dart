class AratdarModel {
  final int id;
  final String name;
  final String? businessName;
  final String? phone;
  final String? market;
  final String? district;
  final int commissionType;
  final double commissionValue;

  AratdarModel({
    required this.id,
    required this.name,
    this.businessName,
    this.phone,
    this.market,
    this.district,
    required this.commissionType,
    required this.commissionValue,
  });

  factory AratdarModel.fromJson(Map<String, dynamic> json) {
    return AratdarModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? 'আড়তদার',
      businessName: json['business_name'] ?? json['market'] ?? '',
      phone: json['phone'] ?? '',
      market: json['market'] ?? '',
      district: json['district'] ?? 'ঢাকা',
      commissionType: (json['commission_type'] as num?)?.toInt() ?? 1,
      commissionValue: (json['commission_value'] as num?)?.toDouble() ?? 5.0,
    );
  }
}