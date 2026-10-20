class ShipmentItemModel {
  final int id;
  final int productId;
  final String productName;
  final int bagCount;
  final double dispatchedWeight;
  final double receivedWeight;
  final double shortageWeight;
  final String unitName;

  ShipmentItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.bagCount,
    required this.dispatchedWeight,
    required this.receivedWeight,
    required this.shortageWeight,
    required this.unitName,
  });

  factory ShipmentItemModel.fromJson(Map<String, dynamic> json) {
    return ShipmentItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] ?? json['product']?['name'] ?? 'কৃষিপণ্য',
      bagCount: (json['bag_count'] as num?)?.toInt() ?? 0,
      dispatchedWeight: (json['dispatched_weight'] as num?)?.toDouble() ?? 0.0,
      receivedWeight: (json['received_weight'] as num?)?.toDouble() ?? 0.0,
      shortageWeight: (json['shortage_weight'] as num?)?.toDouble() ?? 0.0,
      unitName: json['unit_name'] ?? json['unit']?['name'] ?? 'কেজি',
    );
  }
}

class ShipmentExpenseItem {
  final int? type;
  final String head;
  final double amount;
  final String paidBy;
  final String? notes;

  ShipmentExpenseItem({
    this.type,
    required this.head,
    required this.amount,
    required this.paidBy,
    this.notes,
  });

  factory ShipmentExpenseItem.fromJson(Map<String, dynamic> json) {
    return ShipmentExpenseItem(
      type: (json['type'] as num?)?.toInt(),
      head: json['head'] ?? 'খরচ',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paidBy: json['paid_by'] ?? 'owner',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      'head': head,
      'amount': amount,
      'paid_by': paidBy,
      if (notes != null) 'notes': notes,
    };
  }
}

class ShipmentModel {
  final int id;
  final String shipmentNumber;
  final int? aratdarId;
  final String? aratdarName;
  final String? destinationMarket;
  final String dispatchDate;
  final String? vehicleNumber;
  final double freightAmount;
  final String freightPaidBy;
  final int status;
  final String statusLabel;
  final List<ShipmentItemModel> items;
  final List<ShipmentExpenseItem> expenses;

  ShipmentModel({
    required this.id,
    required this.shipmentNumber,
    this.aratdarId,
    this.aratdarName,
    this.destinationMarket,
    required this.dispatchDate,
    this.vehicleNumber,
    required this.freightAmount,
    required this.freightPaidBy,
    required this.status,
    required this.statusLabel,
    required this.items,
    required this.expenses,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems.map((e) => ShipmentItemModel.fromJson(e as Map<String, dynamic>)).toList();

    final rawExp = json['expense_breakdown'] as List<dynamic>? ?? [];
    final expList = rawExp.map((e) => ShipmentExpenseItem.fromJson(e as Map<String, dynamic>)).toList();

    return ShipmentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      shipmentNumber: json['shipment_number'] ?? 'SHP-${json['id']}',
      aratdarId: (json['aratdar_id'] as num?)?.toInt(),
      aratdarName: json['aratdar_name'] ?? json['aratdar']?['name'] ?? 'আড়তদার',
      destinationMarket: json['market_name'] ?? json['market']?['name'] ?? 'ঢাকা',
      dispatchDate: json['dispatch_date'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      freightAmount: (json['freight_amount'] as num?)?.toDouble() ?? 0.0,
      freightPaidBy: json['freight_paid_by'] ?? 'owner',
      status: (json['status'] as num?)?.toInt() ?? 1,
      statusLabel: json['status_label'] ?? 'চলমান',
      items: itemsList,
      expenses: expList,
    );
  }

  double get totalDispatchedWeight => items.fold<double>(0.0, (sum, i) => sum + i.dispatchedWeight);
  double get totalExpenses => expenses.fold<double>(0.0, (sum, e) => sum + e.amount) + freightAmount;
}