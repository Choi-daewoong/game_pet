import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pet_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/widget_service.dart';
import '../games/jump_game_screen.dart';
import '../games/shuffle_game_screen.dart';
import '../hospital/hospital_screen.dart';
import '../shop/shop_screen.dart';
import '../../models/pet_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Update pet state on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petProvider.notifier).updateState();
      ref.read(currencyProvider.notifier).recoverHearts();
      _updateWidget();
    });
  }

  void _updateWidget() async {
    final pet = ref.read(petProvider);
    final currency = ref.read(currencyProvider);
    if (pet != null && currency != null) {
      await WidgetService().updateWidget(pet, currency);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    final currency = ref.watch(currencyProvider);

    if (pet == null || currency == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          _buildCurrencyDisplay(currency),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Pet Display Area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: _buildPetDisplay(pet),
                ),
              ),
            ),

            // Status Bars
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildStatusBars(pet),
            ),

            // Action Buttons
            Expanded(
              child: _buildActionButtons(pet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDisplay(dynamic currency) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.red, size: 20),
          const SizedBox(width: 4),
          Text(
            '${currency.hearts}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            '${currency.coins}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetDisplay(PetState pet) {
    final emoji = _getPetEmoji(pet.emotion);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 120),
        ),
        const SizedBox(height: 16),
        if (pet.illness != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_hospital, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  _getIllnessName(pet.illness!),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _getPetEmoji(PetEmotion emotion) {
    switch (emotion) {
      case PetEmotion.happy:
        return '😊';
      case PetEmotion.normal:
        return '😐';
      case PetEmotion.sad:
        return '😢';
      case PetEmotion.tired:
        return '😴';
      case PetEmotion.sick:
        return '🤒';
    }
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

  Widget _buildStatusBars(PetState pet) {
    return Column(
      children: [
        _buildStatusBar('배고픔', pet.hunger, Colors.orange),
        const SizedBox(height: 8),
        _buildStatusBar('청결도', pet.cleanliness, Colors.blue),
        const SizedBox(height: 8),
        _buildStatusBar('기분', pet.mood, Colors.pink),
        const SizedBox(height: 8),
        _buildStatusBar('피로도', 100 - pet.fatigue, Colors.purple),
      ],
    );
  }

  Widget _buildStatusBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 35,
          child: Text(
            '${value.toInt()}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(PetState pet) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildActionButton(
          icon: Icons.restaurant,
          label: '밥주기',
          color: Colors.orange,
          onTap: () {
            ref.read(petProvider.notifier).feed();
            _updateWidget();
            _showSnackBar('맛있게 먹었어요! 😊');
          },
        ),
        _buildActionButton(
          icon: Icons.cleaning_services,
          label: '청소',
          color: Colors.blue,
          onTap: () {
            ref.read(petProvider.notifier).clean();
            _updateWidget();
            _showSnackBar('깨끗해졌어요! ✨');
          },
        ),
        _buildActionButton(
          icon: Icons.bathtub,
          label: '씻기기',
          color: Colors.cyan,
          onTap: () {
            ref.read(petProvider.notifier).wash();
            _updateWidget();
            _showSnackBar('상쾌해요! 🛁');
          },
        ),
        _buildActionButton(
          icon: Icons.bedtime,
          label: '재우기',
          color: Colors.purple,
          onTap: () {
            if (pet.isSleeping) {
              ref.read(petProvider.notifier).wakeUp();
              _updateWidget();
              _showSnackBar('일어났어요! ☀️');
            } else {
              ref.read(petProvider.notifier).sleep();
              _updateWidget();
              _showSnackBar('잘 자요! 💤');
            }
          },
        ),
        _buildActionButton(
          icon: Icons.games,
          label: '게임',
          color: Colors.green,
          onTap: () {
            _showGameMenu();
          },
        ),
        _buildActionButton(
          icon: Icons.shopping_bag,
          label: '상점',
          color: Colors.amber,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ShopScreen(),
              ),
            ).then((_) => _updateWidget());
          },
        ),
        if (pet.illness != null)
          _buildActionButton(
            icon: Icons.local_hospital,
            label: '병원',
            color: Colors.red,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HospitalScreen(),
                ),
              ).then((_) => _updateWidget());
            },
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGameMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.directions_run, color: Colors.green),
                title: const Text('점프 산책'),
                subtitle: const Text('장애물을 피해 멀리 달려보세요'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const JumpGameScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.orange),
                title: const Text('먹이 찾기'),
                subtitle: const Text('컵 속의 간식을 찾아보세요'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ShuffleGameScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
