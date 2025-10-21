class UserModel {
  final String id;
  final String cnpj;
  final String nomeEmpresa;
  final String? email;
  final String? telefone;
  final String filialId;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final List<Map<String, dynamic>>? filiais; // Lista de filiais do cliente
  final bool isMatriz; // Se é matriz ou filial

  UserModel({
    required this.id,
    required this.cnpj,
    required this.nomeEmpresa,
    this.email,
    this.telefone,
    required this.filialId,
    required this.createdAt,
    this.lastLogin,
    this.filiais,
    this.isMatriz = true,
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
      filiais: json['filiais'] != null 
          ? List<Map<String, dynamic>>.from(json['filiais']) 
          : null,
      isMatriz: json['is_matriz'] ?? true,
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
      'filiais': filiais,
      'is_matriz': isMatriz,
    };
  }

  /// Retorna o CNPJ da filial selecionada ou da matriz
  String getCurrentCnpj(String? selectedFilialCnpj) {
    return selectedFilialCnpj ?? cnpj;
  }

  /// Verifica se tem filiais
  bool get hasFiliais {
    return filiais != null && filiais!.isNotEmpty;
  }

  /// Cria uma cópia com alterações
  UserModel copyWith({
    String? id,
    String? cnpj,
    String? nomeEmpresa,
    String? email,
    String? telefone,
    String? filialId,
    DateTime? createdAt,
    DateTime? lastLogin,
    List<Map<String, dynamic>>? filiais,
    bool? isMatriz,
  }) {
    return UserModel(
      id: id ?? this.id,
      cnpj: cnpj ?? this.cnpj,
      nomeEmpresa: nomeEmpresa ?? this.nomeEmpresa,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      filialId: filialId ?? this.filialId,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      filiais: filiais ?? this.filiais,
      isMatriz: isMatriz ?? this.isMatriz,
    );
  }
}
}