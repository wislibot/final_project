class TransactionModel {
  final String type;
  final String category;
  final double amount;
  final String description;
  final DateTime createdAt;

  TransactionModel({
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
  factory TransactionModel.fromMap(
    Map<String, dynamic> map) {

  return TransactionModel(
    type: map["type"],
    category: map["category"],
    amount: double.parse(
      map["amount"].toString(),
    ),
    description: map["description"],
    createdAt: map["createdAt"].toDate(),
  );
}

}