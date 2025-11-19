import 'package:hive/hive.dart';

part 'pet_state.g.dart';

@HiveType(typeId: 0)
class PetState {
  @HiveField(0)
  String name;

  @HiveField(1)
  double hunger; // 0-100

  @HiveField(2)
  double cleanliness; // 0-100

  @HiveField(3)
  double mood; // 0-100

  @HiveField(4)
  double fatigue; // 0-100

  @HiveField(5)
  double health; // 0-100

  @HiveField(6)
  DateTime lastUpdateTime;

  @HiveField(7)
  bool isSleeping;

  @HiveField(8)
  DateTime? sleepStartTime;

  @HiveField(9)
  String? illness; // null or 'stomach_ache', 'skin_disease', 'weak_immunity'

  @HiveField(10)
  int level;

  @HiveField(11)
  int experience;

  PetState({
    required this.name,
    this.hunger = 100.0,
    this.cleanliness = 100.0,
    this.mood = 100.0,
    this.fatigue = 0.0,
    this.health = 100.0,
    required this.lastUpdateTime,
    this.isSleeping = false,
    this.sleepStartTime,
    this.illness,
    this.level = 1,
    this.experience = 0,
  });

  PetState copyWith({
    String? name,
    double? hunger,
    double? cleanliness,
    double? mood,
    double? fatigue,
    double? health,
    DateTime? lastUpdateTime,
    bool? isSleeping,
    DateTime? sleepStartTime,
    String? illness,
    int? level,
    int? experience,
  }) {
    return PetState(
      name: name ?? this.name,
      hunger: hunger ?? this.hunger,
      cleanliness: cleanliness ?? this.cleanliness,
      mood: mood ?? this.mood,
      fatigue: fatigue ?? this.fatigue,
      health: health ?? this.health,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      isSleeping: isSleeping ?? this.isSleeping,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      illness: illness ?? this.illness,
      level: level ?? this.level,
      experience: experience ?? this.experience,
    );
  }

  // 현재 표정 상태 결정
  PetEmotion get emotion {
    if (illness != null) return PetEmotion.sick;
    if (fatigue > 70) return PetEmotion.tired;
    if (hunger < 30) return PetEmotion.sad;
    if (mood > 70 && hunger > 60) return PetEmotion.happy;
    return PetEmotion.normal;
  }

  // 상태가 위험한지 체크
  bool get isInDanger {
    return hunger < 20 || cleanliness < 30 || fatigue > 80;
  }

  // 상태 업데이트 (Lazy Evaluation)
  PetState updateWithTimeDiff(Duration timeDiff) {
    // 수면 모드 시간 계산
    final activeHours = _calculateActiveHours(timeDiff);

    double newHunger = hunger - (5 * activeHours);
    double newCleanliness = cleanliness - (2 * activeHours);
    double newFatigue = isSleeping
        ? (fatigue - 5 * (timeDiff.inMinutes / 60))
        : (fatigue + 3 * activeHours);

    // 수면 중이면 피로도만 회복
    if (isSleeping) {
      newFatigue = (newFatigue < 0) ? 0 : newFatigue;
    }

    // 값 범위 제한
    newHunger = newHunger.clamp(0, 100);
    newCleanliness = newCleanliness.clamp(0, 100);
    newFatigue = newFatigue.clamp(0, 100);

    // 질병 발생 확률 계산
    String? newIllness = illness;
    if (newIllness == null) {
      if (newHunger < 20 && _randomChance(0.2)) {
        newIllness = 'stomach_ache';
      } else if (newCleanliness < 30 && _randomChance(0.3)) {
        newIllness = 'skin_disease';
      } else if (newFatigue > 80 && _randomChance(0.15)) {
        newIllness = 'weak_immunity';
      }
    }

    double newHealth = health;
    if (newIllness != null && health > 30) {
      newHealth -= 10;
    }

    return copyWith(
      hunger: newHunger,
      cleanliness: newCleanliness,
      fatigue: newFatigue,
      health: newHealth.clamp(0, 100),
      lastUpdateTime: DateTime.now(),
      illness: newIllness,
    );
  }

  // 수면 모드 시간 제외 계산
  double _calculateActiveHours(Duration timeDiff) {
    final totalHours = timeDiff.inMinutes / 60;

    // 간단한 구현: 밤 10시~아침 7시는 수면 시간으로 간주
    // 실제로는 더 정교한 로직 필요
    if (isSleeping) {
      return totalHours * 0.1; // 수면 중에는 1/10 속도
    }
    return totalHours;
  }

  bool _randomChance(double probability) {
    return DateTime.now().millisecond / 1000 < probability;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hunger': hunger,
      'cleanliness': cleanliness,
      'mood': mood,
      'fatigue': fatigue,
      'health': health,
      'lastUpdateTime': lastUpdateTime.toIso8601String(),
      'isSleeping': isSleeping,
      'sleepStartTime': sleepStartTime?.toIso8601String(),
      'illness': illness,
      'level': level,
      'experience': experience,
    };
  }

  factory PetState.fromJson(Map<String, dynamic> json) {
    return PetState(
      name: json['name'] as String,
      hunger: (json['hunger'] as num).toDouble(),
      cleanliness: (json['cleanliness'] as num).toDouble(),
      mood: (json['mood'] as num).toDouble(),
      fatigue: (json['fatigue'] as num).toDouble(),
      health: (json['health'] as num).toDouble(),
      lastUpdateTime: DateTime.parse(json['lastUpdateTime'] as String),
      isSleeping: json['isSleeping'] as bool? ?? false,
      sleepStartTime: json['sleepStartTime'] != null
          ? DateTime.parse(json['sleepStartTime'] as String)
          : null,
      illness: json['illness'] as String?,
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
    );
  }
}

enum PetEmotion {
  happy,
  normal,
  sad,
  tired,
  sick,
}
