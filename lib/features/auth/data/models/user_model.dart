class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? role;
  final String? firstName;
  final String? lastName;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.role,
    this.firstName,
    this.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? json['username'] ?? 'ব্যবসায়ী',
      email: json['email'],
      phone: json['phone'] ?? json['mobile'],
      role: json['role'] ?? 'owner',
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
