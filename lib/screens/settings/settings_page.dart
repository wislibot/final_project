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
                  children: const [
                    PreferenceTile(
                      icon: Icons.person,
                      title: "Profile",
                    ),

                    Divider(),

                    PreferenceTile(
                      icon: Icons.palette,
                      title: "Appearance",
                    ),

                    Divider(),

                    PreferenceTile(
                      icon: Icons.language,
                      title: "Language",
                    ),

                    Divider(),

                    PreferenceTile(
                      icon: Icons.security,
                      title: "Privacy",
                    ),

                    Divider(),

                    PreferenceTile(
                      icon: Icons.help_outline,
                      title: "Help",
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
}