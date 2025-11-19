import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pet_provider.dart';
import '../../providers/currency_provider.dart';

class HospitalScreen extends ConsumerStatefulWidget {
  const HospitalScreen({super.key});

  @override
  ConsumerState<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends ConsumerState<HospitalScreen> {
  String _selectedTreatment = '';
  int _petCount = 0;
  bool _isTreating = false;

  void _startFreeTreatment(String type) {
    setState(() {
      _selectedTreatment = type;
      _petCount = 0;
      _isTreating = true;
    });
  }

  void _onPet() {
    if (_petCount >= 50) return;

    setState(() {
      _petCount++;
    });

    if (_petCount >= 50) {
      _completeTreatment();
    }
  }

  void _completeTreatment() {
    ref.read(petProvider.notifier).cure(_selectedTreatment);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('치료 완료'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '💚',
                style: TextStyle(fontSize: 60),
              ),
              SizedBox(height: 16),
              Text(
                '건강해졌어요!',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
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

  void _instantTreatment(String method) {
    final pet = ref.read(petProvider);
    final currency = ref.read(currencyProvider);

    if (pet == null || currency == null) return;

    bool success = false;
    String message = '';

    if (method == 'affection') {
      if (currency.affectionPoints >= 50) {
        ref.read(currencyProvider.notifier).consumeAffectionPoints(50);
        success = true;
      } else {
        message = '교감 포인트가 부족해요';
      }
    } else if (method == 'coin') {
      if (currency.coins >= 20) {
        ref.read(currencyProvider.notifier).consumeCoins(20);
        success = true;
      } else {
        message = '코인이 부족해요';
      }
    } else if (method == 'ad') {
      // TODO: Show ad
      success = true;
    }

    if (success) {
      ref.read(petProvider.notifier).cure(pet.illness ?? '');
      _showSuccessDialog();
    } else if (message.isNotEmpty) {
      _showErrorDialog(message);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('치료 완료'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '💚',
                style: TextStyle(fontSize: 60),
              ),
              SizedBox(height: 16),
              Text(
                '즉시 건강해졌어요!',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    final currency = ref.watch(currencyProvider);

    if (pet == null || pet.illness == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('병원'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Text('건강해요!'),
        ),
      );
    }

    if (_isTreating) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('쓰다듬기 치료'),
          backgroundColor: Colors.red,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '쓰다듬어주세요\n($_petCount / 50)',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: _onPet,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '🤒',
                        style: TextStyle(fontSize: 100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: _petCount / 50,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                  minHeight: 10,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('병원'),
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet status
              Center(
                child: Column(
                  children: [
                    const Text(
                      '🤒',
                      style: TextStyle(fontSize: 100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${pet.name}가 아파요',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        _getIllnessName(pet.illness!),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Free treatment section
              Text(
                '무료 치료 (시간이 걸려요)',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 16),
              _buildTreatmentOption(
                icon: Icons.touch_app,
                title: '쓰다듬기 50번',
                subtitle: '정성껏 쓰다듬어주세요',
                color: Colors.pink,
                onTap: () => _startFreeTreatment('pet'),
              ),
              const SizedBox(height: 32),

              // Instant treatment section
              Text(
                '즉시 치료 (빠르게 완치)',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 16),
              _buildTreatmentOption(
                icon: Icons.favorite,
                title: '교감 포인트 50개',
                subtitle: '보유: ${currency?.affectionPoints ?? 0}개',
                color: Colors.purple,
                onTap: () => _instantTreatment('affection'),
                enabled: (currency?.affectionPoints ?? 0) >= 50,
              ),
              const SizedBox(height: 12),
              _buildTreatmentOption(
                icon: Icons.monetization_on,
                title: '코인 20개',
                subtitle: '보유: ${currency?.coins ?? 0}개',
                color: Colors.amber,
                onTap: () => _instantTreatment('coin'),
                enabled: (currency?.coins ?? 0) >= 20,
              ),
              const SizedBox(height: 12),
              _buildTreatmentOption(
                icon: Icons.play_circle,
                title: '광고 보기',
                subtitle: '광고 시청 후 즉시 치료',
                color: Colors.green,
                onTap: () => _instantTreatment('ad'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTreatmentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? color : Colors.grey,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: enabled ? color : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: enabled ? color : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: enabled ? Colors.grey[700] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: enabled ? color : Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _getIllnessName(String illness) {
    switch (illness) {
      case 'stomach_ache':
        return '배탈';
      case 'skin_disease':
        return '피부병';
      case 'weak_immunity':
        return '면역력 저하';
      default:
        return '아픔';
    }
  }
}
