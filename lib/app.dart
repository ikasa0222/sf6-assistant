import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sf6_tracker/core/theme/app_theme.dart';
import 'package:sf6_tracker/models/app_settings.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/services/frame_data_service.dart';
import 'package:sf6_tracker/services/notes_service.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/ui/screens/home/home_screen.dart';
import 'package:sf6_tracker/ui/screens/battle_log/battle_log_screen.dart';
import 'package:sf6_tracker/ui/screens/analytics/analytics_screen.dart';
import 'package:sf6_tracker/ui/screens/social/social_screen.dart';
import 'package:sf6_tracker/ui/screens/tools/tools_screen.dart';
import 'package:sf6_tracker/ui/screens/settings/settings_screen.dart';
import 'package:sf6_tracker/services/update_service.dart';

class Sf6App extends StatefulWidget {
  const Sf6App({super.key});

  @override
  State<Sf6App> createState() => _Sf6AppState();
}

class _Sf6AppState extends State<Sf6App> {
  final AuthService _authService = AuthService();
  final BattleLogService _battleLogService = BattleLogService();
  final StatsService _statsService = StatsService();
  final SocialService _socialService = SocialService();
  final FrameDataService _frameDataService = FrameDataService();
  final NotesService _notesService = NotesService();

  AppSettings _settings = const AppSettings();
  int _currentIndex = 0;
  bool _isInitialized = false;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _settings = await StorageService.instance.getSettings();
    await _authService.initialize();

    await _loadAllData(_authService.activePlatform);

    _authService.addListener(_onAuthChanged);

    setState(() {
      _isInitialized = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyUpdate();
    });
  }

  Future<void> _checkDailyUpdate() async {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final lastCheck = await StorageService.instance.getLastUpdateCheckDate();
      if (lastCheck == todayStr) return;

      await StorageService.instance.setLastUpdateCheckDate(todayStr);
      final release = await UpdateService.instance.checkForUpdates(isManual: false);
      if (release != null && UpdateService.instance.hasNewVersion && mounted) {
        UpdateService.instance.showUpdateDialog(context, release);
      }
    } catch (_) {}
  }

  Future<void> _loadAllData(PlatformProfile? activePlatform) async {
    if (activePlatform == null) return;
    await _battleLogService.loadRecords(
      shortId: activePlatform.shortId,
      platform: activePlatform.platformType.code,
      fighterId: activePlatform.fighterId,
      lp: activePlatform.currentLp,
      mr: activePlatform.currentMr,
      mainCharId: activePlatform.mainCharId,
      clubName: activePlatform.clubName,
      characterUsages: activePlatform.characterUsages,
    );
    await _statsService.loadStats(
      shortId: activePlatform.shortId,
      platform: activePlatform.platformType.code,
    );
    await _socialService.loadSocialData(
      clubName: activePlatform.clubName,
      shortId: activePlatform.shortId,
    );
  }

  void _onAuthChanged() async {
    await _loadAllData(_authService.activePlatform);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _updateSettings(AppSettings newSettings) async {
    setState(() => _settings = newSettings);
    await StorageService.instance.saveSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getTheme(_settings.themeMode),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Build navigation items based on settings toggles
    final navItems = <_NavigationItem>[
      _NavigationItem(
        label: '首页',
        icon: const Icon(Icons.dashboard),
        screen: HomeScreen(
          authService: _authService,
          battleLogService: _battleLogService,
          statsService: _statsService,
          socialService: _socialService,
          onNavigateToBattleLog: () => _navigateToTab('战绩'),
          onNavigateToAnalytics: () => _navigateToTab('分析'),
        ),
      ),
      _NavigationItem(
        label: '战绩',
        icon: const Icon(Icons.history),
        screen: BattleLogScreen(
          authService: _authService,
          battleLogService: _battleLogService,
          notesService: _notesService,
        ),
      ),
      if (_settings.showMatchupAnalytics)
        _NavigationItem(
          label: '分析',
          icon: const Icon(Icons.bar_chart),
          screen: AnalyticsScreen(
            authService: _authService,
            statsService: _statsService,
          ),
        ),
      if (_settings.showFriendsClub)
        _NavigationItem(
          label: '社交',
          icon: const Icon(Icons.people),
          screen: SocialScreen(
            socialService: _socialService,
            authService: _authService,
            battleLogService: _battleLogService,
            statsService: _statsService,
          ),
        ),
      if (_settings.showFrameData || _settings.showMatchupNotes)
        _NavigationItem(
          label: '工具',
          icon: const Icon(Icons.construction),
          screen: ToolsScreen(
            frameDataService: _frameDataService,
            notesService: _notesService,
          ),
        ),
      _NavigationItem(
        label: '设置',
        icon: const Icon(Icons.settings),
        screen: SettingsScreen(
          authService: _authService,
          battleLogService: _battleLogService,
          statsService: _statsService,
          socialService: _socialService,
          settings: _settings,
          onUpdateSettings: _updateSettings,
        ),
      ),
    ];

    final clampedIndex = _currentIndex.clamp(0, navItems.length - 1);

    return MaterialApp(
      title: '街霸6助手',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(_settings.themeMode),
      home: Builder(
        builder: (context) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (_currentIndex != 0) {
                setState(() => _currentIndex = 0);
              } else {
                final now = DateTime.now();
                if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
                  _lastBackPressTime = now;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('再次滑动返回退出应用'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  SystemNavigator.pop();
                }
              }
            },
            child: Scaffold(
              body: IndexedStack(
                index: clampedIndex,
                children: navItems.map((item) => item.screen).toList(),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: clampedIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                items: navItems
                    .map((item) => BottomNavigationBarItem(
                          icon: item.icon,
                          label: item.label,
                        ))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToTab(String label) {
    setState(() {
      if (label == '战绩') _currentIndex = 1;
      if (label == '分析') _currentIndex = 2;
    });
  }
}

class _NavigationItem {
  final String label;
  final Widget icon;
  final Widget screen;

  _NavigationItem({
    required this.label,
    required this.icon,
    required this.screen,
  });
}
