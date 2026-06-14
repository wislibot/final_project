import 'package:flutter/material.dart';

class QuickActionChip extends StatelessWidget {

  final String text;

  const QuickActionChip({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Colors.grey.shade200,
        ),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(
              0.03,
            ),

            blurRadius: 8,
          ),

        ],
      ),

      child: Text(
        text,

        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
