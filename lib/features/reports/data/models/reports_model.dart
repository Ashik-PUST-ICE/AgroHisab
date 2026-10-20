class ProfitabilityReportModel {
  final double totalRevenue;
  final double totalCogs;
  final double grossProfit;
  final double totalExpenses;
  final double netProfit;

  ProfitabilityReportModel({
    required this.totalRevenue,
    required this.totalCogs,
    required this.grossProfit,
    required this.totalExpenses,
    required this.netProfit,
  });

  factory ProfitabilityReportModel.fromJson(Map<String, dynamic> json) {
    return ProfitabilityReportModel(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? (json['revenue'] as num?)?.toDouble() ?? 0.0,
      totalCogs: (json['total_cogs'] as num?)?.toDouble() ?? (json['cogs'] as num?)?.toDouble() ?? 0.0,
      grossProfit: (json['gross_profit'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['net_profit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InventoryValuationItemModel {
  final String productName;
  final double currentStockKg;
  final double averageRate;
  final double totalValue;

  InventoryValuationItemModel({
    required this.productName,
    required this.currentStockKg,
    required this.averageRate,
    required this.totalValue,
  });

  factory InventoryValuationItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryValuationItemModel(
      productName: json['product_name'] ?? json['crop_name'] ?? 'ফসল',
      currentStockKg: (json['current_stock_kg'] as num?)?.toDouble() ?? (json['stock_kg'] as num?)?.toDouble() ?? 0.0,
      averageRate: (json['average_rate'] as num?)?.toDouble() ?? (json['avg_price'] as num?)?.toDouble() ?? 0.0,
      totalValue: (json['total_valuation'] as num?)?.toDouble() ?? (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}