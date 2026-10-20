class AratdarRemittanceModel {
  final int id;
  final String remittanceNumber;
  final int aratdarId;
  final String aratdarName;
  final int accountId;
  final String accountName;
  final double amount;
  final double allocatedAmount;
  final double unallocatedAmount;
  final String paymentDate;
  final String paymentMethod;
  final String? referenceNumber;
  final String? notes;

  AratdarRemittanceModel({
    required this.id,
    required this.remittanceNumber,
    required this.aratdarId,
    required this.aratdarName,
    required this.accountId,
    required this.accountName,
    required this.amount,
    required this.allocatedAmount,
    required this.unallocatedAmount,
    required this.paymentDate,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
  });

  factory AratdarRemittanceModel.fromJson(Map<String, dynamic> json) {
    return AratdarRemittanceModel(
      id: json['id'] ?? 0,
      remittanceNumber: json['remittance_number'] ?? '',
      aratdarId: json['aratdar_id'] ?? 0,
      aratdarName: json['aratdar_name'] ?? json['aratdar']?['name'] ?? 'আড়তদার',
      accountId: json['account_id'] ?? 0,
      accountName: json['account_name'] ?? json['account']?['name'] ?? 'ক্যাশ',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      allocatedAmount: (json['allocated_amount'] as num?)?.toDouble() ?? 0.0,
      unallocatedAmount: (json['unallocated_amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['payment_date'] ?? '',
      paymentMethod: json['payment_method'] ?? 'cash',
      referenceNumber: json['reference_number'],
      notes: json['notes'],
    );
  }
}