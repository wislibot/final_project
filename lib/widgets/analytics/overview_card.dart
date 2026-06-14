import 'package:flutter/material.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF10203F),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  title: "Monthly Spent",
                  value: "\$425",
                ),
              ),
              Expanded(
                child: _StatItem(
                  title: "Budget Limit",
                  value: "\$600",
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  title: "Today",
                  value: "\$35",
                ),
              ),
              Expanded(
                child: _StatItem(
                  title: "Remaining",
                  value: "\$175",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}