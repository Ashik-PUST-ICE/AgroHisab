class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? role;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? json['username'] ?? 'ব্যবসায়ী',
      email: json['email'],
      phone: json['phone'] ?? json['mobile'],
      role: json['role'] ?? 'owner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}