import 'package:flutter/material.dart';

class MonthlyProgressCard extends StatelessWidget {
  const MonthlyProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    const double progress = 0.7;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Progress",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "You have used 70% of your monthly budget",
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: const Color(0xFFE6F7F3),
              color: const Color(0xFF00BFA6),
            ),
          ),

          const SizedBox(height: 14),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$425 spent",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "\$175 remaining",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00BFA6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}