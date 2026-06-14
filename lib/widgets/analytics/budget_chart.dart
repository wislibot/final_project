import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BudgetChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const BudgetChart({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    final categories = categoryTotals.keys.toList();
    final values = categoryTotals.values.toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Spending by Category",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            if (categoryTotals.isEmpty)
              const Center(
                child: Text("No transactions yet."),
              )
            else
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 || index >= categories.length) {
                              return const SizedBox();
                            }

                            return Text(
                              categories[index],
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(
                      values.length,
                      (index) => makeGroup(index, values[index]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 18,
          color: Colors.teal,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}