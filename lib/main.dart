import 'package:flutter/material.dart';
import 'splash.dart';
import 'login.dart';

void main() {
  runApp(const ArthSaathiApp());
}

/// Shared design tokens used across all ArthSaathi pages.
class AppColors {
  static const Color navy = Color(0xFF123A5E); // primary buttons / headings
  static const Color navyDark = Color(0xFF0E2C47);
  static const Color teal = Color(0xFF2E9C7A); // logo swirl / accents
  static const Color background = Color(0xFFF4F7FA);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color border = Color(0xFFE3E8EE);
}

class ArthSaathiApp extends StatelessWidget {
  const ArthSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArthSaathi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          primary: AppColors.navy,
        ),
        fontFamily: 'Roboto',
      ),
      // As more pages are added, register their routes here.
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
      },
      initialRoute: '/',
    );
  }
}