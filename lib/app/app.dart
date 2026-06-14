import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';

import '../theme/light_theme.dart';
import '../theme/dark_theme.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../screens/home/home_page.dart';
import '../screens/auth/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "AI Finance Assistant",

      theme: LightTheme.theme,

      darkTheme: DarkTheme.theme,

      themeMode: ThemeMode.light,

      home: StreamBuilder<User?>(
        stream:
            FirebaseAuth.instance.authStateChanges(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const SplashScreen();
          }

          if (snapshot.hasData) {

            return const HomePage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}