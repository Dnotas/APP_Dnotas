class Customer {
  final String id;
  final String name;
  final String? email;
  final String? cpfCnpj;
  final String? phone;
  final DateTime? createdAt;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.cpfCnpj,
    this.phone,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      cpfCnpj: json['cpfCnpj'],
      phone: json['phone'],
      createdAt: json['dateCreated'] != null 
        ? DateTime.parse(json['dateCreated']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'cpfCnpj': cpfCnpj,
      'phone': phone,
      'dateCreated': createdAt?.toIso8601String(),
    };
  }
}