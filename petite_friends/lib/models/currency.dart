import 'package:hive/hive.dart';

part 'currency.g.dart';

@HiveType(typeId: 1)
class Currency {
  @HiveField(0)
  int hearts; // 게임 기회

  @HiveField(1)
  int coins; // 아이템 구매용

  @HiveField(2)
  int affectionPoints; // 교감 포인트

  @HiveField(3)
  DateTime lastHeartRecoveryTime;

  @HiveField(4)
  DateTime installDate;

  @HiveField(5)
  int friendHeartRequestsToday;

  @HiveField(6)
  DateTime lastFriendRequestDate;

  Currency({
    this.hearts = 20,
    this.coins = 0,
    this.affectionPoints = 0,
    DateTime? lastHeartRecoveryTime,
    DateTime? installDate,
    this.friendHeartRequestsToday = 0,
    DateTime? lastFriendRequestDate,
  })  : lastHeartRecoveryTime = lastHeartRecoveryTime ?? DateTime.now(),
        installDate = installDate ?? DateTime.now(),
        lastFriendRequestDate = lastFriendRequestDate ?? DateTime.now();

  Currency copyWith({
    int? hearts,
    int? coins,
    int? affectionPoints,
    DateTime? lastHeartRecoveryTime,
    DateTime? installDate,
    int? friendHeartRequestsToday,
    DateTime? lastFriendRequestDate,
  }) {
    return Currency(
      hearts: hearts ?? this.hearts,
      coins: coins ?? this.coins,
      affectionPoints: affectionPoints ?? this.affectionPoints,
      lastHeartRecoveryTime:
          lastHeartRecoveryTime ?? this.lastHeartRecoveryTime,
      installDate: installDate ?? this.installDate,
      friendHeartRequestsToday:
          friendHeartRequestsToday ?? this.friendHeartRequestsToday,
      lastFriendRequestDate:
          lastFriendRequestDate ?? this.lastFriendRequestDate,
    );
  }

  // 신규 유저인지 체크 (설치 후 3일 이내)
  bool get isNewUser {
    final daysSinceInstall = DateTime.now().difference(installDate).inDays;
    return daysSinceInstall < 3;
  }

  // 하트 회복 속도 (분 단위)
  int get heartRecoveryMinutes {
    if (isNewUser) return 30; // 신규 유저: 30분
    return 60; // 일반 유저: 1시간
  }

  // 최대 하트 개수
  int get maxHearts => 20;

  // 하트 자동 회복
  Currency recoverHearts() {
    final now = DateTime.now();
    final minutesPassed =
        now.difference(lastHeartRecoveryTime).inMinutes;

    if (minutesPassed >= heartRecoveryMinutes && hearts < maxHearts) {
      final heartsToAdd = minutesPassed ~/ heartRecoveryMinutes;
      final newHearts = (hearts + heartsToAdd).clamp(0, maxHearts);

      return copyWith(
        hearts: newHearts,
        lastHeartRecoveryTime: now,
      );
    }

    return this;
  }

  // 하트 소모
  Currency consumeHeart() {
    if (hearts > 0) {
      return copyWith(hearts: hearts - 1);
    }
    return this;
  }

  // 코인 추가
  Currency addCoins(int amount) {
    return copyWith(coins: coins + amount);
  }

  // 코인 소모
  Currency consumeCoins(int amount) {
    if (coins >= amount) {
      return copyWith(coins: coins - amount);
    }
    return this;
  }

  // 교감 포인트 추가
  Currency addAffectionPoints(int amount) {
    return copyWith(affectionPoints: affectionPoints + amount);
  }

  // 교감 포인트 소모
  Currency consumeAffectionPoints(int amount) {
    if (affectionPoints >= amount) {
      return copyWith(affectionPoints: affectionPoints - amount);
    }
    return this;
  }

  // 친구 하트 요청 가능 여부
  bool canRequestFriendHeart() {
    final now = DateTime.now();

    // 날짜가 바뀌면 카운트 리셋
    if (now.day != lastFriendRequestDate.day) {
      return true;
    }

    return friendHeartRequestsToday < 5;
  }

  // 친구 하트 요청
  Currency requestFriendHeart() {
    final now = DateTime.now();

    // 날짜가 바뀌면 카운트 리셋
    int newCount = (now.day != lastFriendRequestDate.day)
        ? 1
        : friendHeartRequestsToday + 1;

    return copyWith(
      friendHeartRequestsToday: newCount,
      lastFriendRequestDate: now,
    );
  }

  // 광고 시청으로 하트 획득
  Currency addHeartFromAd() {
    final newHearts = (hearts + 1).clamp(0, maxHearts);
    return copyWith(hearts: newHearts);
  }

  Map<String, dynamic> toJson() {
    return {
      'hearts': hearts,
      'coins': coins,
      'affectionPoints': affectionPoints,
      'lastHeartRecoveryTime': lastHeartRecoveryTime.toIso8601String(),
      'installDate': installDate.toIso8601String(),
      'friendHeartRequestsToday': friendHeartRequestsToday,
      'lastFriendRequestDate': lastFriendRequestDate.toIso8601String(),
    };
  }

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      hearts: json['hearts'] as int? ?? 20,
      coins: json['coins'] as int? ?? 0,
      affectionPoints: json['affectionPoints'] as int? ?? 0,
      lastHeartRecoveryTime:
          DateTime.parse(json['lastHeartRecoveryTime'] as String),
      installDate: DateTime.parse(json['installDate'] as String),
      friendHeartRequestsToday: json['friendHeartRequestsToday'] as int? ?? 0,
      lastFriendRequestDate:
          DateTime.parse(json['lastFriendRequestDate'] as String),
    );
  }
}
