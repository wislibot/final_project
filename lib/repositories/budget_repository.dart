import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/budget_model.dart';

class BudgetRepository {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<void> addBudget(
      BudgetModel budget) async {

    await firestore
        .collection('budgets')
        .add(
          budget.toMap(),
        );
  }

  Stream<QuerySnapshot> getBudgets() {

    return firestore
        .collection('budgets')
        .snapshots();

  }
}