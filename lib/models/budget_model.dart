class BudgetModel {
  final String category;
  final double limit;
  final int month;
  final int year;
  final double spent;
  final int transactionCount;

  BudgetModel({
    required this.category,
    required this.limit,
    this.month = 0,
    this.year = 0,
    this.spent = 0,
    this.transactionCount = 0,
  });

  /// Remaining budget: limit minus spent.
  double get remaining => limit - spent;

  /// Percentage of budget used, clamped to [0, 999].
  double get percentUsed => (spent / limit * 100).clamp(0.0, 999.0);

  /// Health status string based on percent used.
  String get healthStatus {
    if (percentUsed > 100) return 'over_budget';
    if (percentUsed > 80) return 'over_pace';
    if (percentUsed > 50) return 'caution';
    return 'on_track';
  }

  /// Returns a copy with updated spending information.
  BudgetModel withSpending({
    required double spent,
    required int transactionCount,
  }) {
    return BudgetModel(
      category: category,
      limit: limit,
      month: month,
      year: year,
      spent: spent,
      transactionCount: transactionCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limit': limit,
      'month': month,
      'year': year,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      category: map['category'],
      limit: double.parse(
        map['limit'].toString(),
      ),
      month: (map['month'] as int?) ?? 0,
      year: (map['year'] as int?) ?? 0,
    );
  }
}
