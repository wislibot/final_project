import 'package:flutter/material.dart';

import 'budget_chart.dart';
import 'category_chart.dart';
import 'transaction_chart.dart';

class ChartSection extends StatelessWidget {
  
  final Map<String,double> categoryTotals;

  const ChartSection({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.04,
              ),

              blurRadius: 10,
            ),
          ],
        ),

        child: Column(
          children: [

            TabBar(
              labelColor:
                  const Color(0xFF00BFA6),

              unselectedLabelColor:
                  Colors.grey,

              indicatorColor: const Color(0xFF00BFA6),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
              tabs: const [

                Tab(
                  text:
                      "Budget vs Spent",
                ),

                Tab(
                  text:
                      "Category",
                ),

                Tab(
                  text:
                      "Transactions",
                ),

              ],
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(
              height: 280,

              child: TabBarView(

                children: [

                  BudgetChart(categoryTotals: categoryTotals,),

                  CategoryChart(categoryTotals: categoryTotals,),

                  const TransactionChart(),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
