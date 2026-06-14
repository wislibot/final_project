import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<void> addTransaction(
      TransactionModel transaction) async {
    await firestore
        .collection('transactions')
        .add(
          transaction.toMap(),
        );
  }

  Stream<QuerySnapshot> getTransactions() {
    return firestore
        .collection('transactions')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }
  Future<List<TransactionModel>> fetchTransactions() async {

      final snapshot = await firestore
          .collection("transactions")
          .get();

      return snapshot.docs
          .map(
            (doc) => TransactionModel.fromMap(
              doc.data(),
            ),
          )
          .toList();
    }
}