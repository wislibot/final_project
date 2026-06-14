import 'package:flutter/material.dart';

class PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const PreferenceTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: const Color(0xFF00BFA6),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
      ),
    );
  }
}