import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_state.dart';
import '../models/currency.dart';
import '../models/game_result.dart';

class StorageService {
  static const String _keyPetState = 'pet_state';
  static const String _keyCurrency = 'currency';
  static const String _keySleepModeStart = 'sleep_mode_start';
  static const String _keySleepModeEnd = 'sleep_mode_end';
  static const String _keyIsFirstRun = 'is_first_run';
  static const String _keyPetName = 'pet_name';
  static const String _keySettings = 'settings';
  static const String _keyGameRecords = 'game_records';
  static const String _keyDailyCheck = 'daily_check';
  static const String _keyPurchases = 'purchases';
  static const String _keyInstallDate = 'install_date';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Pet State
  Future<void> savePetState(PetState state) async {
    final json = jsonEncode(state.toJson());
    await _prefs.setString(_keyPetState, json);
  }

  PetState? loadPetState() {
    final json = _prefs.getString(_keyPetState);
    if (json == null) return null;
    return PetState.fromJson(jsonDecode(json));
  }

  // Currency
  Future<void> saveCurrency(Currency currency) async {
    final json = jsonEncode(currency.toJson());
    await _prefs.setString(_keyCurrency, json);
  }

  Currency? loadCurrency() {
    final json = _prefs.getString(_keyCurrency);
    if (json == null) return null;
    return Currency.fromJson(jsonDecode(json));
  }

  // Sleep Mode
  Future<void> setSleepModeTime(int startHour, int endHour) async {
    await _prefs.setInt(_keySleepModeStart, startHour);
    await _prefs.setInt(_keySleepModeEnd, endHour);
  }

  (int start, int end) getSleepModeTime() {
    final start = _prefs.getInt(_keySleepModeStart) ?? 22; // 기본 22시
    final end = _prefs.getInt(_keySleepModeEnd) ?? 7; // 기본 7시
    return (start, end);
  }

  bool isSleepTime() {
    final (start, end) = getSleepModeTime();
    final now = DateTime.now();
    final currentHour = now.hour;

    if (start < end) {
      // 예: 22시 ~ 다음날 7시
      return currentHour >= start || currentHour < end;
    } else {
      // 정상적인 경우는 위와 같음
      return currentHour >= start && currentHour < end;
    }
  }

  // First Run
  Future<void> setFirstRunComplete() async {
    await _prefs.setBool(_keyIsFirstRun, false);
  }

  bool isFirstRun() {
    return _prefs.getBool(_keyIsFirstRun) ?? true;
  }

  // Pet Name
  Future<void> savePetName(String name) async {
    await _prefs.setString(_keyPetName, name);
  }

  String? getPetName() {
    return _prefs.getString(_keyPetName);
  }

  // Game Records
  Future<void> saveGameRecord(GameRecord record) async {
    final records = loadGameRecords();
    records[record.gameType] = record;

    final json = jsonEncode(
      records.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _prefs.setString(_keyGameRecords, json);
  }

  Map<String, GameRecord> loadGameRecords() {
    final json = _prefs.getString(_keyGameRecords);
    if (json == null) return {};

    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map(
      (key, value) => MapEntry(
        key,
        GameRecord.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  // Daily Check
  Future<void> markDailyCheck() async {
    await _prefs.setString(_keyDailyCheck, DateTime.now().toIso8601String());
  }

  bool hasCheckedToday() {
    final lastCheck = _prefs.getString(_keyDailyCheck);
    if (lastCheck == null) return false;

    final lastCheckDate = DateTime.parse(lastCheck);
    final now = DateTime.now();

    return lastCheckDate.year == now.year &&
        lastCheckDate.month == now.month &&
        lastCheckDate.day == now.day;
  }

  // Settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final json = jsonEncode(settings);
    await _prefs.setString(_keySettings, json);
  }

  Map<String, dynamic> loadSettings() {
    final json = _prefs.getString(_keySettings);
    if (json == null) {
      return {
        'notifications_enabled': true,
        'sound_enabled': true,
        'vibration_enabled': true,
      };
    }
    return jsonDecode(json) as Map<String, dynamic>;
  }

  // Install Date
  DateTime getInstallDate() {
    final dateStr = _prefs.getString(_keyInstallDate);
    if (dateStr == null) {
      final now = DateTime.now();
      _prefs.setString(_keyInstallDate, now.toIso8601String());
      return now;
    }
    return DateTime.parse(dateStr);
  }

  // Clear all data (for testing)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
