enum AppThemeMode {
  esportsDark,
  streetNeon,
  materialYou;

  String get displayName {
    switch (this) {
      case AppThemeMode.esportsDark:
        return '电竞暗黑风 (Esports Dark)';
      case AppThemeMode.streetNeon:
        return '街头涂鸦风 (Street Neon)';
      case AppThemeMode.materialYou:
        return 'Material 现代风 (Material You)';
    }
  }

  static AppThemeMode fromString(String val) {
    switch (val) {
      case 'streetNeon':
        return AppThemeMode.streetNeon;
      case 'materialYou':
        return AppThemeMode.materialYou;
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
    this.themeMode = AppThemeMode.esportsDark,
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
    themeMode: AppThemeMode.fromString(json['themeMode'] ?? 'esportsDark'),
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
