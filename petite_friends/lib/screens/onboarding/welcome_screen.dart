import 'package:flutter/material.dart';
import 'pet_birth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Title
              Text(
                'Petite Friends',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 32,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                '새로운 친구를 만나보세요',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Pet Egg Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 140,
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFF9ECE).withOpacity(0.3),
                          const Color(0xFFB4E7CE).withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(70),
                    ),
                    child: const Center(
                      child: Text(
                        '🥚',
                        style: TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const PetBirthScreen(),
                      ),
                    );
                  },
                  child: const Text('시작하기'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
