import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Navigate to appropriate screen based on payload
  }

  // Schedule reminder notifications
  Future<void> scheduleHungerReminder() async {
    await _notifications.zonedSchedule(
      0,
      '배고파요! 🍎',
      '펫이 배가 고파요. 밥을 주세요!',
      _nextInstanceOfTime(12, 0), // 12:00 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hunger_channel',
          '배고픔 알림',
          channelDescription: '펫의 배고픔 상태를 알려드립니다',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleCleanlinessReminder() async {
    await _notifications.zonedSchedule(
      1,
      '청소가 필요해요! 🧹',
      '펫의 주변이 지저분해요. 청소해주세요!',
      _nextInstanceOfTime(18, 0), // 6:00 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cleanliness_channel',
          '청결도 알림',
          channelDescription: '펫의 청결도 상태를 알려드립니다',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleSleepReminder() async {
    await _notifications.zonedSchedule(
      2,
      '잘 시간이에요! 😴',
      '펫이 피곤해해요. 재워주세요!',
      _nextInstanceOfTime(21, 0), // 9:00 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sleep_channel',
          '수면 알림',
          channelDescription: '펫의 피로도를 알려드립니다',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleHeartRecoveryNotification() async {
    await _notifications.zonedSchedule(
      3,
      '하트가 회복됐어요! 💙',
      '게임을 즐길 시간이에요!',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 1)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'heart_channel',
          '하트 회복 알림',
          channelDescription: '하트 회복을 알려드립니다',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showIllnessNotification() async {
    await _notifications.show(
      4,
      '펫이 아파요! 🤒',
      '병원에서 치료가 필요해요!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'illness_channel',
          '질병 알림',
          channelDescription: '펫의 건강 상태를 알려드립니다',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showMoodLowNotification() async {
    await _notifications.show(
      5,
      '펫이 우울해해요 😢',
      '게임을 하거나 음식을 주세요!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mood_channel',
          '기분 알림',
          channelDescription: '펫의 기분을 알려드립니다',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showDailyCheckInReminder() async {
    await _notifications.zonedSchedule(
      6,
      '출석 체크! 📅',
      '오늘의 보상을 받으세요!',
      _nextInstanceOfTime(9, 0), // 9:00 AM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          '출석 알림',
          channelDescription: '매일 출석 체크를 알려드립니다',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Helper method to calculate next instance of time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Schedule all default notifications
  Future<void> scheduleAllReminders() async {
    await scheduleHungerReminder();
    await scheduleCleanlinessReminder();
    await scheduleSleepReminder();
    await showDailyCheckInReminder();
  }
}
