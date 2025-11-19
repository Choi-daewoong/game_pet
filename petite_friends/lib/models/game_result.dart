class GameResult {
  final String gameType; // 'jump', 'shuffle', 'puzzle'
  final int score;
  final int coinsEarned;
  final bool isNewRecord;
  final bool isSuccess;
  final int distance; // 점프 게임용
  final int correctCount; // 야바위 게임용

  GameResult({
    required this.gameType,
    required this.score,
    required this.coinsEarned,
    this.isNewRecord = false,
    required this.isSuccess,
    this.distance = 0,
    this.correctCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType,
      'score': score,
      'coinsEarned': coinsEarned,
      'isNewRecord': isNewRecord,
      'isSuccess': isSuccess,
      'distance': distance,
      'correctCount': correctCount,
    };
  }

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      gameType: json['gameType'] as String,
      score: json['score'] as int,
      coinsEarned: json['coinsEarned'] as int,
      isNewRecord: json['isNewRecord'] as bool? ?? false,
      isSuccess: json['isSuccess'] as bool,
      distance: json['distance'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
    );
  }
}

class GameRecord {
  final String gameType;
  final int bestScore;
  final int totalPlays;
  final int totalWins;

  GameRecord({
    required this.gameType,
    this.bestScore = 0,
    this.totalPlays = 0,
    this.totalWins = 0,
  });

  GameRecord copyWith({
    String? gameType,
    int? bestScore,
    int? totalPlays,
    int? totalWins,
  }) {
    return GameRecord(
      gameType: gameType ?? this.gameType,
      bestScore: bestScore ?? this.bestScore,
      totalPlays: totalPlays ?? this.totalPlays,
      totalWins: totalWins ?? this.totalWins,
    );
  }

  double get winRate {
    if (totalPlays == 0) return 0.0;
    return totalWins / totalPlays;
  }

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType,
      'bestScore': bestScore,
      'totalPlays': totalPlays,
      'totalWins': totalWins,
    };
  }

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      gameType: json['gameType'] as String,
      bestScore: json['bestScore'] as int? ?? 0,
      totalPlays: json['totalPlays'] as int? ?? 0,
      totalWins: json['totalWins'] as int? ?? 0,
    );
  }
}
