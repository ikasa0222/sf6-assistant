enum AppThemeMode {
  claudeWarm,
  esportsDark;

  String get displayName {
    switch (this) {
      case AppThemeMode.claudeWarm:
        return '暖纸美学';
      case AppThemeMode.esportsDark:
        return '电竞朋克';
    }
  }

  static AppThemeMode fromString(String val) {
    switch (val) {
      case 'claudeWarm':
      case 'claude':
      case 'parchment':
      case 'warmPaper':
      case '暖纸美学':
        return AppThemeMode.claudeWarm;
      case 'esportsDark':
      case 'cyberpunk':
      case 'streetNeon':
      case 'materialYou':
      case '电竞朋克':
      default:
        return AppThemeMode.esportsDark;
    }
  }
}

class AppSettings {
  final AppThemeMode themeMode;
  final bool showMatchupAnalytics;
  final bool showFriendsClub;
  final bool showFrameData;
  final bool showMatchupNotes;
  final bool autoSyncOnLaunch;
  final int backgroundSyncIntervalMinutes;
  final bool notifyFriendOnline;
  final bool notifyClubMilestones;
  final bool useMockDataIfOffline;

  const AppSettings({
    this.themeMode = AppThemeMode.claudeWarm,
    this.showMatchupAnalytics = true,
    this.showFriendsClub = true,
    this.showFrameData = true,
    this.showMatchupNotes = true,
    this.autoSyncOnLaunch = true,
    this.backgroundSyncIntervalMinutes = 15,
    this.notifyFriendOnline = true,
    this.notifyClubMilestones = true,
    this.useMockDataIfOffline = true,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? showMatchupAnalytics,
    bool? showFriendsClub,
    bool? showFrameData,
    bool? showMatchupNotes,
    bool? autoSyncOnLaunch,
    int? backgroundSyncIntervalMinutes,
    bool? notifyFriendOnline,
    bool? notifyClubMilestones,
    bool? useMockDataIfOffline,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      showMatchupAnalytics: showMatchupAnalytics ?? this.showMatchupAnalytics,
      showFriendsClub: showFriendsClub ?? this.showFriendsClub,
      showFrameData: showFrameData ?? this.showFrameData,
      showMatchupNotes: showMatchupNotes ?? this.showMatchupNotes,
      autoSyncOnLaunch: autoSyncOnLaunch ?? this.autoSyncOnLaunch,
      backgroundSyncIntervalMinutes: backgroundSyncIntervalMinutes ?? this.backgroundSyncIntervalMinutes,
      notifyFriendOnline: notifyFriendOnline ?? this.notifyFriendOnline,
      notifyClubMilestones: notifyClubMilestones ?? this.notifyClubMilestones,
      useMockDataIfOffline: useMockDataIfOffline ?? this.useMockDataIfOffline,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'showMatchupAnalytics': showMatchupAnalytics,
    'showFriendsClub': showFriendsClub,
    'showFrameData': showFrameData,
    'showMatchupNotes': showMatchupNotes,
    'autoSyncOnLaunch': autoSyncOnLaunch,
    'backgroundSyncIntervalMinutes': backgroundSyncIntervalMinutes,
    'notifyFriendOnline': notifyFriendOnline,
    'notifyClubMilestones': notifyClubMilestones,
    'useMockDataIfOffline': useMockDataIfOffline,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode: AppThemeMode.fromString(json['themeMode'] ?? 'claudeWarm'),
    showMatchupAnalytics: json['showMatchupAnalytics'] ?? true,
    showFriendsClub: json['showFriendsClub'] ?? true,
    showFrameData: json['showFrameData'] ?? true,
    showMatchupNotes: json['showMatchupNotes'] ?? true,
    autoSyncOnLaunch: json['autoSyncOnLaunch'] ?? true,
    backgroundSyncIntervalMinutes: json['backgroundSyncIntervalMinutes'] ?? 15,
    notifyFriendOnline: json['notifyFriendOnline'] ?? true,
    notifyClubMilestones: json['notifyClubMilestones'] ?? true,
    useMockDataIfOffline: json['useMockDataIfOffline'] ?? true,
  );
}
