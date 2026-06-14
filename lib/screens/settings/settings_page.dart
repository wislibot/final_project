import 'package:flutter/material.dart';

import '../../widgets/settings/preference_tile.dart';
import '../../widgets/settings/section_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              SectionCard(
                child: Column(
                  children: [
                    PreferenceTile(
                      icon: Icons.person,
                      title: "Profile",
                      onTap: () => _showComingSoon(context, "Profile"),
                    ),

                    const Divider(),

                    PreferenceTile(
                      icon: Icons.palette,
                      title: "Appearance",
                      onTap: () => _showComingSoon(context, "Appearance"),
                    ),

                    const Divider(),

                    PreferenceTile(
                      icon: Icons.language,
                      title: "Language",
                      onTap: () => _showComingSoon(context, "Language"),
                    ),

                    const Divider(),

                    PreferenceTile(
                      icon: Icons.security,
                      title: "Privacy",
                      onTap: () => _showComingSoon(context, "Privacy"),
                    ),

                    const Divider(),

                    PreferenceTile(
                      icon: Icons.help_outline,
                      title: "Help",
                      onTap: () => _showComingSoon(context, "Help"),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature settings coming soon'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF00BFA6),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}