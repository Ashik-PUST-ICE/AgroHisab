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
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ??
          (json['revenue'] as num?)?.toDouble() ??
          0.0,
      totalCogs: (json['total_cogs'] as num?)?.toDouble() ??
          (json['cogs'] as num?)?.toDouble() ??
          0.0,
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
      currentStockKg: (json['current_stock_kg'] as num?)?.toDouble() ??
          (json['stock_kg'] as num?)?.toDouble() ??
          0.0,
      averageRate: (json['average_rate'] as num?)?.toDouble() ??
          (json['avg_price'] as num?)?.toDouble() ??
          0.0,
      totalValue: (json['total_valuation'] as num?)?.toDouble() ??
          (json['value'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

// API 13: Cashbook Report Models
class CashbookSummaryModel {
  final double openingBalance;
  final double totalInflows;
  final double totalOutflows;
  final double netCashflow;
  final double closingBalance;

  CashbookSummaryModel({
    required this.openingBalance,
    required this.totalInflows,
    required this.totalOutflows,
    required this.netCashflow,
    required this.closingBalance,
  });

  factory CashbookSummaryModel.fromJson(Map<String, dynamic> json) {
    return CashbookSummaryModel(
      openingBalance: (json['opening_balance'] as num?)?.toDouble() ?? 0.0,
      totalInflows: (json['total_inflows'] as num?)?.toDouble() ?? 0.0,
      totalOutflows: (json['total_outflows'] as num?)?.toDouble() ?? 0.0,
      netCashflow: (json['net_cashflow'] as num?)?.toDouble() ?? 0.0,
      closingBalance: (json['closing_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CashbookTransactionModel {
  final String id;
  final String date;
  final String type; // 'credit' or 'debit'
  final String typeLabel;
  final String? reference;
  final String? partyName;
  final String? accountName;
  final double creditAmount;
  final double debitAmount;
  final double runningBalance;
  final String? notes;

  CashbookTransactionModel({
    required this.id,
    required this.date,
    required this.type,
    required this.typeLabel,
    this.reference,
    this.partyName,
    this.accountName,
    required this.creditAmount,
    required this.debitAmount,
    required this.runningBalance,
    this.notes,
  });

  factory CashbookTransactionModel.fromJson(Map<String, dynamic> json) {
    return CashbookTransactionModel(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? 'credit',
      typeLabel: json['type_label'] ?? '',
      reference: json['reference']?.toString(),
      partyName: json['party_name']?.toString(),
      accountName: json['account_name']?.toString(),
      creditAmount: (json['credit_amount'] as num?)?.toDouble() ?? 0.0,
      debitAmount: (json['debit_amount'] as num?)?.toDouble() ?? 0.0,
      runningBalance: (json['running_balance'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString(),
    );
  }

  bool get isCredit => type == 'credit' || creditAmount > 0;
}

class CashbookReportModel {
  final CashbookSummaryModel summary;
  final List<CashbookTransactionModel> transactions;

  CashbookReportModel({
    required this.summary,
    required this.transactions,
  });

  factory CashbookReportModel.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};
    final txList = json['transactions'] is List
        ? (json['transactions'] as List)
            .map((e) => CashbookTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <CashbookTransactionModel>[];

    return CashbookReportModel(
      summary: CashbookSummaryModel.fromJson(summaryJson),
      transactions: txList,
    );
  }
}

// API 14: Receivables Aging Report Models
class ReceivablesAgingSummaryModel {
  final double bucket030;
  final double bucket3160;
  final double bucket6190;
  final double bucket90Plus;
  final double grandTotal;

  ReceivablesAgingSummaryModel({
    required this.bucket030,
    required this.bucket3160,
    required this.bucket6190,
    required this.bucket90Plus,
    required this.grandTotal,
  });

  factory ReceivablesAgingSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReceivablesAgingSummaryModel(
      bucket030: (json['0_30_days'] as num?)?.toDouble() ??
          (json['0_30'] as num?)?.toDouble() ??
          0.0,
      bucket3160: (json['31_60_days'] as num?)?.toDouble() ??
          (json['31_60'] as num?)?.toDouble() ??
          0.0,
      bucket6190: (json['61_90_days'] as num?)?.toDouble() ??
          (json['61_90'] as num?)?.toDouble() ??
          0.0,
      bucket90Plus: (json['90_plus_days'] as num?)?.toDouble() ??
          (json['90_plus'] as num?)?.toDouble() ??
          0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

class ReceivablesAgingRowModel {
  final int aratdarId;
  final String aratdarName;
  final String? city;
  final double bucket030;
  final double bucket3160;
  final double bucket6190;
  final double bucket90Plus;
  final double totalDue;

  ReceivablesAgingRowModel({
    required this.aratdarId,
    required this.aratdarName,
    this.city,
    required this.bucket030,
    required this.bucket3160,
    required this.bucket6190,
    required this.bucket90Plus,
    required this.totalDue,
  });

  factory ReceivablesAgingRowModel.fromJson(Map<String, dynamic> json) {
    return ReceivablesAgingRowModel(
      aratdarId: (json['aratdar_id'] as num?)?.toInt() ?? 0,
      aratdarName: json['aratdar_name'] ?? 'আড়তদার',
      city: json['city'] as String?,
      bucket030: (json['0_30_days'] as num?)?.toDouble() ?? 0.0,
      bucket3160: (json['31_60_days'] as num?)?.toDouble() ?? 0.0,
      bucket6190: (json['61_90_days'] as num?)?.toDouble() ?? 0.0,
      bucket90Plus: (json['90_plus_days'] as num?)?.toDouble() ?? 0.0,
      totalDue: (json['total_due'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReceivablesAgingReportModel {
  final String reportDate;
  final ReceivablesAgingSummaryModel summary;
  final List<ReceivablesAgingRowModel> rows;

  ReceivablesAgingReportModel({
    required this.reportDate,
    required this.summary,
    required this.rows,
  });

  factory ReceivablesAgingReportModel.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};
    final rowsList = json['rows'] is List
        ? (json['rows'] as List)
            .map((e) => ReceivablesAgingRowModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <ReceivablesAgingRowModel>[];

    return ReceivablesAgingReportModel(
      reportDate: json['report_date']?.toString() ?? '',
      summary: ReceivablesAgingSummaryModel.fromJson(summaryJson),
      rows: rowsList,
    );
  }
}

// API 15: Payables Aging Report Models
class PayablesAgingSummaryModel {
  final double bucket030;
  final double bucket3160;
  final double bucket6190;
  final double bucket90Plus;
  final double grandTotal;

  PayablesAgingSummaryModel({
    required this.bucket030,
    required this.bucket3160,
    required this.bucket6190,
    required this.bucket90Plus,
    required this.grandTotal,
  });

  factory PayablesAgingSummaryModel.fromJson(Map<String, dynamic> json) {
    return PayablesAgingSummaryModel(
      bucket030: (json['0_30'] as num?)?.toDouble() ??
          (json['0_30_days'] as num?)?.toDouble() ??
          0.0,
      bucket3160: (json['31_60'] as num?)?.toDouble() ??
          (json['31_60_days'] as num?)?.toDouble() ??
          0.0,
      bucket6190: (json['61_90'] as num?)?.toDouble() ??
          (json['61_90_days'] as num?)?.toDouble() ??
          0.0,
      bucket90Plus: (json['90_plus'] as num?)?.toDouble() ??
          (json['90_plus_days'] as num?)?.toDouble() ??
          0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

class PayablesAgingRowModel {
  final int supplierId;
  final String supplierName;
  final double bucket030;
  final double bucket3160;
  final double bucket6190;
  final double bucket90Plus;
  final double totalDue;

  PayablesAgingRowModel({
    required this.supplierId,
    required this.supplierName,
    required this.bucket030,
    required this.bucket3160,
    required this.bucket6190,
    required this.bucket90Plus,
    required this.totalDue,
  });

  factory PayablesAgingRowModel.fromJson(Map<String, dynamic> json) {
    return PayablesAgingRowModel(
      supplierId: (json['supplier_id'] as num?)?.toInt() ?? 0,
      supplierName: json['supplier_name'] ?? 'কৃষক / সরবরাহকারী',
      bucket030: (json['0_30_days'] as num?)?.toDouble() ??
          (json['0_30'] as num?)?.toDouble() ??
          0.0,
      bucket3160: (json['31_60_days'] as num?)?.toDouble() ??
          (json['31_60'] as num?)?.toDouble() ??
          0.0,
      bucket6190: (json['61_90_days'] as num?)?.toDouble() ??
          (json['61_90'] as num?)?.toDouble() ??
          0.0,
      bucket90Plus: (json['90_plus_days'] as num?)?.toDouble() ??
          (json['90_plus'] as num?)?.toDouble() ??
          0.0,
      totalDue: (json['total_due'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

class PayablesAgingReportModel {
  final String reportDate;
  final PayablesAgingSummaryModel summary;
  final List<PayablesAgingRowModel> rows;

  PayablesAgingReportModel({
    required this.reportDate,
    required this.summary,
    required this.rows,
  });

  factory PayablesAgingReportModel.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};
    final rowsList = json['rows'] is List
        ? (json['rows'] as List)
            .map((e) => PayablesAgingRowModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <PayablesAgingRowModel>[];

    return PayablesAgingReportModel(
      reportDate: json['report_date']?.toString() ?? '',
      summary: PayablesAgingSummaryModel.fromJson(summaryJson),
      rows: rowsList,
    );
  }
}

// API 16: Sales By Product Report Models
class SalesByProductSummaryModel {
  final int totalSales;
  final double totalGross;
  final double totalCommission;
  final double totalNet;

  SalesByProductSummaryModel({
    required this.totalSales,
    required this.totalGross,
    required this.totalCommission,
    required this.totalNet,
  });

  factory SalesByProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return SalesByProductSummaryModel(
      totalSales: (json['total_sales'] as num?)?.toInt() ?? 0,
      totalGross: (json['total_gross'] as num?)?.toDouble() ?? 0.0,
      totalCommission: (json['total_commission'] as num?)?.toDouble() ?? 0.0,
      totalNet: (json['total_net'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SalesByProductRowModel {
  final int productId;
  final String productName;
  final int saleCount;
  final double totalQuantity;
  final double totalGross;
  final double totalCommission;
  final double totalNet;

  SalesByProductRowModel({
    required this.productId,
    required this.productName,
    required this.saleCount,
    required this.totalQuantity,
    required this.totalGross,
    required this.totalCommission,
    required this.totalNet,
  });

  factory SalesByProductRowModel.fromJson(Map<String, dynamic> json) {
    return SalesByProductRowModel(
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] ?? 'ফসল',
      saleCount: (json['sale_count'] as num?)?.toInt() ?? 0,
      totalQuantity: (json['total_quantity'] as num?)?.toDouble() ?? 0.0,
      totalGross: (json['total_gross'] as num?)?.toDouble() ?? 0.0,
      totalCommission: (json['total_commission'] as num?)?.toDouble() ?? 0.0,
      totalNet: (json['total_net'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SalesByProductReportModel {
  final SalesByProductSummaryModel summary;
  final List<SalesByProductRowModel> rows;

  SalesByProductReportModel({
    required this.summary,
    required this.rows,
  });

  factory SalesByProductReportModel.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};
    final rowsList = json['rows'] is List
        ? (json['rows'] as List)
            .map((e) => SalesByProductRowModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <SalesByProductRowModel>[];

    return SalesByProductReportModel(
      summary: SalesByProductSummaryModel.fromJson(summaryJson),
      rows: rowsList,
    );
  }
}