class MarketModel {
  final int id;
  final String name;
  final String? district;
  final String? address;
  final int type;
  final String typeLabel;
  final String? contactNotes;

  MarketModel({
    required this.id,
    required this.name,
    this.district,
    this.address,
    required this.type,
    required this.typeLabel,
    this.contactNotes,
  });

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      district: json['district'],
      address: json['address'],
      type: (json['type'] as num?)?.toInt() ?? 1,
      typeLabel: json['type_label'] ?? 'মোকাম / পাইকারি হাট',
      contactNotes: json['contact_notes'],
    );
  }
}