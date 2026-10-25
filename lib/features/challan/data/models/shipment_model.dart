class ShipmentItemModel {
  final int id;
  final int? purchaseItemId;
  final int productId;
  final String productName;
  final int? unitId;
  final String unitName;
  final int bagCount;
  final double dispatchedWeight;
  final double receivedWeight;
  final double shortageWeight;
  final double unitRate;
  final String? notes;

  ShipmentItemModel({
    required this.id,
    this.purchaseItemId,
    required this.productId,
    required this.productName,
    this.unitId,
    required this.unitName,
    required this.bagCount,
    required this.dispatchedWeight,
    required this.receivedWeight,
    required this.shortageWeight,
    required this.unitRate,
    this.notes,
  });

  factory ShipmentItemModel.fromJson(Map<String, dynamic> json) {
    return ShipmentItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      purchaseItemId: (json['purchase_item_id'] as num?)?.toInt(),
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] ?? json['product']?['name'] ?? 'কৃষিপণ্য',
      unitId: (json['unit_id'] as num?)?.toInt(),
      unitName: json['unit_name'] ?? json['unit']?['name'] ?? 'কেজি',
      bagCount: (json['bag_count'] as num?)?.toInt() ?? 0,
      dispatchedWeight: (json['dispatched_weight'] as num?)?.toDouble() ?? 0.0,
      receivedWeight: (json['received_weight'] as num?)?.toDouble() ?? 0.0,
      shortageWeight: (json['shortage_weight'] as num?)?.toDouble() ?? 0.0,
      unitRate: (json['unit_rate'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      if (purchaseItemId != null) 'purchase_item_id': purchaseItemId,
      'product_id': productId,
      if (unitId != null) 'unit_id': unitId,
      'bag_count': bagCount,
      'dispatched_weight': dispatchedWeight,
      'unit_rate': unitRate,
      if (notes != null) 'notes': notes,
    };
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

class ShipmentSaleModel {
  final int id;
  final String saleNumber;
  final int shipmentId;
  final int? shipmentItemId;
  final int productId;
  final String productName;
  final String unitName;
  final String saleDate;
  final double quantity;
  final double unitRate;
  final double grossAmount;
  final double discountAmount;
  final double netAmount;
  final int commissionType;
  final String commissionLabel;
  final double commissionRate;
  final double commissionAmount;
  final double netProceeds;
  final String? buyerName;
  final String? buyerPhone;
  final String? notes;

  ShipmentSaleModel({
    required this.id,
    required this.saleNumber,
    required this.shipmentId,
    this.shipmentItemId,
    required this.productId,
    required this.productName,
    required this.unitName,
    required this.saleDate,
    required this.quantity,
    required this.unitRate,
    required this.grossAmount,
    required this.discountAmount,
    required this.netAmount,
    required this.commissionType,
    required this.commissionLabel,
    required this.commissionRate,
    required this.commissionAmount,
    required this.netProceeds,
    this.buyerName,
    this.buyerPhone,
    this.notes,
  });

  factory ShipmentSaleModel.fromJson(Map<String, dynamic> json) {
    return ShipmentSaleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      saleNumber: json['sale_number'] ?? 'SLS-${json['id']}',
      shipmentId: (json['shipment_id'] as num?)?.toInt() ?? 0,
      shipmentItemId: (json['shipment_item_id'] as num?)?.toInt(),
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] ?? json['product']?['name'] ?? 'কৃষিপণ্য',
      unitName: json['unit_name'] ?? json['unit']?['name'] ?? 'কেজি',
      saleDate: json['sale_date'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitRate: (json['unit_rate'] as num?)?.toDouble() ?? 0.0,
      grossAmount: (json['gross_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0.0,
      commissionType: (json['commission_type'] as num?)?.toInt() ?? 1,
      commissionLabel: json['commission_label'] ?? 'কমিশন',
      commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 0.0,
      commissionAmount: (json['commission_amount'] as num?)?.toDouble() ?? 0.0,
      netProceeds: (json['net_proceeds'] as num?)?.toDouble() ?? 0.0,
      buyerName: json['buyer_name'],
      buyerPhone: json['buyer_phone'],
      notes: json['notes'],
    );
  }
}

class ShipmentModel {
  final int id;
  final String shipmentNumber;
  final int? aratdarId;
  final String? aratdarName;
  final int? transporterId;
  final String? transporterName;
  final int? marketId;
  final String? destinationMarket;
  final String dispatchDate;
  final String? expectedArrivalDate;
  final String? vehicleNumber;
  final double freightAmount;
  final String freightPaidBy;
  final int status;
  final String statusLabel;
  final String? notes;
  final List<ShipmentItemModel> items;
  final List<ShipmentExpenseItem> expenses;

  ShipmentModel({
    required this.id,
    required this.shipmentNumber,
    this.aratdarId,
    this.aratdarName,
    this.transporterId,
    this.transporterName,
    this.marketId,
    this.destinationMarket,
    required this.dispatchDate,
    this.expectedArrivalDate,
    this.vehicleNumber,
    required this.freightAmount,
    required this.freightPaidBy,
    required this.status,
    required this.statusLabel,
    this.notes,
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
      transporterId: (json['transporter_id'] as num?)?.toInt(),
      transporterName: json['transporter_name'] ?? json['transporter']?['name'],
      marketId: (json['market_id'] as num?)?.toInt(),
      destinationMarket: json['market_name'] ?? json['market']?['name'] ?? 'পাইকারি মোকাম',
      dispatchDate: json['dispatch_date'] ?? '',
      expectedArrivalDate: json['expected_arrival_date'],
      vehicleNumber: json['vehicle_number'] ?? '',
      freightAmount: (json['freight_amount'] as num?)?.toDouble() ?? 0.0,
      freightPaidBy: json['freight_paid_by'] ?? 'owner',
      status: (json['status'] as num?)?.toInt() ?? 0,
      statusLabel: json['status_label'] ?? _defaultStatusLabel((json['status'] as num?)?.toInt() ?? 0),
      notes: json['notes'],
      items: itemsList,
      expenses: expList,
    );
  }

  static String _defaultStatusLabel(int s) {
    switch (s) {
      case 0:
        return 'খসড়া (Draft)';
      case 1:
        return 'ট্রাকে প্রেরিত (Dispatched)';
      case 2:
        return 'আড়তে পৌঁছেছে (Received)';
      case 3:
        return 'বিক্রি চলছে (Selling)';
      case 4:
        return 'সমন্বয় চলছে (Reconciling)';
      case 5:
        return 'নিষ্পত্তি সম্পন্ন (Settled)';
      case 6:
        return 'বিতর্কিত (Disputed)';
      default:
        return 'চলমান';
    }
  }

  double get totalDispatchedWeight => items.fold<double>(0.0, (sum, i) => sum + i.dispatchedWeight);
  double get totalReceivedWeight => items.fold<double>(0.0, (sum, i) => sum + i.receivedWeight);
  double get totalShortageWeight => items.fold<double>(0.0, (sum, i) => sum + i.shortageWeight);
  int get totalBags => items.fold<int>(0, (sum, i) => sum + i.bagCount);
  double get totalExpenses => expenses.fold<double>(0.0, (sum, e) => sum + e.amount) + freightAmount;
}