import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../repositories/transaction_repository.dart';
import '../../models/transaction_model.dart';
import '../../core/localization/app_localizations.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = TransactionRepository();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.transactionHistory),
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
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    loc.noTransactionsYet,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.startRecording,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
                docId: docs[index].id,
              );

              return _TransactionTile(
                transaction: transaction,
                docId: docs[index].id,
                repository: repository,
              );
            },
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String docId;
  final TransactionRepository repository;

  const _TransactionTile({
    required this.transaction,
    required this.docId,
    required this.repository,
  });

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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Transaction"),
        content: Text("Remove \"${transaction.description}\" (${transaction.category})?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              repository.deleteTransaction(docId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Transaction deleted"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type.toLowerCase() != 'income';
    final amountColor = isExpense ? Colors.red.shade400 : Colors.green.shade600;
    final prefix = isExpense ? '-' : '+';

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        _confirmDelete(context);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 28),
      ),
      child: Card(
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
                  color: const Color(0xFFF5E6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(transaction.category),
                  color: Colors.deepPurple,
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
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${transaction.category} · ${DateFormat('MMM d').format(transaction.createdAt)}",
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$prefix\$${transaction.amount.toStringAsFixed(2)}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: amountColor),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Icon(Icons.delete_outline, color: Colors.grey[600], size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
