import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 160,
      ),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF08162D),
            Color(0xFF0B2447),
          ],
        ),
      ),

      child: const Padding(
        padding: EdgeInsets.all(25),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,

          children: [

            Text(
              "AI Assistant",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Ready to help",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),

            SizedBox(height: 6),

            Text(
              "Your smart financial companion",
              style: TextStyle(
                color: Colors.white60,
              ),
            ),

          ],
        ),
      ),
    );
  }
}