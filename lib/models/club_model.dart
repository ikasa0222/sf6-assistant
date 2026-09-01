class ClubMember {
  final String shortId;
  final String fighterId;
  final String avatarUrl;
  final String role; // 会长/管理, 副会长, 成员
  final String platform;
  final String mainCharacterId;
  final int lp;
  final int mr;
  final bool isOnline;
  final String statusText; // 排位赛中, 训练模式中, 格斗中心, 自定义房, 在线, 离线
  final int monthlyPoints;

  ClubMember({
    required this.shortId,
    required this.fighterId,
    this.avatarUrl = '',
    required this.role,
    required this.platform,
    required this.mainCharacterId,
    required this.lp,
    this.mr = 0,
    required this.isOnline,
    this.statusText = '在线',
    this.monthlyPoints = 0,
  });

  Map<String, dynamic> toJson() => {
    'shortId': shortId,
    'fighterId': fighterId,
    'avatarUrl': avatarUrl,
    'role': role,
    'platform': platform,
    'mainCharacterId': mainCharacterId,
    'lp': lp,
    'mr': mr,
    'isOnline': isOnline,
    'statusText': statusText,
    'monthlyPoints': monthlyPoints,
  };

  factory ClubMember.fromJson(Map<String, dynamic> json) => ClubMember(
    shortId: json['shortId'] ?? '',
    fighterId: json['fighterId'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    role: json['role'] ?? '成员',
    platform: json['platform'] ?? 'steam',
    mainCharacterId: json['mainCharacterId'] ?? 'luke',
    lp: json['lp'] ?? 0,
    mr: json['mr'] ?? 0,
    isOnline: json['isOnline'] == true || json['isOnline'] == 1,
    statusText: json['statusText'] ?? (json['isOnline'] == true ? '在线' : '离线'),
    monthlyPoints: json['monthlyPoints'] ?? 0,
  );
}

class ClubModel {
  final String clubId;
  final String clubName;
  final String tag;
  final String emblemUrl;
  final String notice;
  final int memberCount;
  final int maxMemberCount;
  final int totalMonthlyPoints;
  final List<ClubMember> members;

  ClubModel({
    required this.clubId,
    required this.clubName,
    required this.tag,
    this.emblemUrl = '',
    this.notice = '',
    required this.memberCount,
    this.maxMemberCount = 100,
    this.totalMonthlyPoints = 0,
    this.members = const [],
  });

  Map<String, dynamic> toJson() => {
    'clubId': clubId,
    'clubName': clubName,
    'tag': tag,
    'emblemUrl': emblemUrl,
    'notice': notice,
    'memberCount': memberCount,
    'maxMemberCount': maxMemberCount,
    'totalMonthlyPoints': totalMonthlyPoints,
    'members': members.map((m) => m.toJson()).toList(),
  };

  factory ClubModel.fromJson(Map<String, dynamic> json) => ClubModel(
    clubId: json['clubId'] ?? '',
    clubName: json['clubName'] ?? '',
    tag: json['tag'] ?? '',
    emblemUrl: json['emblemUrl'] ?? '',
    notice: json['notice'] ?? '',
    memberCount: json['memberCount'] ?? 0,
    maxMemberCount: json['maxMemberCount'] ?? 100,
    totalMonthlyPoints: json['totalMonthlyPoints'] ?? 0,
    members: (json['members'] as List<dynamic>?)
            ?.map((e) => ClubMember.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
