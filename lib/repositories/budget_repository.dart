import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/budget_model.dart';

class BudgetRepository {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  /// Save or update a budget for a specific month
  Future<void> saveBudget(BudgetModel budget) async {
    final query = await firestore
        .collection('budgets')
        .where('category', isEqualTo: budget.category)
        .where('month', isEqualTo: budget.month)
        .where('year', isEqualTo: budget.year)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(budget.toMap());
    } else {
      await firestore
          .collection('budgets')
          .add(budget.toMap());
    }
  }

  /// Save all budgets for a month (bulk)
  Future<void> saveMonthlyBudgets(
      List<BudgetModel> budgets) async {
    for (final b in budgets) {
      await saveBudget(b);
    }
  }

  /// Fetch budgets for a specific month
  Future<List<BudgetModel>> fetchBudgetsForMonth(
      int month, int year) async {
    final snapshot = await firestore
        .collection('budgets')
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();

    return snapshot.docs
        .map((doc) => BudgetModel.fromMap(doc.data()))
        .toList();
  }

  /// Legacy: fetch all budgets
  Future<List<BudgetModel>> fetchBudgets() async {
    final snapshot =
        await firestore.collection('budgets').get();
    return snapshot.docs
        .map((doc) => BudgetModel.fromMap(doc.data()))
        .toList();
  }

  Stream<QuerySnapshot> getBudgets() {
    return firestore
        .collection('budgets')
        .snapshots();
  }

  /// Delete all budgets for a specific month
  Future<int> deleteBudgetsForMonth(int month, int year) async {
    final snapshot = await firestore
        .collection('budgets')
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();

    int count = 0;
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
      count++;
    }
    return count;
  }

  /// Delete all budgets
  Future<int> deleteAllBudgets() async {
    final snapshot = await firestore.collection('budgets').get();
    int count = 0;
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
      count++;
    }
    return count;
  }
}
