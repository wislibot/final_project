class TransactionModel {
  final String id;
  final String type;
  final String category;
  final double amount;
  final String description;
  final DateTime createdAt;

  TransactionModel({
    this.id = '',
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'createdAt': createdAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, {String docId = ''}) {
    return TransactionModel(
      id: docId,
      type: map["type"] ?? '',
      category: map["category"] ?? 'Other',
      amount: double.parse(map["amount"].toString()),
      description: map["description"] ?? '',
      createdAt: map["createdAt"] != null ? map["createdAt"].toDate() : DateTime.now(),
    );
  }
}
