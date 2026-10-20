class SupplierModel {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String? market;
  final String? district;
  final String? notes;

  SupplierModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.market,
    this.district,
    this.notes,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      market: json['market'],
      district: json['district'],
      notes: json['notes'],
    );
  }
}

class SupplierPurchaseItem {
  final int id;
  final String purchaseNumber;
  final String purchaseDate;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;

  SupplierPurchaseItem({
    required this.id,
    required this.purchaseNumber,
    required this.purchaseDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
  });

  factory SupplierPurchaseItem.fromJson(Map<String, dynamic> json) {
    return SupplierPurchaseItem(
      id: json['id'] ?? 0,
      purchaseNumber: json['purchase_number'] ?? '',
      purchaseDate: json['purchase_date'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SupplierPaymentItem {
  final int id;
  final String paymentNumber;
  final String paymentDate;
  final double amount;
  final String? paymentMethod;

  SupplierPaymentItem({
    required this.id,
    required this.paymentNumber,
    required this.paymentDate,
    required this.amount,
    this.paymentMethod,
  });

  factory SupplierPaymentItem.fromJson(Map<String, dynamic> json) {
    return SupplierPaymentItem(
      id: json['id'] ?? 0,
      paymentNumber: json['payment_number'] ?? '',
      paymentDate: json['payment_date'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'],
    );
  }
}

class SupplierLedgerModel {
  final double totalPurchases;
  final double totalPaid;
  final double balanceDue;
  final List<SupplierPurchaseItem> purchases;
  final List<SupplierPaymentItem> payments;

  SupplierLedgerModel({
    required this.totalPurchases,
    required this.totalPaid,
    required this.balanceDue,
    required this.purchases,
    required this.payments,
  });

  factory SupplierLedgerModel.fromJson(Map<String, dynamic> json) {
    final pList = (json['purchases'] as List?)?.map((e) => SupplierPurchaseItem.fromJson(e)).toList() ?? [];
    final payList = (json['payments'] as List?)?.map((e) => SupplierPaymentItem.fromJson(e)).toList() ?? [];
    final summary = json['summary'] as Map<String, dynamic>? ?? {};

    return SupplierLedgerModel(
      totalPurchases: (summary['total_purchases'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (summary['total_paid'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (summary['balance_due'] as num?)?.toDouble() ?? 0.0,
      purchases: pList,
      payments: payList,
    );
  }
}