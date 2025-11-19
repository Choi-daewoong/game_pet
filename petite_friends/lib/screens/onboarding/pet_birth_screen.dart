import 'package:flutter/material.dart';
import 'naming_screen.dart';

class PetBirthScreen extends StatefulWidget {
  const PetBirthScreen({super.key});

  @override
  State<PetBirthScreen> createState() => _PetBirthScreenState();
}

class _PetBirthScreenState extends State<PetBirthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _eggCracked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _crackEgg() {
    setState(() {
      _eggCracked = true;
    });
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const NamingScreen(),
          ),
        );
      }
    });
  }

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
              Text(
                _eggCracked ? '안녕! 👋' : '알을 터치해서 깨워보세요',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: _eggCracked ? null : _crackEgg,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _eggCracked ? _scaleAnimation.value : 1.0,
                      child: Container(
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
                          child: Text(
                            _eggCracked ? '🐱' : '🥚',
                            style: const TextStyle(fontSize: 100),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              if (_eggCracked)
                Text(
                  '귀여운 친구가 나왔어요!',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
