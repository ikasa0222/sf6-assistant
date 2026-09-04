import 'user_profile.dart';

enum PlatformType {
  steam,
  nintendoSwitch2,
  playstation,
  xbox;

  String get displayName {
    switch (this) {
      case PlatformType.steam:
        return 'Steam (PC)';
      case PlatformType.nintendoSwitch2:
        return 'Nintendo Switch 2';
      case PlatformType.playstation:
        return 'PlayStation (PS5/PS4)';
      case PlatformType.xbox:
        return 'Xbox Series X|S';
    }
  }

  String get code {
    switch (this) {
      case PlatformType.steam:
        return 'steam';
      case PlatformType.nintendoSwitch2:
        return 'switch2';
      case PlatformType.playstation:
        return 'psn';
      case PlatformType.xbox:
        return 'xbox';
    }
  }

  static PlatformType fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'steam':
      case 'pc':
        return PlatformType.steam;
      case 'switch':
      case 'switch2':
      case 'ns':
      case 'ns2':
      case 'nsw':
      case 'nsw2':
      case 'nintendo':
        return PlatformType.nintendoSwitch2;
      case 'psn':
      case 'ps5':
      case 'ps4':
      case 'playstation':
        return PlatformType.playstation;
      case 'xbox':
      case 'xbs':
        return PlatformType.xbox;
      default:
        return PlatformType.steam;
    }
  }

  static String formatPlatformBadge(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '未知';
    final lower = raw.toLowerCase().trim();
    if (lower.contains('switch') || lower.contains('nsw') || lower.contains('ns')) return 'NS2';
    if (lower.contains('steam') || lower.contains('pc')) return 'Steam';
    if (lower.contains('ps5') || lower.contains('playstation_5')) return 'PS5';
    if (lower.contains('ps4') || lower.contains('playstation_4')) return 'PS4';
    if (lower.contains('psn') || lower.contains('playstation')) return 'PlayStation';
    if (lower.contains('xbox') || lower.contains('xbs')) return 'Xbox';
    if (lower.contains('cross')) return '跨平台';
    return lower.length > 5 ? lower.substring(0, 5).toUpperCase() : lower.toUpperCase();
  }
}

class PlatformProfile {
  final PlatformType platformType;
  final String shortId;
  final String fighterId;
  final String avatarUrl;
  final int? currentLp;
  final int? currentMr;
  final String clubName;
  final String mainCharId;
  final List<CharacterUsage> characterUsages;

  PlatformProfile({
    required this.platformType,
    required this.shortId,
    required this.fighterId,
    this.avatarUrl = '',
    this.currentLp,
    this.currentMr,
    this.clubName = '',
    this.mainCharId = '',
    this.characterUsages = const [],
  });

  Map<String, dynamic> toJson() => {
    'platformType': platformType.code,
    'shortId': shortId,
    'fighterId': fighterId,
    'avatarUrl': avatarUrl,
    'currentLp': currentLp,
    'currentMr': currentMr,
    'clubName': clubName,
    'mainCharId': mainCharId,
    'characterUsages': characterUsages.map((u) => u.toJson()).toList(),
  };

  factory PlatformProfile.fromJson(Map<String, dynamic> json) => PlatformProfile(
    platformType: PlatformType.fromCode(json['platformType'] ?? 'steam'),
    shortId: json['shortId'] ?? '',
    fighterId: json['fighterId'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    currentLp: json['currentLp'],
    currentMr: json['currentMr'],
    clubName: json['clubName'] ?? '',
    mainCharId: json['mainCharId'] ?? '',
    characterUsages: json['characterUsages'] != null
        ? (json['characterUsages'] as List)
            .map((u) => CharacterUsage.fromJson(u is Map ? Map<String, dynamic>.from(u) : {}))
            .toList()
        : const [],
  );
}

class CapcomAccount {
  final String id;
  final String capcomId;
  final String displayName;
  final String email;
  final String cookieSession;
  final List<PlatformProfile> linkedPlatforms;
  final int activePlatformIndex;
  final DateTime lastLoginAt;

  CapcomAccount({
    required this.id,
    required this.capcomId,
    required this.displayName,
    this.email = '',
    required this.cookieSession,
    required this.linkedPlatforms,
    this.activePlatformIndex = 0,
    required this.lastLoginAt,
  });

  PlatformProfile? get activePlatform {
    if (linkedPlatforms.isEmpty) return null;
    if (activePlatformIndex >= 0 && activePlatformIndex < linkedPlatforms.length) {
      return linkedPlatforms[activePlatformIndex];
    }
    return linkedPlatforms.first;
  }

  CapcomAccount copyWith({
    String? id,
    String? capcomId,
    String? displayName,
    String? email,
    String? cookieSession,
    List<PlatformProfile>? linkedPlatforms,
    int? activePlatformIndex,
    DateTime? lastLoginAt,
  }) {
    return CapcomAccount(
      id: id ?? this.id,
      capcomId: capcomId ?? this.capcomId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      cookieSession: cookieSession ?? this.cookieSession,
      linkedPlatforms: linkedPlatforms ?? this.linkedPlatforms,
      activePlatformIndex: activePlatformIndex ?? this.activePlatformIndex,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'capcomId': capcomId,
    'displayName': displayName,
    'email': email,
    'cookieSession': cookieSession,
    'linkedPlatforms': linkedPlatforms.map((p) => p.toJson()).toList(),
    'activePlatformIndex': activePlatformIndex,
    'lastLoginAt': lastLoginAt.toIso8601String(),
  };

  factory CapcomAccount.fromJson(Map<String, dynamic> json) => CapcomAccount(
    id: json['id'] ?? '',
    capcomId: json['capcomId'] ?? '',
    displayName: json['displayName'] ?? 'SF6 Fighter',
    email: json['email'] ?? '',
    cookieSession: json['cookieSession'] ?? '',
    linkedPlatforms: (json['linkedPlatforms'] as List<dynamic>?)
            ?.map((e) => PlatformProfile.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    activePlatformIndex: json['activePlatformIndex'] ?? 0,
    lastLoginAt: DateTime.tryParse(json['lastLoginAt'] ?? '') ?? DateTime.now(),
  );
}
