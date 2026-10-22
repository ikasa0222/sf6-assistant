import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sf6_tracker/core/theme/app_theme.dart';
import 'package:sf6_tracker/core/theme/liquid_glass_container.dart';
import 'package:sf6_tracker/core/theme/monet_ambient_canvas.dart';
import 'package:sf6_tracker/models/app_settings.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/services/frame_data_service.dart';
import 'package:sf6_tracker/services/notes_service.dart';
import 'package:sf6_tracker/services/combo_service.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/ui/screens/home/home_screen.dart';
import 'package:sf6_tracker/ui/screens/battle_log/battle_log_screen.dart';
import 'package:sf6_tracker/ui/screens/analytics/analytics_screen.dart';
import 'package:sf6_tracker/ui/screens/social/social_screen.dart';
import 'package:sf6_tracker/ui/screens/settings/settings_screen.dart';
import 'package:sf6_tracker/services/update_service.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/ui/widgets/announcement_dialog.dart';

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
  final ComboService _comboService = ComboService();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  AppSettings _settings = const AppSettings();
  int _currentIndex = 0;
  bool _isInitialized = false;
  DateTime? _lastBackPressTime;
  Timer? _backgroundSyncTimer;

  String? _lastActivePlatformKey;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _settings = await StorageService.instance.getSettings();
    await _authService.initialize();
    await _comboService.init();

    _lastActivePlatformKey = '${_authService.activeAccount?.id}_${_authService.activePlatform?.shortId}';
    await _loadAllData(_authService.activePlatform);

    _authService.addListener(_onAuthChanged);

    setState(() {
      _isInitialized = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _checkAnnouncement();
          _checkDailyUpdate();
        }
      });
      Future.delayed(const Duration(seconds: 4), () {
        _triggerSilentBackgroundSync();
      });
      _backgroundSyncTimer = Timer.periodic(const Duration(minutes: 10), (_) {
        _triggerSilentBackgroundSync();
      });
    });
  }

  Future<void> _checkAnnouncement() async {
    try {
      final navContext = _navigatorKey.currentContext;
      if (navContext == null || !mounted) return;
      final lastSeen = await StorageService.instance.getLastSeenAnnouncementVersion();
      final currentVer = AppLogger.currentAppVersion;
      if (lastSeen != currentVer && mounted) {
        final activeContext = _navigatorKey.currentContext;
        if (activeContext != null && mounted) {
          await AnnouncementDialog.show(activeContext);
          await StorageService.instance.setLastSeenAnnouncementVersion(currentVer);
        }
      }
    } catch (e) {
      AppLogger.instance.warn('App', '检查公告异常: $e');
    }
  }

  Future<void> _checkDailyUpdate() async {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final lastCheck = await StorageService.instance.getLastUpdateCheckDate();
      if (lastCheck == todayStr) return;

      final release = await UpdateService.instance.checkForUpdates(isManual: false);
      if (UpdateService.instance.errorMessage.isEmpty) {
        await StorageService.instance.setLastUpdateCheckDate(todayStr);
      }
      final activeContext = _navigatorKey.currentContext;
      if (release != null && UpdateService.instance.hasNewVersion && mounted && activeContext != null) {
        UpdateService.instance.showUpdateDialog(activeContext, release);
      }
    } catch (e) {
      AppLogger.instance.warn('App', '检查每日更新异常: $e');
    }
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
    final currentKey = '${_authService.activeAccount?.id}_${_authService.activePlatform?.shortId}';
    if (currentKey == _lastActivePlatformKey) {
      // Identity unchanged (data update during sync/refresh).
      // Child screens handle their own reactive updates without tearing down the root tree.
      return;
    }
    _lastActivePlatformKey = currentKey;
    await _loadAllData(_authService.activePlatform);
    if (mounted) setState(() {});
  }

  Future<void> _triggerSilentBackgroundSync() async {
    if (!mounted) return;
    if (_authService.activePlatform == null) return;
    try {
      await _battleLogService.performBackgroundSync(
        authService: _authService,
        statsService: _statsService,
        socialService: _socialService,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _backgroundSyncTimer?.cancel();
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
        navigatorKey: _navigatorKey,
        title: '街霸6助手',
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
          statsService: _statsService,
          socialService: _socialService,
        ),
      ),
      if (_settings.showMatchupAnalytics)
        _NavigationItem(
          label: '分析',
          icon: const Icon(Icons.bar_chart),
          screen: AnalyticsScreen(
            authService: _authService,
            statsService: _statsService,
            battleLogService: _battleLogService,
            socialService: _socialService,
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
    final isClaudeWarm = _settings.themeMode == AppThemeMode.claudeWarm;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: '街霸6助手',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(_settings.themeMode),
      builder: (context, child) {
        if (isClaudeWarm && child != null) {
          return MonetAmbientCanvas(
            child: child,
          );
        }
        return child ?? const SizedBox();
      },
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
              backgroundColor: isClaudeWarm ? Colors.transparent : null,
              extendBody: true,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: IndexedStack(
                      index: clampedIndex,
                      children: navItems.map((item) => item.screen).toList(),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildLiquidGlassFloatingDock(context, navItems, clampedIndex, isClaudeWarm),
                  ),
                ],
              ),
              bottomNavigationBar: null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiquidGlassFloatingDock(
    BuildContext context,
    List<_NavigationItem> items,
    int currentIndex,
    bool isClaudeWarm,
  ) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final effectiveBottom = math.max(14.0, bottomInset);

    // 暖纸美学：象牙白微透温润液态玻璃 + 柔和暖调阴影；电竞朋克：极客暗黑微透液态玻璃 + 霓虹青微光阴影
    final glassBg = isClaudeWarm
        ? const Color(0xC7FFFFFF) // 78% 象牙白温润液态玻璃
        : const Color(0xB80E1424); // 72% 暗黑数码液态玻璃
    final glassBorder = isClaudeWarm
        ? const Color(0x60E5DFC9) // 极细暖纸边框
        : const Color(0x5900E5FF); // 赛博荧光青边框
    final glassShadows = isClaudeWarm
        ? [
            const BoxShadow(
              color: Color(0x1A402010),
              blurRadius: 28,
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFFD97757).withOpacity(0.08),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, -1),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 28,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.18),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, -1),
            ),
          ];

    final activeColor = isClaudeWarm ? const Color(0xFFD97757) : const Color(0xFF00E5FF);
    final inactiveColor = isClaudeWarm ? const Color(0xFF7A756D) : const Color(0xFF6B7280);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: effectiveBottom,
        top: 6,
      ),
      child: LiquidGlassContainer(
        borderRadius: 30,
        blurSigma: 24,
        backgroundColor: glassBg,
        borderColor: glassBorder,
        borderWidth: 1.0,
        shadows: glassShadows,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              activeColor.withOpacity(isClaudeWarm ? 0.20 : 0.25),
                              activeColor.withOpacity(isClaudeWarm ? 0.08 : 0.08),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(
                            color: activeColor.withOpacity(isClaudeWarm ? 0.45 : 0.65),
                            width: 1,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: activeColor.withOpacity(isClaudeWarm ? 0.18 : 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconTheme(
                        data: IconThemeData(
                          color: isSelected ? activeColor : inactiveColor,
                          size: 21,
                        ),
                        child: item.icon,
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? activeColor : inactiveColor,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
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
