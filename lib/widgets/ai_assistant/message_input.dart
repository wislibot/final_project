import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {

  final TextEditingController controller;

  final VoidCallback onSend;

  final VoidCallback onAttachImage;

  final VoidCallback onVoiceInput;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttachImage,
    required this.onVoiceInput,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(30),

        boxShadow: [

          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.06,
            ),

            blurRadius: 15,

            offset:
                const Offset(0, 5),
          ),

        ],
      ),

      child: Row(

        children: [

          IconButton(

            icon: const Icon(
              Icons.mic_none_rounded,
              color: Color(0xFF00BFA6),
            ),

            onPressed: onVoiceInput,
          ),

          Expanded(

            child: TextField(

              controller: controller,

              decoration:
                  const InputDecoration(

                hintText:
                    "Ask me anything...",

                border:
                    InputBorder.none,
              ),
            ),
          ),

          IconButton(

            icon: const Icon(
              Icons.attach_file_rounded,
              color: Color(0xFF00BFA6),
            ),

            onPressed: onAttachImage,
          ),

          Container(

            decoration:
                const BoxDecoration(

              shape: BoxShape.circle,

              color: Color(0xFF00BFA6),
            ),

            child: IconButton(

              icon: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
              ),

              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

