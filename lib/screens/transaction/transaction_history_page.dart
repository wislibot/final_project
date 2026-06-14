import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../repositories/transaction_repository.dart';

import '../../models/transaction_model.dart';
import '../../widgets/transaction/transaction_card.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {

    final repository = TransactionRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transaction History",
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: repository.getTransactions(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,

            itemBuilder: (context, index) {

              final transaction =
                TransactionModel.fromMap(
                  docs[index].data()
                      as Map<String, dynamic>,
                );

            return TransactionCard(
              transaction: transaction,
            );
            },
          );
        },
      ),
    );
  }
}