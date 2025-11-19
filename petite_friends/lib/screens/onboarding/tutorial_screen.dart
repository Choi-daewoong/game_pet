import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_screen.dart';
import '../../providers/pet_provider.dart';
import '../../providers/storage_provider.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  int _step = 0;
  bool _fedPet = false;

  void _nextStep() {
    if (_step == 0 && !_fedPet) {
      // Feed tutorial: wait for user to feed
      return;
    }

    if (_step < 2) {
      setState(() {
        _step++;
      });
    } else {
      _completeOnboarding();
    }
  }

  void _feedPet() {
    ref.read(petProvider.notifier).feed();
    setState(() {
      _fedPet = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      _nextStep();
    });
  }

  void _completeOnboarding() {
    final storage = ref.read(storageProvider);
    storage.setFirstRunComplete();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              _buildStepContent(pet),
              const Spacer(),
              if (_step > 0 || _fedPet)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_step == 2 ? '시작하기' : '다음'),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(dynamic pet) {
    switch (_step) {
      case 0:
        return Column(
          children: [
            const Text(
              '🐱',
              style: TextStyle(fontSize: 100),
            ),
            const SizedBox(height: 24),
            Text(
              '${pet?.name ?? '친구'}가 배고픈가 봐요\n밥을 줘보세요',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            if (!_fedPet)
              ElevatedButton.icon(
                onPressed: _feedPet,
                icon: const Icon(Icons.restaurant),
                label: const Text('밥 주기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              )
            else
              Column(
                children: [
                  const Text(
                    '😊',
                    style: TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '맛있게 먹었어요!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
          ],
        );

      case 1:
        return Column(
          children: [
            const Text(
              '🎮',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              '게임을 하면서\n함께 놀 수 있어요',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '게임을 하면 코인을 얻을 수 있고\n${pet?.name ?? '친구'}의 기분도 좋아져요',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        );

      case 2:
        return Column(
          children: [
            const Text(
              '💕',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              '준비 완료!',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '${pet?.name ?? '친구'}와 함께\n즐거운 시간을 보내세요!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD3B6).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD3B6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 팁',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 매일 밥을 주고 돌봐주세요\n'
                    '• 게임을 하면 코인을 얻을 수 있어요\n'
                    '• 홈 화면에 위젯을 추가하면 편리해요',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
