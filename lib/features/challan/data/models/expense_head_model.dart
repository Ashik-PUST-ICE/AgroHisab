class ExpenseHeadModel {
  final int id;
  final String code;
  final String name;
  final String defaultPaidBy;

  ExpenseHeadModel({
    required this.id,
    required this.code,
    required this.name,
    required this.defaultPaidBy,
  });

  factory ExpenseHeadModel.fromJson(Map<String, dynamic> json) {
    return ExpenseHeadModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      defaultPaidBy: json['default_paid_by'] ?? 'owner',
    );
  }
}