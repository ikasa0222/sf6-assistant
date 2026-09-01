class UserProfile {
  final String shortId;
  final String fighterId;
  final String avatarUrl;
  final String title;
  final String clubName;
  final String platform;
  final int lp;
  final int mr;
  final int? globalRank;
  final String mainCharacterId;
  final int totalMatches;
  final int totalWins;
  final double winRate;
  final int currentStreak;
  final int maxStreak;
  final List<CharacterUsage> characterUsages;
  final RadarStats radarStats;
  final DateTime updatedAt;

  UserProfile({
    required this.shortId,
    required this.fighterId,
    this.avatarUrl = '',
    this.title = '',
    this.clubName = '',
    required this.platform,
    required this.lp,
    this.mr = 0,
    this.globalRank,
    required this.mainCharacterId,
    this.totalMatches = 0,
    this.totalWins = 0,
    this.winRate = 0.0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.characterUsages = const [],
    required this.radarStats,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'shortId': shortId,
    'fighterId': fighterId,
    'avatarUrl': avatarUrl,
    'title': title,
    'clubName': clubName,
    'platform': platform,
    'lp': lp,
    'mr': mr,
    'globalRank': globalRank,
    'mainCharacterId': mainCharacterId,
    'totalMatches': totalMatches,
    'totalWins': totalWins,
    'winRate': winRate,
    'currentStreak': currentStreak,
    'maxStreak': maxStreak,
    'characterUsages': characterUsages.map((c) => c.toJson()).toList(),
    'radarStats': radarStats.toJson(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    shortId: json['shortId'] ?? '',
    fighterId: json['fighterId'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    title: json['title'] ?? '',
    clubName: json['clubName'] ?? '',
    platform: json['platform'] ?? 'steam',
    lp: json['lp'] ?? 0,
    mr: json['mr'] ?? 0,
    globalRank: json['globalRank'],
    mainCharacterId: json['mainCharacterId'] ?? 'luke',
    totalMatches: json['totalMatches'] ?? 0,
    totalWins: json['totalWins'] ?? 0,
    winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
    currentStreak: json['currentStreak'] ?? 0,
    maxStreak: json['maxStreak'] ?? 0,
    characterUsages: (json['characterUsages'] as List<dynamic>?)
            ?.map((e) => CharacterUsage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    radarStats: json['radarStats'] != null
        ? RadarStats.fromJson(json['radarStats'] as Map<String, dynamic>)
        : RadarStats.defaultStats(),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
  );
}

class CharacterUsage {
  final String characterId;
  final int matches;
  final int wins;
  final double winRate;
  final int lp;
  final int mr;

  CharacterUsage({
    required this.characterId,
    required this.matches,
    required this.wins,
    required this.winRate,
    this.lp = 0,
    this.mr = 0,
  });

  Map<String, dynamic> toJson() => {
    'characterId': characterId,
    'matches': matches,
    'wins': wins,
    'winRate': winRate,
    'lp': lp,
    'mr': mr,
  };

  factory CharacterUsage.fromJson(Map<String, dynamic> json) => CharacterUsage(
    characterId: json['characterId'] ?? '',
    matches: json['matches'] ?? 0,
    wins: json['wins'] ?? 0,
    winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
    lp: json['lp'] ?? 0,
    mr: json['mr'] ?? 0,
  );
}

class RadarStats {
  final double offense;      // 进攻性
  final double defense;      // 防守/确反
  final double technique;    // 技巧/连段
  final double driveGauge;   // 斗气槽利用率
  final double antiAir;      // 对空能力

  const RadarStats({
    required this.offense,
    required this.defense,
    required this.technique,
    required this.driveGauge,
    required this.antiAir,
  });

  factory RadarStats.defaultStats() => const RadarStats(
    offense: 75.0,
    defense: 70.0,
    technique: 80.0,
    driveGauge: 65.0,
    antiAir: 78.0,
  );

  Map<String, dynamic> toJson() => {
    'offense': offense,
    'defense': defense,
    'technique': technique,
    'driveGauge': driveGauge,
    'antiAir': antiAir,
  };

  factory RadarStats.fromJson(Map<String, dynamic> json) => RadarStats(
    offense: (json['offense'] as num?)?.toDouble() ?? 70.0,
    defense: (json['defense'] as num?)?.toDouble() ?? 70.0,
    technique: (json['technique'] as num?)?.toDouble() ?? 70.0,
    driveGauge: (json['driveGauge'] as num?)?.toDouble() ?? 70.0,
    antiAir: (json['antiAir'] as num?)?.toDouble() ?? 70.0,
  );
}
