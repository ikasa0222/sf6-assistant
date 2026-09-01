class FriendModel {
  final String shortId;
  final String fighterId;
  final String avatarUrl;
  final String platform;
  final bool isOnline;
  final String statusText; // e.g. "Battle Hub - Server 01 (Sitting)", "Fighting Ground - Ranked", "Offline"
  final String mainCharacterId;
  final int lp;
  final int mr;
  final DateTime lastSeen;

  FriendModel({
    required this.shortId,
    required this.fighterId,
    this.avatarUrl = '',
    required this.platform,
    required this.isOnline,
    required this.statusText,
    required this.mainCharacterId,
    required this.lp,
    this.mr = 0,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
    'shortId': shortId,
    'fighterId': fighterId,
    'avatarUrl': avatarUrl,
    'platform': platform,
    'isOnline': isOnline,
    'statusText': statusText,
    'mainCharacterId': mainCharacterId,
    'lp': lp,
    'mr': mr,
    'lastSeen': lastSeen.toIso8601String(),
  };

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
    shortId: json['shortId'] ?? '',
    fighterId: json['fighterId'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    platform: json['platform'] ?? 'steam',
    isOnline: json['isOnline'] == true || json['isOnline'] == 1,
    statusText: json['statusText'] ?? (json['isOnline'] == true ? '在线' : '离线'),
    mainCharacterId: json['mainCharacterId'] ?? 'ryu',
    lp: json['lp'] ?? 0,
    mr: json['mr'] ?? 0,
    lastSeen: DateTime.tryParse(json['lastSeen'] ?? '') ?? DateTime.now(),
  );
}
