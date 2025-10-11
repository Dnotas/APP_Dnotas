class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final String type; // 'received' ou 'sent'
  final DateTime date;
  final String? category;
  final String? reference;

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.category,
    this.reference,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: json['type'] ?? 'received',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      category: json['category'],
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'category': category,
      'reference': reference,
    };
  }
}