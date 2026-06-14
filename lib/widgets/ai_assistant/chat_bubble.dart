import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Column(
        crossAxisAlignment:
            isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,

        children: [

          Container(
            constraints: const BoxConstraints(
              maxWidth: 300,
            ),

            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(

              color:
                  isUser
                      ? const Color(0xFF00BFA6)
                      : Colors.white,

              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: [

                BoxShadow(
                  color:
                      Colors.black.withOpacity(
                    0.05,
                  ),

                  blurRadius: 10,

                  offset:
                      const Offset(0, 4),
                ),

              ],
            ),

            child: Text(

              message,

              style: TextStyle(

                color:
                    isUser
                        ? Colors.white
                        : Colors.black87,

                fontSize: 15,

                height: 1.5,
              ),
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            "09:35 PM",

            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

