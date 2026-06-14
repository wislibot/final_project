import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../repositories/transaction_repository.dart';
import '../../widgets/analytics/insight_card.dart';
import '../../widgets/analytics/monthly_progress_card.dart';
import '../../widgets/analytics/overview_card.dart';
import '../../widgets/analytics/chart_section.dart';


class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  Future<void> selectDateRange(
        BuildContext context) async {

      await showDateRangePicker(
        context: context,

        firstDate: DateTime(2024),

        lastDate: DateTime.now(),
      );
    }
  @override
  Widget build(BuildContext context) {
    final repository = TransactionRepository();

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: repository.getTransactions(),
          builder: (context, snapshot) {
            final Map<String, double> categoryTotals = {};

            if (snapshot.hasData) {
              for (final doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;

                final category = data["category"] ?? "Other";
                final amount = double.parse(data["amount"].toString());

                categoryTotals[category] =
                    (categoryTotals[category] ?? 0) + amount;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Analytics",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Your financial insights",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const OverviewCard(),

                  const SizedBox(height: 20),

                  const MonthlyProgressCard(),

                  const SizedBox(height: 20),

                  const InsightCard(),

                  const SizedBox(height: 20),

                  ChartSection(
                    categoryTotals: categoryTotals,
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