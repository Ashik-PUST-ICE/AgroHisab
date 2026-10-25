class PriceObservationModel {
  final int id;
  final int marketId;
  final String? marketName;
  final int productId;
  final String? productName;
  final int? unitId;
  final String? unitSymbol;
  final String observedDate;
  final double? minPrice;
  final double? maxPrice;
  final double? avgPrice;
  final String? source;
  final String? notes;
  final String? createdAt;

  PriceObservationModel({
    required this.id,
    required this.marketId,
    this.marketName,
    required this.productId,
    this.productName,
    this.unitId,
    this.unitSymbol,
    required this.observedDate,
    this.minPrice,
    this.maxPrice,
    this.avgPrice,
    this.source,
    this.notes,
    this.createdAt,
  });

  factory PriceObservationModel.fromJson(Map<String, dynamic> json) {
    return PriceObservationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      marketId: (json['market_id'] as num?)?.toInt() ?? 0,
      marketName: json['market_name'] as String?,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] as String?,
      unitId: (json['unit_id'] as num?)?.toInt(),
      unitSymbol: json['unit_symbol'] as String?,
      observedDate: json['observed_date']?.toString() ?? '',
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      avgPrice: (json['avg_price'] as num?)?.toDouble(),
      source: json['source'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  String get priceSummary {
    if (minPrice != null && maxPrice != null && minPrice != maxPrice) {
      return '৳${minPrice!.toStringAsFixed(0)} - ৳${maxPrice!.toStringAsFixed(0)}';
    } else if (avgPrice != null) {
      return '৳${avgPrice!.toStringAsFixed(1)} (গড়)';
    } else if (minPrice != null) {
      return '৳${minPrice!.toStringAsFixed(0)}';
    } else if (maxPrice != null) {
      return '৳${maxPrice!.toStringAsFixed(0)}';
    }
    return 'দর উল্লেখ নেই';
  }
}