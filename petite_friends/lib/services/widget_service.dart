import 'package:home_widget/home_widget.dart';
import '../models/pet_state.dart';
import '../models/currency.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  static const String _widgetName = 'PetiteWidgetProvider';
  static const String _iOSWidgetName = 'PetiteWidget';

  // Update widget with pet state
  Future<void> updateWidget(PetState? pet, Currency? currency) async {
    if (pet == null || currency == null) return;

    try {
      // Save data to widget
      await HomeWidget.saveWidgetData<String>('pet_name', pet.name);
      await HomeWidget.saveWidgetData<int>(
        'pet_hunger',
        pet.hunger.round(),
      );
      await HomeWidget.saveWidgetData<int>(
        'pet_mood',
        pet.mood.round(),
      );
      await HomeWidget.saveWidgetData<int>(
        'pet_health',
        pet.health.round(),
      );
      await HomeWidget.saveWidgetData<int>(
        'pet_cleanliness',
        pet.cleanliness.round(),
      );
      await HomeWidget.saveWidgetData<int>(
        'pet_level',
        pet.level,
      );
      await HomeWidget.saveWidgetData<bool>(
        'pet_is_sleeping',
        pet.isSleeping,
      );
      await HomeWidget.saveWidgetData<bool>(
        'pet_is_sick',
        pet.illness != null,
      );
      await HomeWidget.saveWidgetData<int>(
        'currency_hearts',
        currency.hearts,
      );
      await HomeWidget.saveWidgetData<int>(
        'currency_coins',
        currency.coins,
      );
      await HomeWidget.saveWidgetData<String>(
        'pet_emoji',
        _getPetEmoji(pet),
      );

      // Update the widget
      await HomeWidget.updateWidget(
        androidName: _widgetName,
        iOSName: _iOSWidgetName,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  // Get appropriate emoji based on pet state
  String _getPetEmoji(PetState pet) {
    if (pet.illness != null) {
      return '🤒';
    } else if (pet.isSleeping) {
      return '😴';
    } else if (pet.mood < 30) {
      return '😢';
    } else if (pet.hunger < 30) {
      return '😋';
    } else if (pet.cleanliness < 30) {
      return '🙁';
    } else if (pet.mood > 80) {
      return '😊';
    } else {
      return '🐱';
    }
  }

  // Register widget background callback
  static void registerBackgroundCallback() {
    HomeWidget.registerBackgroundCallback(_backgroundCallback);
  }

  // Background callback for widget interactions
  @pragma('vm:entry-point')
  static Future<void> _backgroundCallback(Uri? uri) async {
    if (uri == null) return;

    // Handle widget button clicks
    final action = uri.host;

    // These actions will be handled by the native widget code
    // which will communicate with WorkManager to update pet state
    switch (action) {
      case 'feed':
        // Native code will handle this through WorkManager
        break;
      case 'clean':
        // Native code will handle this through WorkManager
        break;
      case 'play':
        // Native code will handle this through WorkManager
        break;
      case 'open_app':
        // Native code will open the app
        break;
    }
  }

  // Initialize widget
  Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId('group.petite.friends');
    } catch (e) {
      // Handle error silently
    }
  }

  // Get widget data (for testing)
  Future<Map<String, dynamic>> getWidgetData() async {
    try {
      final petName = await HomeWidget.getWidgetData<String>('pet_name');
      final petHunger = await HomeWidget.getWidgetData<int>('pet_hunger');
      final petMood = await HomeWidget.getWidgetData<int>('pet_mood');
      final petHealth = await HomeWidget.getWidgetData<int>('pet_health');
      final hearts = await HomeWidget.getWidgetData<int>('currency_hearts');
      final coins = await HomeWidget.getWidgetData<int>('currency_coins');

      return {
        'pet_name': petName,
        'pet_hunger': petHunger,
        'pet_mood': petMood,
        'pet_health': petHealth,
        'currency_hearts': hearts,
        'currency_coins': coins,
      };
    } catch (e) {
      return {};
    }
  }
}
