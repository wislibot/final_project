import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../widgets/analytics/overview_card.dart';
import '../../widgets/analytics/monthly_progress_card.dart';
import '../../widgets/analytics/chart_section.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = TransactionRepository();

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: repository.getTransactions(),
          builder: (context, snapshot) {
            final Map<String, double> categoryTotals = {};
            final List<TransactionModel> allTransactions = [];
            double totalSpent = 0;
            double todaySpent = 0;
            final now = DateTime.now();

            if (snapshot.hasData) {
              for (final doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final transaction = TransactionModel.fromMap(data, docId: doc.id);
                allTransactions.add(transaction);

                categoryTotals[transaction.category] =
                    (categoryTotals[transaction.category] ?? 0) + transaction.amount;

                if (transaction.type != "income") {
                  totalSpent += transaction.amount;
                  if (transaction.createdAt.year == now.year &&
                      transaction.createdAt.month == now.month &&
                      transaction.createdAt.day == now.day) {
                    todaySpent += transaction.amount;
                  }
                }
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Dark navy header ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0B2447), Color(0xFF19376D)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Analytics", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("Your financial insights", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Overview Card ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OverviewCard(monthlySpent: totalSpent, todaySpent: todaySpent),
                  ),

                  const SizedBox(height: 16),

                  // ── Monthly Progress Card ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MonthlyProgressCard(totalSpent: totalSpent, budgetLimit: 1600),
                  ),

                  const SizedBox(height: 20),

                  // ── Chart Section ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ChartSection(
                      categoryTotals: categoryTotals,
                      transactions: allTransactions,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
