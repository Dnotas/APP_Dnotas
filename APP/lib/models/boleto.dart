class Boleto {
  final String id;
  final String customerId;
  final String? customerName;
  final double value;
  final DateTime dueDate;
  final String status;
  final String? description;
  final DateTime dateCreated;
  final String? invoiceUrl;
  final String? bankSlipUrl;
  final String? pixQrCode;
  final String billingType;
  final String? nossoNumero;
  final double? netValue;
  final double? grossValue;

  Boleto({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.value,
    required this.dueDate,
    required this.status,
    this.description,
    required this.dateCreated,
    this.invoiceUrl,
    this.bankSlipUrl,
    this.pixQrCode,
    required this.billingType,
    this.nossoNumero,
    this.netValue,
    this.grossValue,
  });

  /// Cria um Boleto a partir do JSON da API Asaas
  factory Boleto.fromAsaasJson(Map<String, dynamic> json) {
    return Boleto(
      id: json['id'] ?? '',
      customerId: json['customer'] ?? '',
      customerName: json['customerName'],
      value: (json['value'] ?? 0.0).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'UNKNOWN',
      description: json['description'],
      dateCreated: DateTime.parse(json['dateCreated'] ?? DateTime.now().toIso8601String()),
      invoiceUrl: json['invoiceUrl'],
      bankSlipUrl: json['bankSlipUrl'],
      pixQrCode: json['pixQrCode'],
      billingType: json['billingType'] ?? 'BOLETO',
      nossoNumero: json['nossoNumero'],
      netValue: (json['netValue'] ?? 0.0).toDouble(),
      grossValue: (json['grossValue'] ?? 0.0).toDouble(),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'value': value,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
      'invoiceUrl': invoiceUrl,
      'bankSlipUrl': bankSlipUrl,
      'pixQrCode': pixQrCode,
      'billingType': billingType,
      'nossoNumero': nossoNumero,
      'netValue': netValue,
      'grossValue': grossValue,
    };
  }

  /// Cria a partir do JSON local
  factory Boleto.fromJson(Map<String, dynamic> json) {
    return Boleto(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'],
      value: (json['value'] ?? 0.0).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'UNKNOWN',
      description: json['description'],
      dateCreated: DateTime.parse(json['dateCreated'] ?? DateTime.now().toIso8601String()),
      invoiceUrl: json['invoiceUrl'],
      bankSlipUrl: json['bankSlipUrl'],
      pixQrCode: json['pixQrCode'],
      billingType: json['billingType'] ?? 'BOLETO',
      nossoNumero: json['nossoNumero'],
      netValue: (json['netValue'] ?? 0.0)?.toDouble(),
      grossValue: (json['grossValue'] ?? 0.0)?.toDouble(),
    );
  }

  /// Status em português
  String get statusPortugues {
    switch (status) {
      case 'PENDING':
        return 'Pendente';
      case 'RECEIVED':
        return 'Recebido';
      case 'CONFIRMED':
        return 'Confirmado';
      case 'OVERDUE':
        return 'Vencido';
      case 'REFUNDED':
        return 'Estornado';
      case 'RECEIVED_IN_CASH':
        return 'Recebido em Dinheiro';
      case 'REFUND_REQUESTED':
        return 'Estorno Solicitado';
      case 'CHARGEBACK_REQUESTED':
        return 'Chargeback Solicitado';
      case 'CHARGEBACK_DISPUTE':
        return 'Disputa de Chargeback';
      case 'AWAITING_CHARGEBACK_REVERSAL':
        return 'Aguardando Reversão';
      default:
        return status;
    }
  }

  /// Cor do status
  String get statusColor {
    switch (status) {
      case 'PENDING':
        return '#FFA500'; // Orange
      case 'RECEIVED':
      case 'CONFIRMED':
      case 'RECEIVED_IN_CASH':
        return '#4CAF50'; // Green
      case 'OVERDUE':
        return '#F44336'; // Red
      case 'REFUNDED':
      case 'REFUND_REQUESTED':
        return '#9E9E9E'; // Gray
      case 'CHARGEBACK_REQUESTED':
      case 'CHARGEBACK_DISPUTE':
      case 'AWAITING_CHARGEBACK_REVERSAL':
        return '#FF9800'; // Amber
      default:
        return '#607D8B'; // Blue Gray
    }
  }

  /// Verifica se está vencido
  bool get isOverdue {
    return status == 'OVERDUE' || 
           (status == 'PENDING' && dueDate.isBefore(DateTime.now()));
  }

  /// Verifica se está próximo do vencimento
  bool get isNearDue {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return status == 'PENDING' && difference >= 0 && difference <= 10;
  }

  /// Dias até o vencimento
  int get daysToDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  /// Valor formatado
  String get valueFormatted {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Data de vencimento formatada
  String get dueDateFormatted {
    return '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}';
  }

  /// Data de criação formatada
  String get dateCreatedFormatted {
    return '${dateCreated.day.toString().padLeft(2, '0')}/${dateCreated.month.toString().padLeft(2, '0')}/${dateCreated.year}';
  }

  /// Cópia com alterações
  Boleto copyWith({
    String? id,
    String? customerId,
    String? customerName,
    double? value,
    DateTime? dueDate,
    String? status,
    String? description,
    DateTime? dateCreated,
    String? invoiceUrl,
    String? bankSlipUrl,
    String? pixQrCode,
    String? billingType,
    String? nossoNumero,
    double? netValue,
    double? grossValue,
  }) {
    return Boleto(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      value: value ?? this.value,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      description: description ?? this.description,
      dateCreated: dateCreated ?? this.dateCreated,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      bankSlipUrl: bankSlipUrl ?? this.bankSlipUrl,
      pixQrCode: pixQrCode ?? this.pixQrCode,
      billingType: billingType ?? this.billingType,
      nossoNumero: nossoNumero ?? this.nossoNumero,
      netValue: netValue ?? this.netValue,
      grossValue: grossValue ?? this.grossValue,
    );
  }

  @override
  String toString() {
    return 'Boleto{id: $id, value: $value, dueDate: $dueDate, status: $status}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Boleto &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}