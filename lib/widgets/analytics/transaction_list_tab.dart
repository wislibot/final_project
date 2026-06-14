import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';

class TransactionListTab extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionListTab({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recent = transactions.where((t) => t.createdAt.isAfter(weekAgo)).toList();
    final total = recent.fold<double>(0, (sum, t) => sum + t.amount);

    if (recent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text("No recent transactions", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Last 7 Days summary ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Last 7 Days", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        "${recent.length} transaction${recent.length > 1 ? 's' : ''} · \$${total.toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  "\$${total.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Transaction items ──
          Expanded(
            child: ListView.separated(
              itemCount: recent.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final t = recent[index];
                return _TransactionRow(transaction: t);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionRow({required this.transaction});

  IconData _icon(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('food') || c.contains('lunch') || c.contains('dinner')) return Icons.restaurant_rounded;
    if (c.contains('transport')) return Icons.directions_car_rounded;
    if (c.contains('shopping')) return Icons.shopping_bag_rounded;
    if (c.contains('entertainment')) return Icons.movie_rounded;
    if (c.contains('bills')) return Icons.receipt_long_rounded;
    if (c.contains('health')) return Icons.local_hospital_rounded;
    return Icons.attach_money_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon(transaction.category), color: Colors.deepPurple, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 3),
                Text(
                  "${transaction.category} · ${DateFormat('MMM d').format(transaction.createdAt)}",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            "-\$${transaction.amount.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
