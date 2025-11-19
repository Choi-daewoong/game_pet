import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/storage_provider.dart';

class PetiteFriendsApp extends ConsumerWidget {
  const PetiteFriendsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageProvider);
    final isFirstRun = storage.isFirstRun();

    return MaterialApp(
      title: 'Petite Friends',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: const Color(0xFFFF9ECE),
        scaffoldBackgroundColor: const Color(0xFFFFF9F0),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF4A4A4A),
          ),
          labelLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9ECE),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: isFirstRun ? const WelcomeScreen() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
