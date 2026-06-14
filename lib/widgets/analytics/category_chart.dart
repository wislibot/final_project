import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryChart({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text("No category data yet."),
      );
    }

    final entries = categoryTotals.entries.toList();
    final total = categoryTotals.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sectionsSpace: 3,
              sections: entries.map((entry) {
                final percent = total == 0
                    ? 0
                    : (entry.value / total) * 100;

                return PieChartSectionData(
                  value: entry.value,
                  title: "${percent.toStringAsFixed(0)}%",
                  radius: 58,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      "\$${entry.value.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}