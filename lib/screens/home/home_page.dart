import 'package:flutter/material.dart';

import '../ai_assistant/ai_chat_page.dart';
import '../analytics/analytics_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 1;

  final List<Widget> pages = [
    const AnalyticsPage(),
    const AIChatPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,

        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF00BFA6),
          elevation: 6,
          child: const Icon(
            Icons.smart_toy,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              currentIndex = 1;
            });
          },
        ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.bar_chart,
                    color: currentIndex == 0
                        ? const Color(0xFF00BFA6)
                        : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      currentIndex = 0;
                    });
                  },
                ),

                const SizedBox(width: 60),

                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: currentIndex == 2
                        ? const Color(0xFF00BFA6)
                        : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      currentIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}