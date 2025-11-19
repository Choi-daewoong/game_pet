import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pet_provider.dart';
import '../../providers/currency_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('상점'),
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Currency display
              _buildCurrencyDisplay(currency),
              const SizedBox(height: 32),

              // Food section
              Text(
                '음식',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildShopItem(
                context: context,
                ref: ref,
                icon: '🍎',
                name: '사과',
                description: '배고픔 +20, 기분 +5',
                coinPrice: 5,
                currency: currency,
                onPurchase: () => _purchaseFood(context, ref, 'apple', 20, 5, 5),
              ),
              const SizedBox(height: 12),
              _buildShopItem(
                context: context,
                ref: ref,
                icon: '🍕',
                name: '피자',
                description: '배고픔 +40, 기분 +10',
                coinPrice: 10,
                currency: currency,
                onPurchase: () => _purchaseFood(context, ref, 'pizza', 40, 10, 10),
              ),
              const SizedBox(height: 12),
              _buildShopItem(
                context: context,
                ref: ref,
                icon: '🍰',
                name: '케이크',
                description: '배고픔 +60, 기분 +20',
                coinPrice: 20,
                currency: currency,
                onPurchase: () => _purchaseFood(context, ref, 'cake', 60, 20, 20),
              ),
              const SizedBox(height: 32),

              // Cleaning items section
              Text(
                '청소용품',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildShopItem(
                context: context,
                ref: ref,
                icon: '🧹',
                name: '빗자루',
                description: '청결도 +15, 기분 +5',
                coinPrice: 8,
                currency: currency,
                onPurchase: () => _purchaseCleaning(context, ref, 'broom', 15, 5, 8),
              ),
              const SizedBox(height: 12),
              _buildShopItem(
                context: context,
                ref: ref,
                icon: '🧼',
                name: '비누',
                description: '청결도 +25, 기분 +8',
                coinPrice: 12,
                currency: currency,
                onPurchase: () => _purchaseCleaning(context, ref, 'soap', 25, 8, 12),
              ),
              const SizedBox(height: 12),
              _buildShopItem(
                context: context,
                ref: ref,
                icon: '🛁',
                name: '욕조',
                description: '청결도 +50, 기분 +15',
                coinPrice: 25,
                currency: currency,
                onPurchase: () => _purchaseCleaning(context, ref, 'bath', 50, 15, 25),
              ),
              const SizedBox(height: 32),

              // Heart packages section
              Text(
                '하트 패키지',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildShopItem(
                context: context,
                ref: ref,
                icon: '💙',
                name: '하트 +5',
                description: '게임을 더 즐기세요',
                coinPrice: 10,
                currency: currency,
                onPurchase: () => _purchaseHearts(context, ref, 5, 10),
              ),
              const SizedBox(height: 12),
              _buildShopItem(
                context: context,
                ref: ref,
                icon: '💚',
                name: '하트 +10',
                description: '더 많은 게임 플레이!',
                coinPrice: 18,
                currency: currency,
                onPurchase: () => _purchaseHearts(context, ref, 10, 18),
              ),
              const SizedBox(height: 32),

              // Special items section
              Text(
                '특별 아이템',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildShopItem(
                context: context,
                ref: ref,
                icon: '💊',
                name: '영양제',
                description: '건강 +30, 면역력 강화',
                coinPrice: 15,
                currency: currency,
                onPurchase: () => _purchaseVitamin(context, ref, 15),
              ),
              const SizedBox(height: 12),
              _buildShopItem(
                context: context,
                ref: ref,
                icon: '🎁',
                name: '행운의 상자',
                description: '랜덤 보상 획득!',
                coinPrice: 30,
                currency: currency,
                onPurchase: () => _purchaseLuckyBox(context, ref, 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDisplay(Currency? currency) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.blue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCurrencyItem('💙', '하트', '${currency?.hearts ?? 0}'),
          _buildCurrencyItem('🪙', '코인', '${currency?.coins ?? 0}'),
          _buildCurrencyItem('💜', '교감', '${currency?.affectionPoints ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildShopItem({
    required BuildContext context,
    required WidgetRef ref,
    required String icon,
    required String name,
    required String description,
    required int coinPrice,
    required Currency? currency,
    required VoidCallback onPurchase,
  }) {
    final canAfford = (currency?.coins ?? 0) >= coinPrice;

    return InkWell(
      onTap: canAfford ? onPurchase : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: canAfford
              ? Colors.amber.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canAfford ? Colors.amber : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: canAfford ? Colors.grey[700] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 4),
                    Text(
                      '$coinPrice',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? Colors.amber[800] : Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (!canAfford)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '부족',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseFood(
    BuildContext context,
    WidgetRef ref,
    String type,
    int hungerIncrease,
    int moodIncrease,
    int cost,
  ) {
    if (!ref.read(currencyProvider.notifier).consumeCoins(cost)) {
      return;
    }

    final pet = ref.read(petProvider);
    if (pet != null) {
      final updatedPet = pet.copyWith(
        hunger: (pet.hunger + hungerIncrease).clamp(0, 100),
        mood: (pet.mood + moodIncrease).clamp(0, 100),
        lastUpdateTime: DateTime.now(),
      );
      ref.read(petProvider.notifier).state = updatedPet;
    }

    _showPurchaseSuccessDialog(context, '맛있게 먹었어요! 🍴');
  }

  void _purchaseCleaning(
    BuildContext context,
    WidgetRef ref,
    String type,
    int cleanlinessIncrease,
    int moodIncrease,
    int cost,
  ) {
    if (!ref.read(currencyProvider.notifier).consumeCoins(cost)) {
      return;
    }

    final pet = ref.read(petProvider);
    if (pet != null) {
      final updatedPet = pet.copyWith(
        cleanliness: (pet.cleanliness + cleanlinessIncrease).clamp(0, 100),
        mood: (pet.mood + moodIncrease).clamp(0, 100),
        lastUpdateTime: DateTime.now(),
      );
      ref.read(petProvider.notifier).state = updatedPet;
    }

    _showPurchaseSuccessDialog(context, '깨끗해졌어요! ✨');
  }

  void _purchaseHearts(BuildContext context, WidgetRef ref, int amount, int cost) {
    if (!ref.read(currencyProvider.notifier).consumeCoins(cost)) {
      return;
    }

    final currency = ref.read(currencyProvider);
    if (currency != null) {
      final newHearts = (currency.hearts + amount).clamp(0, 20);
      ref.read(currencyProvider.notifier).state = currency.copyWith(
        hearts: newHearts,
      );
    }

    _showPurchaseSuccessDialog(context, '하트를 충전했어요! 💙');
  }

  void _purchaseVitamin(BuildContext context, WidgetRef ref, int cost) {
    if (!ref.read(currencyProvider.notifier).consumeCoins(cost)) {
      return;
    }

    final pet = ref.read(petProvider);
    if (pet != null) {
      final updatedPet = pet.copyWith(
        health: (pet.health + 30).clamp(0, 100),
        mood: (pet.mood + 10).clamp(0, 100),
        lastUpdateTime: DateTime.now(),
      );
      ref.read(petProvider.notifier).state = updatedPet;
    }

    _showPurchaseSuccessDialog(context, '건강해졌어요! 💪');
  }

  void _purchaseLuckyBox(BuildContext context, WidgetRef ref, int cost) {
    if (!ref.read(currencyProvider.notifier).consumeCoins(cost)) {
      return;
    }

    // Random rewards
    final rewards = [
      ('코인 +50', () => ref.read(currencyProvider.notifier).addCoins(50)),
      ('교감 +30', () => ref.read(currencyProvider.notifier).addAffectionPoints(30)),
      ('하트 +5', () {
        final currency = ref.read(currencyProvider);
        if (currency != null) {
          final newHearts = (currency.hearts + 5).clamp(0, 20);
          ref.read(currencyProvider.notifier).state = currency.copyWith(
            hearts: newHearts,
          );
        }
      }),
      ('경험치 +50', () => ref.read(petProvider.notifier).addExperience(50)),
    ];

    final randomIndex = DateTime.now().millisecond % rewards.length;
    final (rewardText, rewardAction) = rewards[randomIndex];
    rewardAction();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎁 행운의 상자'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              rewardText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구매 완료'),
        content: Text(
          message,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
