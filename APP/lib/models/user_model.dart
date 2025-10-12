class UserModel {
  final String id;
  final String cnpj;
  final String nomeEmpresa;
  final String? email;
  final String? telefone;
  final String filialId;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.cnpj,
    required this.nomeEmpresa,
    this.email,
    this.telefone,
    required this.filialId,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      cnpj: json['cnpj'],
      nomeEmpresa: json['nome_empresa'],
      email: json['email'],
      telefone: json['telefone'],
      filialId: json['filial_id'],
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cnpj': cnpj,
      'nome_empresa': nomeEmpresa,
      'email': email,
      'telefone': telefone,
      'filial_id': filialId,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }
}