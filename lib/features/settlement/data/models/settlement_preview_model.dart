class SettlementPreviewModel {
  final double grossSales;
  final double commissionAmount;
  final double netSalesProceeds;
  final double allocatedCogs;
  final double totalOwnerExpenses;
  final double totalAratdarDeductions;
  final double realizedProfit;
  final double expectedNetProceeds;
  final double totalRemitted;
  final double outstandingReceivable;

  SettlementPreviewModel({
    required this.grossSales,
    required this.commissionAmount,
    required this.netSalesProceeds,
    required this.allocatedCogs,
    required this.totalOwnerExpenses,
    required this.totalAratdarDeductions,
    required this.realizedProfit,
    required this.expectedNetProceeds,
    required this.totalRemitted,
    required this.outstandingReceivable,
  });

  factory SettlementPreviewModel.fromJson(Map<String, dynamic> json) {
    final sales = json['sales_summary'] as Map<String, dynamic>? ?? {};
    final pnl = json['profit_and_loss'] as Map<String, dynamic>? ?? {};
    final rem = json['remittance_reconciliation'] as Map<String, dynamic>? ?? {};
    final exp = json['expenses_breakdown'] as Map<String, dynamic>? ?? {};

    return SettlementPreviewModel(
      grossSales: (sales['gross_sales'] as num?)?.toDouble() ?? 0.0,
      commissionAmount: (sales['commission_amount'] as num?)?.toDouble() ?? 0.0,
      netSalesProceeds: (sales['net_sales_proceeds'] as num?)?.toDouble() ?? 0.0,
      allocatedCogs: (pnl['allocated_cogs_sold_stock'] as num?)?.toDouble() ?? 0.0,
      totalOwnerExpenses: (pnl['owner_consignment_expenses'] as num?)?.toDouble() ?? (exp['total_owner_expenses'] as num?)?.toDouble() ?? 0.0,
      totalAratdarDeductions: (pnl['aratdar_consignment_deductions'] as num?)?.toDouble() ?? (exp['total_aratdar_deductions'] as num?)?.toDouble() ?? 0.0,
      realizedProfit: (pnl['realized_profit_or_loss'] as num?)?.toDouble() ?? 0.0,
      expectedNetProceeds: (rem['expected_net_proceeds'] as num?)?.toDouble() ?? 0.0,
      totalRemitted: (rem['total_remitted_amount'] as num?)?.toDouble() ?? 0.0,
      outstandingReceivable: (rem['outstanding_receivable'] as num?)?.toDouble() ?? 0.0,
    );
  }
}