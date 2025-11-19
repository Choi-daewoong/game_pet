import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'services/storage_service.dart';
// import 'services/notification_service.dart'; // Temporarily disabled
import 'services/ad_service.dart';
import 'services/widget_service.dart';
import 'providers/storage_provider.dart';
import 'app.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background task for updating widget periodically
    try {
      final storage = await StorageService.init();
      final pet = storage.loadPetState();
      final currency = storage.loadCurrency();

      if (pet != null && currency != null) {
        await WidgetService().updateWidget(pet, currency);
      }

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storage = await StorageService.init();

  // Initialize notification service (temporarily disabled)
  // await NotificationService().initialize();
  // await NotificationService().scheduleAllReminders();

  // Platform-specific initialization (not for web)
  if (!kIsWeb) {
    // Initialize ad service
    await AdService().initialize();
    await AdService().loadRewardedAd();

    // Initialize widget service
    await WidgetService().initialize();
    WidgetService.registerBackgroundCallback();

    // Initialize WorkManager for background widget updates
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register periodic task for widget updates (every 30 minutes)
    await Workmanager().registerPeriodicTask(
      'widget_update',
      'widgetUpdateTask',
      frequency: const Duration(minutes: 30),
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storage),
      ],
      child: const PetiteFriendsApp(),
    ),
  );
}
