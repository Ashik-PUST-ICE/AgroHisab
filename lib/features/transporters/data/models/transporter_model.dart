class TransporterModel {
  final int id;
  final String name;
  final String? phone;
  final String? truckNumber;
  final String? driverName;
  final String? driverPhone;
  final String? address;
  final String? notes;

  TransporterModel({
    required this.id,
    required this.name,
    this.phone,
    this.truckNumber,
    this.driverName,
    this.driverPhone,
    this.address,
    this.notes,
  });

  factory TransporterModel.fromJson(Map<String, dynamic> json) {
    return TransporterModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      truckNumber: json['truck_number'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      address: json['address'],
      notes: json['notes'],
    );
  }
}