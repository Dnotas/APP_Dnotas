class BoletoModel {
  final String id;
  final String numero;
  final String descricao;
  final double valor;
  final DateTime dataVencimento;
  final DateTime? dataPagamento;
  final String status; // 'pendente', 'pago', 'vencido'
  final String? codigoBarras;
  final String? urlPdf;
  final String? nossoNumero;

  BoletoModel({
    required this.id,
    required this.numero,
    required this.descricao,
    required this.valor,
    required this.dataVencimento,
    this.dataPagamento,
    required this.status,
    this.codigoBarras,
    this.urlPdf,
    this.nossoNumero,
  });

  factory BoletoModel.fromJson(Map<String, dynamic> json) {
    return BoletoModel(
      id: json['id'].toString(),
      numero: json['numero'] ?? '',
      descricao: json['descricao'] ?? '',
      valor: (json['valor'] ?? 0.0).toDouble(),
      dataVencimento: DateTime.parse(json['data_vencimento'] ?? DateTime.now().toIso8601String()),
      dataPagamento: json['data_pagamento'] != null 
          ? DateTime.parse(json['data_pagamento']) 
          : null,
      status: json['status'] ?? 'pendente',
      codigoBarras: json['codigo_barras'],
      urlPdf: json['url_pdf'],
      nossoNumero: json['nosso_numero'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'descricao': descricao,
      'valor': valor,
      'data_vencimento': dataVencimento.toIso8601String(),
      'data_pagamento': dataPagamento?.toIso8601String(),
      'status': status,
      'codigo_barras': codigoBarras,
      'url_pdf': urlPdf,
      'nosso_numero': nossoNumero,
    };
  }

  bool get isVencido => dataVencimento.isBefore(DateTime.now()) && status == 'pendente';
}