enum BattleType {
  ranked,
  casual,
  customRoom,
  battleHub;

  String get code {
    switch (this) {
      case BattleType.ranked:
        return 'ranked';
      case BattleType.casual:
        return 'casual';
      case BattleType.customRoom:
        return 'customRoom';
      case BattleType.battleHub:
        return 'battleHub';
    }
  }

  String get displayName {
    switch (this) {
      case BattleType.ranked:
        return '排位赛 (Ranked)';
      case BattleType.casual:
        return '休闲赛 (Casual)';
      case BattleType.customRoom:
        return '自定义房间 (Custom)';
      case BattleType.battleHub:
        return '格斗中心 (Battle Hub)';
    }
  }

  static BattleType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'ranked':
      case 'rank':
        return BattleType.ranked;
      case 'casual':
        return BattleType.casual;
      case 'custom':
      case 'room':
        return BattleType.customRoom;
      case 'hub':
      case 'battlehub':
        return BattleType.battleHub;
      default:
        return BattleType.ranked;
    }
  }
}

enum RoundFinishType {
  ko,
  perfect,
  sa1,
  sa2,
  ca,
  timeOut,
  doubleKo;

  String get displayName {
    switch (this) {
      case RoundFinishType.ko:
        return 'K.O.';
      case RoundFinishType.perfect:
        return 'PERFECT';
      case RoundFinishType.sa1:
        return 'S.A.1';
      case RoundFinishType.sa2:
        return 'S.A.2';
      case RoundFinishType.ca:
        return 'C.A. (超必杀)';
      case RoundFinishType.timeOut:
        return 'TIME OUT';
      case RoundFinishType.doubleKo:
        return 'DOUBLE K.O.';
    }
  }

  static RoundFinishType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'PERFECT':
      case 'P':
        return RoundFinishType.perfect;
      case 'SA1':
        return RoundFinishType.sa1;
      case 'SA2':
        return RoundFinishType.sa2;
      case 'CA':
      case 'SA3':
        return RoundFinishType.ca;
      case 'TIME':
      case 'TIMEOUT':
        return RoundFinishType.timeOut;
      case 'DOUBLEKO':
        return RoundFinishType.doubleKo;
      default:
        return RoundFinishType.ko;
    }
  }
}

class RoundDetail {
  final int roundNum;
  final bool isPlayerWin;
  final RoundFinishType finishType;
  final int durationSeconds;

  RoundDetail({
    required this.roundNum,
    required this.isPlayerWin,
    required this.finishType,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toJson() => {
    'roundNum': roundNum,
    'isPlayerWin': isPlayerWin ? 1 : 0,
    'finishType': finishType.name,
    'durationSeconds': durationSeconds,
  };

  factory RoundDetail.fromJson(Map<String, dynamic> json) => RoundDetail(
    roundNum: json['roundNum'] ?? 1,
    isPlayerWin: json['isPlayerWin'] == 1 || json['isPlayerWin'] == true,
    finishType: RoundFinishType.fromString(json['finishType'] ?? 'ko'),
    durationSeconds: json['durationSeconds'] ?? 0,
  );
}

class BattleRecord {
  final String id; // Replay ID or unique generated hash
  final String shortId; // User who owns this record
  final String platform;
  final DateTime playedAt;
  final BattleType battleType;
  final String playerCharacterId;
  final int playerScore;
  final int playerLpChange;
  final int playerMrChange;
  final int? playerCurrentLp;
  final int? playerCurrentMr;
  final String playerControlType; // 'M' or 'C'

  final String opponentFighterId;
  final String opponentShortId;
  final String opponentPlatform;
  final String opponentCharacterId;
  final int opponentScore;
  final int? opponentLp;
  final int? opponentMr;
  final String opponentRankTier;
  final String opponentControlType; // 'M' or 'C'

  final bool isWin;
  final String replayCode;
  final List<RoundDetail> rounds;

  BattleRecord({
    required this.id,
    required this.shortId,
    required this.platform,
    required this.playedAt,
    required this.battleType,
    required this.playerCharacterId,
    required this.playerScore,
    this.playerLpChange = 0,
    this.playerMrChange = 0,
    this.playerCurrentLp,
    this.playerCurrentMr,
    this.playerControlType = 'C',
    required this.opponentFighterId,
    required this.opponentShortId,
    required this.opponentPlatform,
    required this.opponentCharacterId,
    required this.opponentScore,
    this.opponentLp,
    this.opponentMr,
    this.opponentRankTier = 'master',
    this.opponentControlType = 'C',
    required this.isWin,
    this.replayCode = '',
    this.rounds = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'shortId': shortId,
    'platform': platform,
    'playedAt': playedAt.toIso8601String(),
    'battleType': battleType.name,
    'playerCharacterId': playerCharacterId,
    'playerScore': playerScore,
    'playerLpChange': playerLpChange,
    'playerMrChange': playerMrChange,
    'playerCurrentLp': playerCurrentLp,
    'playerCurrentMr': playerCurrentMr,
    'playerControlType': playerControlType,
    'opponentFighterId': opponentFighterId,
    'opponentShortId': opponentShortId,
    'opponentPlatform': opponentPlatform,
    'opponentCharacterId': opponentCharacterId,
    'opponentScore': opponentScore,
    'opponentLp': opponentLp,
    'opponentMr': opponentMr,
    'opponentRankTier': opponentRankTier,
    'opponentControlType': opponentControlType,
    'isWin': isWin ? 1 : 0,
    'replayCode': replayCode,
    'roundsJson': rounds.map((r) => r.toJson()).toList().toString(),
  };

  factory BattleRecord.fromMap(Map<String, dynamic> map, {List<RoundDetail>? rounds}) => BattleRecord(
    id: map['id'] ?? '',
    shortId: map['shortId'] ?? '',
    platform: map['platform'] ?? 'steam',
    playedAt: DateTime.tryParse(map['playedAt'] ?? '') ?? DateTime.now(),
    battleType: BattleType.fromString(map['battleType'] ?? 'ranked'),
    playerCharacterId: map['playerCharacterId'] ?? 'luke',
    playerScore: map['playerScore'] ?? 0,
    playerLpChange: map['playerLpChange'] ?? 0,
    playerMrChange: map['playerMrChange'] ?? 0,
    playerCurrentLp: map['playerCurrentLp'],
    playerCurrentMr: map['playerCurrentMr'],
    playerControlType: map['playerControlType'] ?? 'C',
    opponentFighterId: map['opponentFighterId'] ?? 'Player 2',
    opponentShortId: map['opponentShortId'] ?? '',
    opponentPlatform: map['opponentPlatform'] ?? 'steam',
    opponentCharacterId: map['opponentCharacterId'] ?? 'ryu',
    opponentScore: map['opponentScore'] ?? 0,
    opponentLp: map['opponentLp'],
    opponentMr: map['opponentMr'],
    opponentRankTier: map['opponentRankTier'] ?? 'master',
    opponentControlType: map['opponentControlType'] ?? 'C',
    isWin: map['isWin'] == 1 || map['isWin'] == true,
    replayCode: map['replayCode'] ?? '',
    rounds: rounds ?? [],
  );
}
