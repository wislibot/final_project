import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/budget_repository.dart';
import '../../core/services/insights_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/analytics/overview_card.dart';
import '../../widgets/analytics/monthly_progress_card.dart';
import '../../widgets/analytics/insights_section.dart';
import '../../widgets/analytics/chart_section.dart';
import '../../widgets/analytics/date_range_selector.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedPreset = 'This Month';
  DateTimeRange? _customRange;

  DateTimeRange _getSelectedRange() {
    final now = DateTime.now();

    switch (_selectedPreset) {
      case 'This Week':
        final daysFromMonday = now.weekday - 1;
        final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));
        return DateTimeRange(start: start, end: now);

      case 'This Month':
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );

      case 'This Year':
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );

      case 'Custom':
        return _customRange ?? DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );

      case 'All Time':
      default:
        return DateTimeRange(
          start: DateTime(2020),
          end: now,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = TransactionRepository();
    final budgetRepository = BudgetRepository();
    final insightsService = InsightsService();
    final range = _getSelectedRange();

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

                if (transaction.createdAt.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
                    transaction.createdAt.isBefore(range.end.add(const Duration(days: 1)))) {
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
            }

            final daysInRange = range.end.difference(range.start).inDays + 1;
            final baseBudgetLimit = 1600.0;
            final budgetLimit = _selectedPreset == 'This Week'
                ? (baseBudgetLimit / 30 * 7)
                : _selectedPreset == 'This Year'
                    ? (baseBudgetLimit * 12)
                    : _selectedPreset == 'All Time'
                        ? (baseBudgetLimit * 12 * 2)
                        : (baseBudgetLimit / 30 * daysInRange);

            return FutureBuilder<List<BudgetModel>>(
              future: budgetRepository.fetchBudgets(),
              builder: (context, budgetSnapshot) {
                final budgets = budgetSnapshot.data ?? [];
                final insights = insightsService.generateInsights(allTransactions, budgets);

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
                        final loc = AppLocalizations.of(context);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.analytics, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(loc.financialInsights, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15)),
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
                        child: MonthlyProgressCard(totalSpent: totalSpent, budgetLimit: budgetLimit),
                      ),

                      const SizedBox(height: 16),

                      // ── Insights Section ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InsightsSection(insights: insights),
                      ),

                      const SizedBox(height: 20),

                      // ── Date Range Filter ──
                      DateRangeSelector(
                        selected: _selectedPreset,
                        customRange: _customRange,
                        onPresetSelected: (preset) => setState(() {
                          _selectedPreset = preset;
                          if (preset != 'Custom') _customRange = null;
                        }),
                        onCustomRangeSelected: (range) => setState(() {
                          _selectedPreset = 'Custom';
                          _customRange = range;
                        }),
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
            );
          },
        ),
      ),
    );
  }
}
