class StockBalanceModel {
  final int productId;
  final String productName;
  final double currentStockKg;
  final int currentStockBags;

  StockBalanceModel({
    required this.productId,
    required this.productName,
    required this.currentStockKg,
    required this.currentStockBags,
  });

  factory StockBalanceModel.fromJson(Map<String, dynamic> json) {
    return StockBalanceModel(
      productId: json['product_id'] ?? json['crop_id'] ?? 0,
      productName: json['product_name'] ?? json['crop_name'] ?? 'ফসল',
      currentStockKg: (json['current_stock_kg'] as num?)?.toDouble() ?? 
                      (json['balance_kg'] as num?)?.toDouble() ?? 0.0,
      currentStockBags: (json['current_stock_bags'] as num?)?.toInt() ?? 
                        (json['balance_bags'] as num?)?.toInt() ?? 0,
    );
  }
}

class StockMovementModel {
  final int id;
  final int productId;
  final String productName;
  final String type; // in, out, adjustment
  final double quantityKg;
  final int bagCount;
  final String referenceType;
  final String referenceId;
  final String date;
  final String? notes;

  StockMovementModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantityKg,
    required this.bagCount,
    required this.referenceType,
    required this.referenceId,
    required this.date,
    this.notes,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product']?['name'] ?? 'ফসল',
      type: json['type'] ?? 'in',
      quantityKg: (json['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      bagCount: (json['bag_count'] as num?)?.toInt() ?? 0,
      referenceType: json['reference_type'] ?? '',
      referenceId: (json['reference_id'] ?? '').toString(),
      date: json['movement_date'] ?? json['created_at'] ?? '',
      notes: json['notes'],
    );
  }
}

class StockAdjustmentModel {
  final int id;
  final int productId;
  final String productName;
  final String reason;
  final String reasonLabel;
  final double quantityKg;
  final int bagCount;
  final String date;
  final String? remarks;

  StockAdjustmentModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.reason,
    required this.reasonLabel,
    required this.quantityKg,
    required this.bagCount,
    required this.date,
    this.remarks,
  });

  factory StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product']?['name'] ?? 'ফসল',
      reason: json['reason'] ?? '',
      reasonLabel: json['reason_label'] ?? json['reason'] ?? 'ঘাটতি সমন্বয়',
      quantityKg: (json['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      bagCount: (json['bag_count'] as num?)?.toInt() ?? 0,
      date: json['adjustment_date'] ?? json['created_at'] ?? '',
      remarks: json['remarks'],
    );
  }
}