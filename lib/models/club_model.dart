class ClubMember {
  final String shortId;
  final String fighterId;
  final String avatarUrl;
  final String role; // 战队会长, 副会长, 成员
  final String platform;
  final String mainCharacterId;
  final int lp;
  final int mr;
  final bool isOnline;
  final String statusText; // 排位赛中, 训练模式中, 格斗中心, 休闲匹配, 在线, 离线
  final String battleHubServer; // e.g. 亚洲 1-02
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
    this.battleHubServer = '',
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
    'battleHubServer': battleHubServer,
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
    battleHubServer: json['battleHubServer'] ?? '',
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
  final bool isMainClub;
  final int onlineMemberCount;
  final String leaderFighterId;
  final String leaderShortId;
  final String leaderPlatform;
  final List<String> tags;
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
    this.isMainClub = false,
    this.onlineMemberCount = 0,
    this.leaderFighterId = '',
    this.leaderShortId = '',
    this.leaderPlatform = '',
    this.tags = const [],
    this.members = const [],
  });

  ClubModel copyWith({
    String? clubId,
    String? clubName,
    String? tag,
    String? emblemUrl,
    String? notice,
    int? memberCount,
    int? maxMemberCount,
    int? totalMonthlyPoints,
    bool? isMainClub,
    int? onlineMemberCount,
    String? leaderFighterId,
    String? leaderShortId,
    String? leaderPlatform,
    List<String>? tags,
    List<ClubMember>? members,
  }) {
    return ClubModel(
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      tag: tag ?? this.tag,
      emblemUrl: emblemUrl ?? this.emblemUrl,
      notice: notice ?? this.notice,
      memberCount: memberCount ?? this.memberCount,
      maxMemberCount: maxMemberCount ?? this.maxMemberCount,
      totalMonthlyPoints: totalMonthlyPoints ?? this.totalMonthlyPoints,
      isMainClub: isMainClub ?? this.isMainClub,
      onlineMemberCount: onlineMemberCount ?? this.onlineMemberCount,
      leaderFighterId: leaderFighterId ?? this.leaderFighterId,
      leaderShortId: leaderShortId ?? this.leaderShortId,
      leaderPlatform: leaderPlatform ?? this.leaderPlatform,
      tags: tags ?? this.tags,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toJson() => {
    'clubId': clubId,
    'clubName': clubName,
    'tag': tag,
    'emblemUrl': emblemUrl,
    'notice': notice,
    'memberCount': memberCount,
    'maxMemberCount': maxMemberCount,
    'totalMonthlyPoints': totalMonthlyPoints,
    'isMainClub': isMainClub,
    'onlineMemberCount': onlineMemberCount,
    'leaderFighterId': leaderFighterId,
    'leaderShortId': leaderShortId,
    'leaderPlatform': leaderPlatform,
    'tags': tags,
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
    totalMonthlyPoints: json['totalMonthlyPoints'] ?? json['total_point'] ?? json['recently_point'] ?? 0,
    isMainClub: json['isMainClub'] == true || json['main_circle_flg'] == true,
    onlineMemberCount: json['onlineMemberCount'] ?? json['online_member_count'] ?? 0,
    leaderFighterId: json['leaderFighterId'] ?? '',
    leaderShortId: json['leaderShortId'] ?? '',
    leaderPlatform: json['leaderPlatform'] ?? '',
    tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    members: (json['members'] as List<dynamic>?)
            ?.map((e) => ClubMember.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
