class MatchupStat {
  final String characterId;
  final int totalMatches;
  final int wins;
  final int losses;
  final double winRate;
  final List<bool> recentForm; // true = win, false = loss

  MatchupStat({
    required this.characterId,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.winRate,
    this.recentForm = const [],
  });

  Map<String, dynamic> toJson() => {
    'characterId': characterId,
    'totalMatches': totalMatches,
    'wins': wins,
    'losses': losses,
    'winRate': winRate,
    'recentForm': recentForm,
  };

  factory MatchupStat.fromJson(Map<String, dynamic> json) => MatchupStat(
    characterId: json['characterId'] ?? '',
    totalMatches: json['totalMatches'] ?? 0,
    wins: json['wins'] ?? 0,
    losses: json['losses'] ?? 0,
    winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
    recentForm: (json['recentForm'] as List<dynamic>?)?.map((e) => e as bool).toList() ?? [],
  );
}
