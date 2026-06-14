import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/budget_repository.dart';
import '../../core/services/insights_service.dart';
import '../../core/services/date_override_service.dart';
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
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadNow();
  }

  Future<void> _loadNow() async {
    final service = await DateOverrideService.getInstance();
    setState(() {
      _now = service.now();
    });
  }

  DateTimeRange _getRange() {
    final now = _now;
    switch (_selectedPreset) {
      case 'This Week':
        final daysFromMonday = now.weekday - 1;
        final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));
        return DateTimeRange(start: start, end: now);
      case 'This Month':
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0);
        return DateTimeRange(start: lastMonth, end: lastMonthEnd);
      case 'This Year':
        return DateTimeRange(start: DateTime(now.year, 1, 1), end: now);
      case 'Custom':
        return _customRange ?? DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
      default:
        return DateTimeRange(start: DateTime(2020), end: now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = TransactionRepository();
    final budgetRepository = BudgetRepository();
    final insightsService = InsightsService();
    final range = _getRange();

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: repository.getTransactions(),
          builder: (context, snapshot) {
            final Map<String, double> categoryTotals = {};
            final List<TransactionModel> allTransactions = [];
            final List<TransactionModel> filteredTransactions = [];
            double totalSpent = 0;
            double todaySpent = 0;
            double filteredSpent = 0;

            if (snapshot.hasData) {
              for (final doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final transaction = TransactionModel.fromMap(data, docId: doc.id);
                allTransactions.add(transaction);

                if (transaction.type != "income") {
                  totalSpent += transaction.amount;
                  if (transaction.createdAt.year == _now.year &&
                      transaction.createdAt.month == _now.month &&
                      transaction.createdAt.day == _now.day) {
                    todaySpent += transaction.amount;
                  }
                }

                final inRange = transaction.createdAt.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
                    transaction.createdAt.isBefore(range.end.add(const Duration(days: 1)));

                if (inRange) {
                  filteredTransactions.add(transaction);
                  if (transaction.type != "income") {
                    filteredSpent += transaction.amount;
                    categoryTotals[transaction.category] =
                        (categoryTotals[transaction.category] ?? 0) + transaction.amount;
                  }
                }
              }
            }

            return FutureBuilder<List<BudgetModel>>(
              future: budgetRepository.fetchBudgets(),
              builder: (context, budgetSnapshot) {
                final budgets = budgetSnapshot.data ?? [];
                final insights = insightsService.generateInsights(filteredTransactions, budgets);

                final rangeDays = range.end.difference(range.start).inDays + 1;
                final budgetLimit = _selectedPreset == 'All Time'
                    ? budgets.fold<double>(0, (sum, b) => sum + b.limit) * 12
                    : budgets.fold<double>(0, (sum, b) => sum + b.limit) * (rangeDays / 30);

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

                      const SizedBox(height: 16),

                      // ── Date range selector ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: DateRangeSelector(
                          selectedPreset: _selectedPreset,
                          customRange: _customRange,
                          onPresetSelected: (preset) => setState(() => _selectedPreset = preset),
                          onCustomRangeSelected: (range) => setState(() {
                            _customRange = range;
                            _selectedPreset = 'Custom';
                          }),
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (filteredTransactions.isEmpty && _selectedPreset != 'All Time')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.date_range_rounded, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text("No transactions for this period", style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                Text("Try selecting a different date range", style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        // ── Overview Card ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: OverviewCard(monthlySpent: filteredSpent, todaySpent: todaySpent),
                        ),

                        const SizedBox(height: 16),

                        // ── Monthly Progress Card ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: MonthlyProgressCard(totalSpent: filteredSpent, budgetLimit: budgetLimit > 0 ? budgetLimit : 1600),
                        ),

                        const SizedBox(height: 16),

                        // ── Insights Section ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InsightsSection(insights: insights),
                        ),

                        const SizedBox(height: 20),

                        // ── Chart Section ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ChartSection(
                            categoryTotals: categoryTotals,
                            transactions: filteredTransactions,
                          ),
                        ),
                      ],
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
