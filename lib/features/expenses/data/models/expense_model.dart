class ExpenseCategoryModel {
  final int id;
  final String name;

  ExpenseCategoryModel({required this.id, required this.name});

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ExpenseModel {
  final int id;
  final String expenseNumber;
  final String title;
  final double amount;
  final String? categoryName;
  final String expenseDate;
  final String paidBy;
  final String? notes;
  final String? purchaseNumber;
  final String? shipmentNumber;

  ExpenseModel({
    required this.id,
    required this.expenseNumber,
    required this.title,
    required this.amount,
    this.categoryName,
    required this.expenseDate,
    required this.paidBy,
    this.notes,
    this.purchaseNumber,
    this.shipmentNumber,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? 0,
      expenseNumber: json['expense_number'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      categoryName: json['category_name'] ?? json['category']?['name'],
      expenseDate: json['expense_date'] ?? '',
      paidBy: json['paid_by'] ?? 'owner',
      notes: json['notes'],
      purchaseNumber: json['purchase_number'],
      shipmentNumber: json['shipment_number'],
    );
  }
}