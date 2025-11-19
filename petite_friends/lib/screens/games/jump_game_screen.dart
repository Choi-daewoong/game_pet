import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/currency_provider.dart';
import '../../providers/pet_provider.dart';
import '../../services/widget_service.dart';
import '../../models/game_result.dart';

class JumpGameScreen extends ConsumerStatefulWidget {
  const JumpGameScreen({super.key});

  @override
  ConsumerState<JumpGameScreen> createState() => _JumpGameScreenState();
}

class _JumpGameScreenState extends ConsumerState<JumpGameScreen> {
  bool _gameStarted = false;
  bool _gameOver = false;
  int _distance = 0;
  int _coinsEarned = 0;

  double _petY = 0;
  double _petVelocity = 0;
  final double _gravity = 0.8;
  final double _jumpForce = -15;

  List<Obstacle> _obstacles = [];
  Timer? _gameTimer;
  final Random _random = Random();

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    // Consume heart
    final consumed = ref.read(currencyProvider.notifier).consumeHeart();
    if (!consumed) {
      _showNoHeartsDialog();
      return;
    }

    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _distance = 0;
      _coinsEarned = 0;
      _petY = 0;
      _petVelocity = 0;
      _obstacles = [];
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _updateGame();
    });
  }

  void _updateGame() {
    if (_gameOver) {
      _gameTimer?.cancel();
      return;
    }

    setState(() {
      // Update pet position
      _petVelocity += _gravity;
      _petY += _petVelocity;

      // Ground collision
      if (_petY > 0) {
        _petY = 0;
        _petVelocity = 0;
      }

      // Update obstacles
      for (var obstacle in _obstacles) {
        obstacle.x -= 5;
      }

      // Remove off-screen obstacles
      _obstacles.removeWhere((obstacle) => obstacle.x < -100);

      // Add new obstacles
      if (_obstacles.isEmpty ||
          _obstacles.last.x < MediaQuery.of(context).size.width - 300) {
        _obstacles.add(Obstacle(
          x: MediaQuery.of(context).size.width,
          height: 40 + _random.nextDouble() * 40,
        ));
      }

      // Check collision
      for (var obstacle in _obstacles) {
        if (obstacle.x < 100 &&
            obstacle.x > -50 &&
            _petY > -obstacle.height) {
          _endGame();
          return;
        }
      }

      // Update distance
      _distance++;

      // Calculate coins (every 50m)
      if (_distance % 50 == 0 && _distance > 0) {
        _coinsEarned++;
      }
    });
  }

  void _jump() {
    if (!_gameStarted || _gameOver) return;
    if (_petY == 0) {
      setState(() {
        _petVelocity = _jumpForce;
      });
    }
  }

  void _endGame() {
    setState(() {
      _gameOver = true;
    });
    _gameTimer?.cancel();

    // Save coins
    if (_coinsEarned > 0) {
      ref.read(currencyProvider.notifier).addCoins(_coinsEarned);
    }

    // Update pet mood
    ref.read(petProvider.notifier).playGame(15);

    // Update widget
    _updateWidget();

    // Show result
    Future.delayed(const Duration(milliseconds: 500), () {
      _showResultDialog();
    });
  }

  void _updateWidget() async {
    final pet = ref.read(petProvider);
    final currency = ref.read(currencyProvider);
    if (pet != null && currency != null) {
      await WidgetService().updateWidget(pet, currency);
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('게임 종료'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              Text(
                '거리: ${_distance}m',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '획득 코인: $_coinsEarned개',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
            if (ref.read(currencyProvider)!.hearts > 0)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startGame();
                },
                child: const Text('다시 하기'),
              ),
          ],
        );
      },
    );
  }

  void _showNoHeartsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('하트가 부족해요'),
          content: const Text('하트를 충전하거나 시간이 지나면 자동으로 회복됩니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('점프 산책'),
        backgroundColor: Colors.green,
      ),
      body: GestureDetector(
        onTap: _jump,
        child: Container(
          color: const Color(0xFFFFF9F0),
          child: Stack(
            children: [
              // Distance counter
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '${_distance}m',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Coins
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$_coinsEarned',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pet
              if (_gameStarted)
                Positioned(
                  left: 50,
                  bottom: 100 - _petY,
                  child: const Text(
                    '🐱',
                    style: TextStyle(fontSize: 40),
                  ),
                ),

              // Obstacles
              ..._obstacles.map((obstacle) {
                return Positioned(
                  left: obstacle.x,
                  bottom: 100,
                  child: Container(
                    width: 50,
                    height: obstacle.height,
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),

              // Ground
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  color: const Color(0xFFB4E7CE).withOpacity(0.3),
                  child: const Center(
                    child: Text(
                      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ),

              // Start button
              if (!_gameStarted)
                Center(
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      '게임 시작',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

              // Instructions
              if (!_gameStarted)
                const Positioned(
                  bottom: 150,
                  left: 0,
                  right: 0,
                  child: Text(
                    '화면을 터치하여 점프하세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Obstacle {
  double x;
  double height;

  Obstacle({required this.x, required this.height});
}
