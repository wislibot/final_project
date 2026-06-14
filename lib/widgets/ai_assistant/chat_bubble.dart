import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime? timestamp;
  final Widget? card;

  const ChatBubble({
    super.key,
    required this.message,
    this.isUser = false,
    this.timestamp,
    this.card,
  });

  @override
  Widget build(BuildContext context) {
    final time = timestamp != null ? DateFormat('hh:mm a').format(timestamp!) : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // AI avatar (left side)
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA6).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF00BFA6),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF00BFA6) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF1A1A2E),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),

                // Optional card (for expense recorded, etc.)
                if (card != null) ...[
                  const SizedBox(height: 8),
                  card!,
                ],

                if (time.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Text(
                      time,
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),

          // User avatar (right side)
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA6).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF00BFA6),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Expense recorded card ──
class ExpenseRecordedCard extends StatelessWidget {
  final String description;
  final String amount;
  final String category;
  final String date;

  const ExpenseRecordedCard({
    super.key,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                "Expense Recorded",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          // Description
          Text(
            description,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          // Amount
          Text(
            "\$$amount",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 10),
          // Category pill + date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: const TextStyle(color: Color(0xFF00BFA6), fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
