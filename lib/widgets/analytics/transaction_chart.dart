import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TransactionChart extends StatelessWidget {
  const TransactionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        borderData: FlBorderData(show: false),

        gridData: FlGridData(show: true),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),

        lineBarsData: [

          LineChartBarData(
            isCurved: true,

            color: const Color(0xFF00BFA6),

            barWidth: 4,

            spots: const [

              FlSpot(1, 80),
              FlSpot(2, 110),
              FlSpot(3, 95),
              FlSpot(4, 150),
              FlSpot(5, 130),
              FlSpot(6, 170),
              FlSpot(7, 140),

            ],
          ),

        ],
      ),
    );
  }
}