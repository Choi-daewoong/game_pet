import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/currency.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, Currency?>((ref) {
  final storage = ref.watch(storageProvider);
  return CurrencyNotifier(storage);
});

class CurrencyNotifier extends StateNotifier<Currency?> {
  final StorageService _storage;

  CurrencyNotifier(this._storage) : super(null) {
    _loadCurrency();
  }

  void _loadCurrency() {
    var currency = _storage.loadCurrency();
    if (currency == null) {
      // 첫 실행 시 기본 Currency 생성
      currency = Currency(
        installDate: _storage.getInstallDate(),
      );
    } else {
      // 하트 자동 회복 적용
      currency = currency.recoverHearts();
    }
    state = currency;
    _saveCurrency();
  }

  void recoverHearts() {
    if (state == null) return;
    state = state!.recoverHearts();
    _saveCurrency();
  }

  bool consumeHeart() {
    if (state == null || state!.hearts <= 0) return false;
    state = state!.consumeHeart();
    _saveCurrency();
    return true;
  }

  void addHeartFromAd() {
    if (state == null) return;
    state = state!.addHeartFromAd();
    _saveCurrency();
  }

  void addCoins(int amount) {
    if (state == null) return;
    state = state!.addCoins(amount);
    _saveCurrency();
  }

  bool consumeCoins(int amount) {
    if (state == null || state!.coins < amount) return false;
    state = state!.consumeCoins(amount);
    _saveCurrency();
    return true;
  }

  void addAffectionPoints(int amount) {
    if (state == null) return;
    state = state!.addAffectionPoints(amount);
    _saveCurrency();
  }

  bool consumeAffectionPoints(int amount) {
    if (state == null || state!.affectionPoints < amount) return false;
    state = state!.consumeAffectionPoints(amount);
    _saveCurrency();
    return true;
  }

  bool requestFriendHeart() {
    if (state == null || !state!.canRequestFriendHeart()) return false;
    state = state!.requestFriendHeart();
    _saveCurrency();
    return true;
  }

  void _saveCurrency() {
    if (state != null) {
      _storage.saveCurrency(state!);
    }
  }
}
