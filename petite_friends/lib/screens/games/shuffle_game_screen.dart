import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/currency_provider.dart';
import '../../providers/pet_provider.dart';
import '../../services/widget_service.dart';

class ShuffleGameScreen extends ConsumerStatefulWidget {
  const ShuffleGameScreen({super.key});

  @override
  ConsumerState<ShuffleGameScreen> createState() => _ShuffleGameScreenState();
}

class _ShuffleGameScreenState extends ConsumerState<ShuffleGameScreen> {
  bool _gameStarted = false;
  int _currentRound = 0;
  int _correctAnswers = 0;
  int _foodPosition = 1; // 0, 1, 2
  bool _isShuffling = false;
  bool _answerRevealed = false;
  int? _selectedCup;

  final List<int> _roundShuffles = [3, 5, 7]; // 각 라운드별 셔플 횟수
  final Random _random = Random();

  void _startGame() {
    // Consume heart
    final consumed = ref.read(currencyProvider.notifier).consumeHeart();
    if (!consumed) {
      _showNoHeartsDialog();
      return;
    }

    setState(() {
      _gameStarted = true;
      _currentRound = 0;
      _correctAnswers = 0;
    });

    _startRound();
  }

  void _startRound() {
    setState(() {
      _foodPosition = _random.nextInt(3);
      _selectedCup = null;
      _answerRevealed = false;
      _isShuffling = false;
    });

    // Show food first
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isShuffling = true;
      });
      _shuffleCups();
    });
  }

  Future<void> _shuffleCups() async {
    final shuffleCount = _roundShuffles[_currentRound];

    for (int i = 0; i < shuffleCount; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      setState(() {
        // Swap random positions
        final pos1 = _random.nextInt(3);
        var pos2 = _random.nextInt(3);
        while (pos2 == pos1) {
          pos2 = _random.nextInt(3);
        }

        if (_foodPosition == pos1) {
          _foodPosition = pos2;
        } else if (_foodPosition == pos2) {
          _foodPosition = pos1;
        }
      });
    }

    setState(() {
      _isShuffling = false;
    });
  }

  void _selectCup(int position) {
    if (_isShuffling || _answerRevealed) return;

    setState(() {
      _selectedCup = position;
      _answerRevealed = true;
    });

    final isCorrect = position == _foodPosition;

    if (isCorrect) {
      _correctAnswers++;
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (isCorrect && _currentRound < 2) {
        // Next round
        setState(() {
          _currentRound++;
        });
        _startRound();
      } else {
        // Game over
        _endGame(isCorrect);
      }
    });
  }

  void _endGame(bool lastCorrect) {
    final totalCoins = _correctAnswers == 3 ? 1 : 0;

    if (totalCoins > 0) {
      ref.read(currencyProvider.notifier).addCoins(totalCoins);
    }

    ref.read(petProvider.notifier).playGame(10);

    // Update widget
    _updateWidget();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _showResultDialog(totalCoins);
    });
  }

  void _updateWidget() async {
    final pet = ref.read(petProvider);
    final currency = ref.read(currencyProvider);
    if (pet != null && currency != null) {
      await WidgetService().updateWidget(pet, currency);
    }
  }

  void _showResultDialog(int coins) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(_correctAnswers == 3 ? '성공!' : '아쉬워요'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _correctAnswers == 3 ? '🎉' : '😊',
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              Text(
                '맞춘 개수: $_correctAnswers / 3',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (coins > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '획득 코인: $coins개',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
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
        title: const Text('먹이 찾기'),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (_gameStarted) ...[
                // Round indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 80,
                        height: 40,
                        decoration: BoxDecoration(
                          color: index < _currentRound
                              ? Colors.green
                              : index == _currentRound
                                  ? Colors.orange
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}단계',
                            style: TextStyle(
                              color: index <= _currentRound
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 32),

                // Instructions
                if (!_isShuffling && !_answerRevealed)
                  const Text(
                    '간식이 어느 컵에 있는지\n잘 기억하세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (_isShuffling)
                  const Text(
                    '섞는 중...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  )
                else if (_answerRevealed)
                  Text(
                    _selectedCup == _foodPosition ? '정답!' : '틀렸어요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _selectedCup == _foodPosition
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
              ],

              const Spacer(),

              // Cups
              if (_gameStarted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) {
                    return _buildCup(index);
                  }),
                ),

              const Spacer(),

              // Start button
              if (!_gameStarted)
                Column(
                  children: [
                    const Text(
                      '🥫',
                      style: TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '섞인 컵 중에서\n간식이 든 컵을 찾아보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
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
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCup(int index) {
    final isSelected = _selectedCup == index;
    final showFood = (index == _foodPosition && !_isShuffling) ||
        (index == _foodPosition && _answerRevealed);

    return GestureDetector(
      onTap: () => _selectCup(index),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected
                  ? (_selectedCup == _foodPosition
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3))
                  : Colors.brown.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.brown,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                showFood ? '🍖' : '🥫',
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
