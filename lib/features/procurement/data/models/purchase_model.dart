class PurchasePaymentModel {
  final int id;
  final int purchaseId;
  final String? purchaseNumber;
  final int? supplierId;
  final String? supplierName;
  final int accountId;
  final String accountName;
  final double amount;
  final String paymentDate;
  final String? referenceNumber;
  final String? notes;

  PurchasePaymentModel({
    required this.id,
    required this.purchaseId,
    this.purchaseNumber,
    this.supplierId,
    this.supplierName,
    required this.accountId,
    required this.accountName,
    required this.amount,
    required this.paymentDate,
    this.referenceNumber,
    this.notes,
  });

  factory PurchasePaymentModel.fromJson(Map<String, dynamic> json) {
    return PurchasePaymentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      purchaseId: (json['purchase_id'] as num?)?.toInt() ?? 0,
      purchaseNumber: json['purchase_number'] ?? json['purchase']?['purchase_number'],
      supplierId: (json['supplier_id'] as num?)?.toInt(),
      supplierName: json['supplier_name'] ?? json['supplier']?['name'],
      accountId: (json['account_id'] as num?)?.toInt() ?? 0,
      accountName: json['account_name'] ?? json['account']?['name'] ?? 'ক্যাশ অ্যাকাউন্ট',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['payment_date'] ?? '',
      referenceNumber: json['reference_number'],
      notes: json['notes'],
    );
  }
}

class PurchaseModel {
  final int id;
  final String purchaseNumber;
  final int? supplierId;
  final String? supplierName;
  final String? productName;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final double netWeight;
  final double actualWeight;
  final double deductedWeight;
  final int status;
  final String purchaseDate;

  PurchaseModel({
    required this.id,
    required this.purchaseNumber,
    this.supplierId,
    this.supplierName,
    this.productName,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.netWeight,
    required this.actualWeight,
    required this.deductedWeight,
    required this.status,
    required this.purchaseDate,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    final supplier = json['supplier'] as Map<String, dynamic>? ?? {};
    final items = json['items'] as List<dynamic>? ?? [];
    String? prodName;
    double netWt = 0;
    double actWt = 0;
    double dedWt = 0;

    if (items.isNotEmpty && items.first is Map) {
      final firstItem = items.first as Map<String, dynamic>;
      prodName = firstItem['product_name'] ?? firstItem['product']?['name'];
      netWt = (firstItem['net_weight'] as num?)?.toDouble() ?? 0.0;
      actWt = (firstItem['actual_weight'] as num?)?.toDouble() ?? 0.0;
      dedWt = (firstItem['deducted_weight'] as num?)?.toDouble() ?? 0.0;
    }

    return PurchaseModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      purchaseNumber: json['purchase_number'] ?? 'PUR-${json['id']}',
      supplierId: json['supplier_id'] is int ? json['supplier_id'] : int.tryParse(json['supplier_id']?.toString() ?? ''),
      supplierName: json['supplier_name'] ?? supplier['name'] ?? 'কৃষক নির্বাচন করা হয়নি',
      productName: prodName ?? 'কৃষিপণ্য',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0.0,
      netWeight: netWt,
      actualWeight: actWt,
      deductedWeight: dedWt,
      status: (json['status'] as num?)?.toInt() ?? 1,
      purchaseDate: json['purchase_date'] ?? '',
    );
  }

  String get statusLabel {
    switch (status) {
      case 1:
        return 'চলমান';
      case 2:
        return 'সম্পন্ন';
      default:
        return 'সম্পন্ন';
    }
  }
}
