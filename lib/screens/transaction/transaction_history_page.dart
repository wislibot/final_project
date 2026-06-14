import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../repositories/transaction_repository.dart';
import '../../models/transaction_model.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = TransactionRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: const Color(0xFF00BFA6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: repository.getTransactions(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BFA6)),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No transactions yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start by recording your first expense",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final transaction = TransactionModel.fromMap(
                docs[index].data() as Map<String, dynamic>,
              );

              return _TransactionTile(transaction: transaction);
            },
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  IconData _categoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('lunch') || cat.contains('dinner')) {
      return Icons.restaurant_rounded;
    } else if (cat.contains('transport') || cat.contains('uber')) {
      return Icons.directions_car_rounded;
    } else if (cat.contains('shopping') || cat.contains('clothes')) {
      return Icons.shopping_bag_rounded;
    } else if (cat.contains('entertainment') || cat.contains('movie')) {
      return Icons.movie_rounded;
    } else if (cat.contains('bills') || cat.contains('utilities')) {
      return Icons.receipt_long_rounded;
    } else if (cat.contains('health') || cat.contains('medical')) {
      return Icons.local_hospital_rounded;
    } else {
      return Icons.attach_money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type.toLowerCase() != 'income';
    final amountColor = isExpense ? Colors.red.shade400 : Colors.green.shade600;
    final prefix = isExpense ? '-' : '+';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon(transaction.category),
                color: const Color(0xFF00BFA6),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$prefix\$${transaction.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d').format(transaction.createdAt),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
