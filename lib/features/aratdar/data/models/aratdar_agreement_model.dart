class AratdarAgreementModel {
  final int aratdarId;
  final String aratdarName;
  final int commissionType; // 1 = Percentage, 2 = Fixed Per Bag
  final String commissionLabel;
  final double commissionValue;
  final String? agreementStart;
  final String? agreementEnd;
  final bool isActive;

  AratdarAgreementModel({
    required this.aratdarId,
    required this.aratdarName,
    required this.commissionType,
    required this.commissionLabel,
    required this.commissionValue,
    this.agreementStart,
    this.agreementEnd,
    required this.isActive,
  });

  factory AratdarAgreementModel.fromJson(Map<String, dynamic> json) {
    return AratdarAgreementModel(
      aratdarId: (json['aratdar_id'] as num?)?.toInt() ?? 0,
      aratdarName: json['aratdar_name'] ?? '',
      commissionType: (json['commission_type'] as num?)?.toInt() ?? 1,
      commissionLabel: json['commission_label'] ?? 'Percentage (%)',
      commissionValue: (json['commission_value'] as num?)?.toDouble() ?? 0.0,
      agreementStart: json['agreement_start'] as String?,
      agreementEnd: json['agreement_end'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  String get displayRate {
    if (commissionType == 2) {
      return '৳${commissionValue.toStringAsFixed(0)} / বস্তা';
    }
    return '${commissionValue.toStringAsFixed(1)}%';
  }

  String get typeTitle {
    return commissionType == 2 ? 'প্রতি বস্তা নির্দিষ্ট ফি' : 'বিক্রয় মূল্যের শতকরা (%)';
  }
}