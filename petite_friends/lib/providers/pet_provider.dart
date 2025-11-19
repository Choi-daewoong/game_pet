import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_state.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

final petProvider = StateNotifierProvider<PetNotifier, PetState?>((ref) {
  final storage = ref.watch(storageProvider);
  return PetNotifier(storage);
});

class PetNotifier extends StateNotifier<PetState?> {
  final StorageService _storage;

  PetNotifier(this._storage) : super(null) {
    _loadPetState();
  }

  void _loadPetState() {
    final pet = _storage.loadPetState();
    if (pet != null) {
      // Lazy Evaluation: 마지막 업데이트 이후 시간 경과 계산
      final now = DateTime.now();
      final timeDiff = now.difference(pet.lastUpdateTime);
      final updatedPet = pet.updateWithTimeDiff(timeDiff);
      state = updatedPet;
      _savePetState();
    }
  }

  void createPet(String name) {
    state = PetState(
      name: name,
      lastUpdateTime: DateTime.now(),
    );
    _savePetState();
  }

  void feed() {
    if (state == null) return;

    state = state!.copyWith(
      hunger: (state!.hunger + 20).clamp(0, 100),
      mood: (state!.mood + 5).clamp(0, 100),
      lastUpdateTime: DateTime.now(),
    );
    _savePetState();
  }

  void clean() {
    if (state == null) return;

    state = state!.copyWith(
      cleanliness: (state!.cleanliness + 10).clamp(0, 100),
      mood: (state!.mood + 5).clamp(0, 100),
      lastUpdateTime: DateTime.now(),
    );
    _savePetState();
  }

  void wash() {
    if (state == null) return;

    state = state!.copyWith(
      cleanliness: (state!.cleanliness + 30).clamp(0, 100),
      mood: (state!.mood + 10).clamp(0, 100),
      lastUpdateTime: DateTime.now(),
    );
    _savePetState();
  }

  void sleep() {
    if (state == null) return;

    state = state!.copyWith(
      fatigue: (state!.fatigue - 30).clamp(0, 100),
      mood: (state!.mood + 5).clamp(0, 100),
      isSleeping: true,
      sleepStartTime: DateTime.now(),
      lastUpdateTime: DateTime.now(),
    );
    _savePetState();
  }

  void wakeUp() {
    if (state == null) return;

    state = state!.copyWith(
      isSleeping: false,
      sleepStartTime: null,
      lastUpdateTime: DateTime.now(),
    );
    _savePetState();
  }

  void playGame(int moodIncrease) {
    if (state == null) return;

    state = state!.copyWith(
      mood: (state!.mood + moodIncrease).clamp(0, 100),
      lastUpdateTime: DateTime.now(),
    );
    _savePetState();
  }

  void cure(String treatmentType) {
    if (state == null || state!.illness == null) return;

    state = state!.copyWith(
      illness: null,
      health: 100,
      lastUpdateTime: DateTime.now(),
    );
    _savePetState();
  }

  void addExperience(int exp) {
    if (state == null) return;

    final newExp = state!.experience + exp;
    final newLevel = state!.level + (newExp ~/ 100);
    final remainingExp = newExp % 100;

    state = state!.copyWith(
      experience: remainingExp,
      level: newLevel,
      lastUpdateTime: DateTime.now(),
    );
    _savePetState();
  }

  void updateState() {
    if (state == null) return;

    final now = DateTime.now();
    final timeDiff = now.difference(state!.lastUpdateTime);
    state = state!.updateWithTimeDiff(timeDiff);
    _savePetState();
  }

  void _savePetState() {
    if (state != null) {
      _storage.savePetState(state!);
    }
  }
}
