class DashboardMetricsModel {
  final double totalLiquidBalance;
  final double netReceivableDue;
  final double totalSupplierDue;
  final double totalGrossSales;
  final double totalRealizedProfit;
  final Map<String, int> shipmentsCount;

  DashboardMetricsModel({
    required this.totalLiquidBalance,
    required this.netReceivableDue,
    required this.totalSupplierDue,
    required this.totalGrossSales,
    required this.totalRealizedProfit,
    required this.shipmentsCount,
  });

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    final liquidity = json['liquidity'] as Map<String, dynamic>? ?? {};
    final receivables = json['receivables'] as Map<String, dynamic>? ?? {};
    final payables = json['payables'] as Map<String, dynamic>? ?? {};
    final financials = json['financials'] as Map<String, dynamic>? ?? {};
    final consignments = json['consignments'] as Map<String, dynamic>? ?? {};
    final breakdown = consignments['breakdown'] as Map<String, dynamic>? ?? {};

    return DashboardMetricsModel(
      totalLiquidBalance: (liquidity['total_liquid_balance'] as num?)?.toDouble() ?? 0.0,
      netReceivableDue: (receivables['net_receivable_due'] as num?)?.toDouble() ?? 0.0,
      totalSupplierDue: (payables['total_supplier_due'] as num?)?.toDouble() ?? 0.0,
      totalGrossSales: (financials['total_gross_sales'] as num?)?.toDouble() ?? 0.0,
      totalRealizedProfit: (financials['total_realized_profit'] as num?)?.toDouble() ?? 0.0,
      shipmentsCount: breakdown.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );
  }

  double get totalInvested => totalLiquidBalance + totalSupplierDue;
}