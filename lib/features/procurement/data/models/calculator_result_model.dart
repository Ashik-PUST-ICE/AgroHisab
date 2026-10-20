class CalculatorResultModel {
  final double actualWeight;
  final double deductedWeight;
  final double payableWeight;
  final double monRate;
  final double monSize;
  final double ratePerKg;
  final double totalProduceValue;
  final double paidAmount;
  final double dueAmount;
  final String summaryTextBn;
  final Map<String, dynamic>? purchase;

  CalculatorResultModel({
    required this.actualWeight,
    required this.deductedWeight,
    required this.payableWeight,
    required this.monRate,
    required this.monSize,
    required this.ratePerKg,
    required this.totalProduceValue,
    required this.paidAmount,
    required this.dueAmount,
    required this.summaryTextBn,
    this.purchase,
  });

  factory CalculatorResultModel.fromJson(Map<String, dynamic> json) {
    return CalculatorResultModel(
      actualWeight: (json['actual_weight'] as num?)?.toDouble() ?? 0.0,
      deductedWeight: (json['deducted_weight'] as num?)?.toDouble() ?? 0.0,
      payableWeight: (json['payable_weight'] as num?)?.toDouble() ?? 0.0,
      monRate: (json['mon_rate'] as num?)?.toDouble() ?? 0.0,
      monSize: (json['mon_size'] as num?)?.toDouble() ?? 40.0,
      ratePerKg: (json['rate_per_kg'] as num?)?.toDouble() ?? 0.0,
      totalProduceValue: (json['total_produce_value'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0.0,
      summaryTextBn: json['summary_text_bn'] ?? '',
      purchase: json['purchase'] is Map<String, dynamic> ? json['purchase'] : null,
    );
  }
}