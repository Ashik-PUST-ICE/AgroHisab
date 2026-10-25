class RemittanceAllocationModel {
  final int id;
  final int aratdarRemittanceId;
  final int shipmentId;
  final String? shipmentNumber;
  final double amount;
  final String allocationDate;
  final String? notes;

  RemittanceAllocationModel({
    required this.id,
    required this.aratdarRemittanceId,
    required this.shipmentId,
    this.shipmentNumber,
    required this.amount,
    required this.allocationDate,
    this.notes,
  });

  factory RemittanceAllocationModel.fromJson(Map<String, dynamic> json) {
    return RemittanceAllocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      aratdarRemittanceId: (json['aratdar_remittance_id'] as num?)?.toInt() ?? 0,
      shipmentId: (json['shipment_id'] as num?)?.toInt() ?? 0,
      shipmentNumber: json['shipment_number'] ?? json['shipment']?['shipment_number'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      allocationDate: json['allocation_date'] ?? '',
      notes: json['notes'],
    );
  }
}

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
  final List<RemittanceAllocationModel> allocations;

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
    this.allocations = const [],
  });

  factory AratdarRemittanceModel.fromJson(Map<String, dynamic> json) {
    final rawAlloc = json['allocations'] as List<dynamic>? ?? [];
    final allocList = rawAlloc.map((e) => RemittanceAllocationModel.fromJson(e as Map<String, dynamic>)).toList();

    return AratdarRemittanceModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      remittanceNumber: json['remittance_number'] ?? '',
      aratdarId: (json['aratdar_id'] as num?)?.toInt() ?? 0,
      aratdarName: json['aratdar_name'] ?? json['aratdar']?['name'] ?? 'আড়তদার',
      accountId: (json['account_id'] as num?)?.toInt() ?? 0,
      accountName: json['account_name'] ?? json['account']?['name'] ?? 'ক্যাশ অ্যাকাউন্ট',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      allocatedAmount: (json['allocated_amount'] as num?)?.toDouble() ?? 0.0,
      unallocatedAmount: (json['unallocated_amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['payment_date'] ?? '',
      paymentMethod: json['payment_method'] ?? 'cash',
      referenceNumber: json['reference_number'],
      notes: json['notes'],
      allocations: allocList,
    );
  }
}