import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sf6_tracker/models/user_profile.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/play_time_model.dart';
import 'package:sf6_tracker/models/home_card_config.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/rank_badge.dart';
import 'package:sf6_tracker/ui/widgets/win_rate_bar.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/core/network/capcom_sync_engine.dart';
import 'package:sf6_tracker/ui/widgets/quick_sync_dialog.dart';
import 'package:sf6_tracker/ui/screens/auth/login_webview_screen.dart';
import 'package:sf6_tracker/ui/widgets/ranked_score_chart_card.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  final BattleLogService battleLogService;
  final StatsService? statsService;
  final SocialService? socialService;
  final VoidCallback onNavigateToBattleLog;
  final VoidCallback onNavigateToAnalytics;

  const HomeScreen({
    super.key,
    required this.authService,
    required this.battleLogService,
    this.statsService,
    this.socialService,
    required this.onNavigateToBattleLog,
    required this.onNavigateToAnalytics,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLadderExpanded = false;
  bool _isPlayTimeExpanded = false;
  PlayTimeModel? _playTime;
  String? _loadedShortId;
  List<HomeCardConfig> _cardConfigs = HomeCardConfig.defaults;

  AuthService get authService => widget.authService;
  BattleLogService get battleLogService => widget.battleLogService;
  StatsService? get statsService => widget.statsService;
  SocialService? get socialService => widget.socialService;
  VoidCallback get onNavigateToBattleLog => widget.onNavigateToBattleLog;
  VoidCallback get onNavigateToAnalytics => widget.onNavigateToAnalytics;

  @override
  void initState() {
    super.initState();
    _fetchPlayTime();
    _loadCardConfigs();
  }

  Future<void> _loadCardConfigs() async {
    final configs = await StorageService.instance.getHomeCardConfigs();
    if (mounted) {
      setState(() {
        _cardConfigs = configs;
      });
    }
  }

  void _fetchPlayTime() async {
    final sid = authService.activePlatform?.shortId ?? battleLogService.userProfile?.shortId;
    if (sid != null && sid.isNotEmpty) {
      final json = await StorageService.instance.getPlayTimeJson(sid);
      if (mounted) {
        setState(() {
          _playTime = json != null ? PlayTimeModel.fromJson(json) : null;
          _loadedShortId = sid;
        });
      }
    }
  }

  PlayTimeModel _resolveEffectivePlayTime(UserProfile? profile) {
    if (_playTime != null && _playTime!.hasData) {
      return _playTime!;
    }
    return const PlayTimeModel();
  }

  Widget _safeBuildCard(String cardName, Widget Function() builder) {
    try {
      return builder();
    } catch (e) {
      AppLogger.instance.warn('HomeScreen', '卡片渲染异常 [$cardName]: $e');
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$cardName 加载异常，请下拉刷新重试',
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([authService, battleLogService]),
      builder: (context, _) {
        final activeAccount = authService.activeAccount;
        final activePlatform = authService.activePlatform;
        final profile = battleLogService.userProfile;
        final currentSid = activePlatform?.shortId ?? profile?.shortId;
        if (currentSid != null && currentSid.isNotEmpty && currentSid != _loadedShortId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fetchPlayTime();
          });
        }
        final mainChar = profile != null ? Sf6Characters.getById(profile.mainCharacterId) : null;

        if (activeAccount == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('街霸6助手', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.accentNeonCyan.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accentNeonCyan, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentNeonCyan.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.sports_martial_arts, size: 48, color: AppColors.accentNeonCyan),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '欢迎使用街霸6助手',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '绑定你的 Capcom ID 或输入玩家 Short ID\n即可同步全平台战绩、MR 走势与角色对策',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentNeonCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.login, size: 20),
                    label: const Text('官方登录并授权同步 (推荐)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LoginWebViewScreen(authService: authService),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.borderSubtle),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.edit, size: 20, color: AppColors.accentNeonYellow),
                    label: const Text('手动快速绑定玩家资料', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    onPressed: () => _showQuickBindDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentNeonCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.accentNeonCyan.withOpacity(0.6)),
              ),
              child: Text(
                activePlatform?.platformType.displayName ?? 'Steam',
                style: const TextStyle(
                  color: AppColors.accentNeonCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                activeAccount.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.accentNeonCyan),
            onPressed: () {
              if (battleLogService.isBackgroundSyncing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('正在自动更新数据中，请稍候...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              if (statsService != null && socialService != null) {
                QuickSyncDialog.show(
                  context,
                  authService: authService,
                  battleLogService: battleLogService,
                  statsService: statsService!,
                  socialService: socialService!,
                );
              }
            },
            tooltip: '一键同步最新官方战绩',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (battleLogService.isBackgroundSyncing) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('正在自动更新数据中，请稍候...'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          if (activePlatform != null) {
            try {
              AppLogger.instance.info('HomeScreen', '[HOME_REFRESH_INIT] 用户下拉刷新主页数据');
              final res = await CapcomSyncEngine.performFullSync(
                authService: authService,
                battleLogService: battleLogService,
                statsService: statsService,
                socialService: socialService,
              );
              if (mounted) {
                _fetchPlayTime();
                _loadCardConfigs();
                if (res.needLogin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('官方会话已过期，请重新登录'), backgroundColor: AppColors.loseRed),
                  );
                } else if (res.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.recordsUpdated > 0 ? '同步完成，已更新 ${res.recordsUpdated} 局最新对战' : '同步完成，已是最新数据'),
                      backgroundColor: AppColors.winGreen,
                    ),
                  );
                }
              }
            } catch (e) {
              AppLogger.instance.warn('HomeScreen', '下拉刷新异常: $e');
            }
          }
        },
        color: AppColors.accentNeonCyan,
        backgroundColor: AppColors.bgCard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildDynamicHomeCards(context, profile, activePlatform, mainChar),
          ),
        ),
      ),
    );
      },
    );
  }

  List<Widget> _buildDynamicHomeCards(
    BuildContext context,
    UserProfile? profile,
    PlatformProfile? activePlatform,
    Sf6Character? mainChar,
  ) {
    final visibleConfigs = _cardConfigs
        .where((c) => c.isVisible || c.key == HomeCardConfig.keyHero)
        .toList();

    final widgets = <Widget>[];

    for (final config in visibleConfigs) {
      Widget? cardWidget;
      switch (config.key) {
        case HomeCardConfig.keyHero:
          cardWidget = _safeBuildCard(
            '玩家资料卡片',
            () => _buildFighterHeroCard(context, profile, activePlatform, mainChar),
          );
          break;
        case HomeCardConfig.keyScoreChart:
          cardWidget = _safeBuildCard(
            '排位分数走势',
            () => RankedScoreChartCard(
              battleLogService: battleLogService,
              authService: authService,
            ),
          );
          break;
        case HomeCardConfig.keyLadder:
          cardWidget = _safeBuildCard(
            '角色天梯榜',
            () => _buildMultiCharacterLadder(context, profile),
          );
          break;
        case HomeCardConfig.keyRecentForm:
          cardWidget = _safeBuildCard(
            '近期状态',
            () => _buildRecentFormCard(),
          );
          break;
        case HomeCardConfig.keyPlayTime:
          cardWidget = _safeBuildCard(
            '最爱内容与游玩时长',
            () => _buildPlayTimeCard(_resolveEffectivePlayTime(profile)),
          );
          break;
        case HomeCardConfig.keyQuickStats:
          cardWidget = _safeBuildCard(
            '快速统计',
            () => _buildQuickStatsGrid(profile),
          );
          break;
        case HomeCardConfig.keyRadar:
          if (profile != null) {
            cardWidget = _safeBuildCard(
              '能力雷达',
              () => _buildRadarCard(profile.radarStats),
            );
          }
          break;
      }

      if (cardWidget != null) {
        if (widgets.isNotEmpty) {
          widgets.add(const SizedBox(height: 12));
        }
        widgets.add(cardWidget);
      }
    }

    if (visibleConfigs.length <= 1) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '已隐藏其他卡片，可在设置中重新开启',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ),
        ),
      );
    }

    widgets.add(const SizedBox(height: 16));
    return widgets;
  }

  Widget _buildFighterHeroCard(BuildContext context, UserProfile? profile, PlatformProfile? platform, Sf6Character? mainChar) {
    final fighterName = platform?.fighterId.isNotEmpty == true
        ? platform!.fighterId
        : (profile?.fighterId.isNotEmpty == true ? profile!.fighterId : '未登录玩家');

    final currentMainCharId = profile?.mainCharacterId.isNotEmpty == true
        ? profile!.mainCharacterId
        : (mainChar?.id.isNotEmpty == true ? mainChar!.id : (platform?.mainCharId ?? 'luke'));

    int lp = profile?.lp ?? platform?.currentLp ?? 0;
    int mr = profile?.mr ?? platform?.currentMr ?? 0;

    final usages = profile?.characterUsages.isNotEmpty == true
        ? profile!.characterUsages
        : (platform?.characterUsages ?? []);

    if (usages.isNotEmpty) {
      CharacterUsage? mainUsage;
      for (final u in usages) {
        if (u.characterId.toLowerCase() == currentMainCharId.toLowerCase()) {
          mainUsage = u;
          break;
        }
      }
      if (mainUsage != null && (mainUsage.lp > 0 || mainUsage.mr > 0)) {
        lp = mainUsage.lp;
        mr = mainUsage.mr;
      }
    }

    final rank = Sf6Rank.fromLpOrMr(lp, mr: mr);
    final neededLp = rank.lpNeeded(lp);
    final progress = rank.progressInTier(lp);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CharacterAvatar(characterId: currentMainCharId, size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fighterName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (authService.accounts.length > 1) ...[
                          IconButton(
                            icon: const Icon(Icons.switch_account, color: AppColors.accentNeonCyan, size: 18),
                            tooltip: '切换账号 (${authService.accounts.length}个)',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showAccountSwitchSheet(context),
                          ),
                          const SizedBox(width: 8),
                        ],
                        IconButton(
                          icon: const Icon(Icons.share, color: AppColors.accentNeonCyan, size: 18),
                          tooltip: '分享战绩海报',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showSharePosterModal(context, profile, platform, mainChar, lp, mr, rank),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.accentNeonYellow, size: 18),
                          tooltip: '修改玩家资料',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showEditProfileDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.bgSecondary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            profile?.title ?? 'Street Fighter',
                            style: const TextStyle(
                              color: AppColors.accentNeonYellow,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (profile != null && profile.clubName.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '[${profile.clubName}]',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    RankBadge(lp: lp, mr: mr),
                  ],
                ),
              ),
            ],
          ),
          if (neededLp > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accentNeonCyan.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '目标: ${rank.nextRankName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rank.tier.index <= RankTier.gold.index
                            ? '还差 $neededLp LP (约 ${(neededLp / 50).ceil()} 场净胜 • 连胜加速)'
                            : '还差 $neededLp LP (约 ${(neededLp / 50).ceil()} 场净胜)',
                        style: const TextStyle(color: AppColors.accentNeonYellow, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.bgInput,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentNeonCyan),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('主玩角色', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    '${mainChar?.nameZh ?? "特瑞"} (${mainChar?.archetype ?? "突进压制型"})',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              if (profile?.globalRank != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('全球大师榜排名', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      '#${profile!.globalRank}',
                      style: const TextStyle(
                        color: AppColors.rankLegend,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFormCard() {
    final wins = battleLogService.recentWins;
    final total = battleLogService.recentTotal;
    final winRate = battleLogService.recentWinRate;
    final form = battleLogService.recentForm;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '近期状态 (最近 20 场)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: onNavigateToBattleLog,
                child: const Row(
                  children: [
                    Text(
                      '查看战绩库',
                      style: TextStyle(color: AppColors.accentNeonCyan, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: AppColors.accentNeonCyan),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (total > 0) ...[
            WinRateBar(winRate: winRate, wins: wins, total: total, height: 10),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('近 10 局走势: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 6),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: form.map((isWin) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isWin ? AppColors.winGreen : AppColors.loseRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              isWin ? 'W' : 'L',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('暂无已归档对局，可在官方网页登录同步或手动添加', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(UserProfile? profile) {
    final winRate = profile?.winRate ?? 0.0;
    final totalMatches = profile?.totalMatches ?? 0;
    final streak = profile?.currentStreak ?? 0;
    final maxStreak = profile?.maxStreak ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('总胜率', '${winRate.toStringAsFixed(1)}%', winRate >= 50.0 ? AppColors.winGreen : AppColors.loseRed),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatItem('总对局', '$totalMatches 场', AppColors.accentNeonCyan),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatItem('当前连胜', '$streak 连胜', AppColors.accentNeonYellow),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatItem('最高连胜', '$maxStreak 场', AppColors.accentNeonPink),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCard(RadarStats stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '战斗六维能力评估 (Playstyle)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildRadarBar('压制进攻 (Offense)', stats.offense, AppColors.accentNeonPink),
          const SizedBox(height: 8),
          _buildRadarBar('确反防守 (Defense)', stats.defense, AppColors.accentNeonCyan),
          const SizedBox(height: 8),
          _buildRadarBar('精准对空 (Anti-Air)', stats.antiAir, AppColors.accentNeonYellow),
          const SizedBox(height: 8),
          _buildRadarBar('斗气管理 (Drive Control)', stats.driveGauge, AppColors.driveGaugeGreen),
          const SizedBox(height: 8),
          _buildRadarBar('连段技术 (Technique)', stats.technique, AppColors.driveImpactMagenta),
        ],
      ),
    );
  }

  Widget _buildRadarBar(String name, double value, Color color) {
    final clampedVal = value.clamp(0.0, 100.0);
    return Row(
      children: [
        SizedBox(
          width: 125,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: clampedVal / 100.0,
              backgroundColor: AppColors.bgSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          child: Text(
            '${clampedVal.round()}',
            textAlign: TextAlign.end,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showQuickBindDialog(BuildContext context) {
    final controller = TextEditingController(text: '');
    final nameController = TextEditingController();
    final lpController = TextEditingController(text: '18000');
    final mrController = TextEditingController(text: '0');
    PlatformType selectedPlatform = PlatformType.steam;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.person_add, color: AppColors.accentNeonCyan),
                  SizedBox(width: 8),
                  Text('绑定玩家 Short ID / 链接', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '输入 10 位 Short ID 或直接粘贴个人主页 URL：',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Short ID 或个人主页网址',
                        hintText: '例如 1234567890 或 https://.../profile/1234567890',
                      ),
                      onChanged: (val) {
                        final reg = RegExp(r'/profile/(\d+)');
                        final match = reg.firstMatch(val);
                        if (match != null) {
                          controller.text = match.group(1)!;
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '玩家昵称 (Fighter ID)',
                        hintText: '输入你的游戏内昵称 (如留空默认使用Short ID)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '当前 LP 积分',
                              hintText: '18000',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: mrController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '当前 MR 评分 (非大师填 0)',
                              hintText: '0',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('选择游玩平台：', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: PlatformType.values.map((p) {
                        final isSelected = selectedPlatform == p;
                        return ChoiceChip(
                          label: Text(p.displayName),
                          selected: isSelected,
                          onSelected: (_) => setDialogState(() => selectedPlatform = p),
                          selectedColor: AppColors.accentNeonCyan.withOpacity(0.3),
                          backgroundColor: AppColors.bgSecondary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
                  onPressed: () async {
                    String input = controller.text.trim();
                    final reg = RegExp(r'(\d{8,12})');
                    final match = reg.firstMatch(input);
                    final extractedId = match != null ? match.group(1)! : input;
                    final lpVal = int.tryParse(lpController.text.trim()) ?? 18000;
                    final mrVal = int.tryParse(mrController.text.trim()) ?? 0;
                    final fighterName = nameController.text.trim().isNotEmpty
                        ? nameController.text.trim()
                        : '玩家_$extractedId';

                    if (extractedId.isNotEmpty) {
                      await authService.addAccountFromShortId(
                        shortId: extractedId,
                        fighterId: fighterName,
                        platformType: selectedPlatform,
                        lp: lpVal,
                        mr: mrVal,
                      );
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已成功绑定玩家: $fighterName (Short ID: $extractedId)')),
                        );
                      }
                    }
                  },
                  child: const Text('确认绑定', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final activePlat = authService.activePlatform;
    final nameController = TextEditingController(text: activePlat?.fighterId ?? 'SF6_Player');
    final shortIdController = TextEditingController(text: activePlat?.shortId ?? '');
    final lpController = TextEditingController(text: '${activePlat?.currentLp ?? 0}');
    final mrController = TextEditingController(text: '${activePlat?.currentMr ?? 0}');
    PlatformType selectedPlatform = activePlat?.platformType ?? PlatformType.steam;

    String selectedMainCharId = activePlat?.mainCharId.isNotEmpty == true
        ? activePlat!.mainCharId
        : (battleLogService.userProfile?.mainCharacterId.isNotEmpty == true
            ? battleLogService.userProfile!.mainCharacterId
            : 'elena');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.edit, color: AppColors.accentNeonCyan),
                  SizedBox(width: 8),
                  Text('修改玩家资料与主用角色', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '玩家昵称 (Fighter ID)',
                        prefixIcon: Icon(Icons.person, size: 20, color: AppColors.accentNeonCyan),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: shortIdController,
                      decoration: const InputDecoration(
                        labelText: 'Short ID (个人主页 10 位识别码)',
                        prefixIcon: Icon(Icons.tag, size: 20, color: AppColors.accentNeonYellow),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('选择主玩角色 (Main Character)：', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMainCharId,
                          isExpanded: true,
                          dropdownColor: AppColors.bgCard,
                          items: Sf6Characters.all.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.id,
                              child: Row(
                                children: [
                                  CharacterAvatar(characterId: c.id, size: 26, showBorder: false),
                                  const SizedBox(width: 8),
                                  Text(c.nameZh, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '(${c.archetype})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedMainCharId = val;
                                final usages = battleLogService.userProfile?.characterUsages ?? [];
                                final match = usages.where((u) => u.characterId.toLowerCase() == val.toLowerCase()).toList();
                                if (match.isNotEmpty && (match.first.lp > 0 || match.first.mr > 0)) {
                                  lpController.text = '${match.first.lp}';
                                  mrController.text = '${match.first.mr}';
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '当前 LP 积分'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: mrController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '当前 MR 评分'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('选择游玩平台：', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: PlatformType.values.map((p) {
                        final isSelected = selectedPlatform == p;
                        return ChoiceChip(
                          label: Text(p.displayName),
                          selected: isSelected,
                          onSelected: (_) => setDialogState(() => selectedPlatform = p),
                          selectedColor: AppColors.accentNeonCyan.withOpacity(0.3),
                          backgroundColor: AppColors.bgSecondary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
                  onPressed: () async {
                    final newName = nameController.text.trim().isNotEmpty ? nameController.text.trim() : (activePlat?.fighterId ?? 'SF6_Player');
                    final newSid = shortIdController.text.trim().isNotEmpty ? shortIdController.text.trim() : (activePlat?.shortId ?? '');
                    final newLp = int.tryParse(lpController.text.trim()) ?? (activePlat?.currentLp ?? 0);
                    final newMr = int.tryParse(mrController.text.trim()) ?? (activePlat?.currentMr ?? 0);

                    await authService.updateActiveProfile(
                      fighterId: newName,
                      shortId: newSid,
                      platformType: selectedPlatform,
                      lp: newLp,
                      mr: newMr,
                      mainCharId: selectedMainCharId,
                    );

                    await battleLogService.loadRecords(
                      shortId: newSid,
                      platform: selectedPlatform.code,
                      fighterId: newName,
                      lp: newLp,
                      mr: newMr,
                      mainCharId: selectedMainCharId,
                    );

                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已成功更新玩家档案：$newName (Short ID: $newSid)'), backgroundColor: AppColors.winGreen),
                      );
                    }
                  },
                  child: const Text('保存修改', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMultiCharacterLadder(BuildContext context, UserProfile? profile) {
    final rawUsages = profile?.characterUsages.isNotEmpty == true
        ? profile!.characterUsages
        : (authService.activePlatform?.characterUsages ?? []);
    final usages = rawUsages.where((u) => u.lp > 0 || u.mr > 0).toList();
    if (usages.isEmpty) return const SizedBox.shrink();

    final currentMainCharId = (authService.activePlatform?.mainCharId.isNotEmpty == true
            ? authService.activePlatform!.mainCharId
            : (profile?.mainCharacterId ?? ''))
        .toLowerCase();

    // Sort: Pinned main character first, then MR desc, LP desc, matches desc
    final sortedUsages = List<CharacterUsage>.from(usages);
    sortedUsages.sort((a, b) {
      final aIsMain = a.characterId.toLowerCase() == currentMainCharId;
      final bIsMain = b.characterId.toLowerCase() == currentMainCharId;
      if (aIsMain && !bIsMain) return -1;
      if (!aIsMain && bIsMain) return 1;
      if (b.mr != a.mr) return b.mr.compareTo(a.mr);
      if (b.lp != a.lp) return b.lp.compareTo(a.lp);
      return b.matches.compareTo(a.matches);
    });

    final displayUsages = _isLadderExpanded ? sortedUsages : sortedUsages.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.military_tech, color: AppColors.accentNeonCyan, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '各角色独立段位与积分榜',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '共 ${usages.length} 位已排位角色',
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...displayUsages.map((u) {
            final char = Sf6Characters.getById(u.characterId);
            final isCurrent = char.id.toLowerCase() == currentMainCharId;
            final activePlat = authService.activePlatform;

            // Fallback match stats from battle records if matches == 0
            int displayMatches = u.matches;
            double displayWinRate = u.winRate;
            if (displayMatches == 0 && battleLogService.records.isNotEmpty) {
              final cRecs = battleLogService.records.where((r) => r.playerCharacterId.toLowerCase() == char.id.toLowerCase()).toList();
              if (cRecs.isNotEmpty) {
                displayMatches = cRecs.length;
                displayWinRate = (cRecs.where((r) => r.isWin).length / displayMatches) * 100.0;
              }
            }

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.bgCard,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: [
                          CharacterAvatar(characterId: char.id, size: 28),
                          const SizedBox(width: 8),
                          const Text('设为当前主玩角色？', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                        ],
                      ),
                      content: Text(
                        '是否将主用角色切换为「${char.nameZh}」，并同步更新主页积分为 ${u.lp} LP (${u.mr > 0 ? "$u.mr MR" : "大师未定"})？',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消', style: TextStyle(color: AppColors.textSecondary))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('立即切换', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && activePlat != null) {
                    final fallbackLp = activePlat.currentLp ?? 0;
                    await authService.updateActiveProfile(
                      fighterId: activePlat.fighterId,
                      shortId: activePlat.shortId,
                      platformType: activePlat.platformType,
                      lp: u.lp > 0 ? u.lp : fallbackLp,
                      mr: u.mr,
                      mainCharId: char.id,
                    );
                    await battleLogService.loadRecords(
                      shortId: activePlat.shortId,
                      platform: activePlat.platformType.code,
                      fighterId: activePlat.fighterId,
                      lp: u.lp > 0 ? u.lp : fallbackLp,
                      mr: u.mr,
                      mainCharId: char.id,
                      characterUsages: usages,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已切换主用角色为：${char.nameZh} (${u.lp} LP)'), backgroundColor: AppColors.winGreen),
                      );
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.accentNeonCyan.withOpacity(0.08) : AppColors.bgSecondary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: isCurrent ? Border.all(color: AppColors.accentNeonCyan.withOpacity(0.4)) : Border.all(color: AppColors.borderSubtle.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      CharacterAvatar(characterId: char.id, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 第 1 行：角色名称与主玩标签
                            Row(
                              children: [
                                Text(
                                  char.nameZh,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentNeonCyan.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '当前主玩',
                                      style: TextStyle(
                                        color: AppColors.accentNeonCyan,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            // 第 2 行：段位徽章与积分
                            RankBadge(lp: u.lp, mr: u.mr, showPoints: true, scale: 0.85),
                            const SizedBox(height: 5),
                            // 第 3 行：对战局数与胜率
                            Text(
                              displayMatches > 0
                                  ? '$displayMatches 场对战  •  ${displayWinRate.toStringAsFixed(1)}% 胜率'
                                  : '已定级  •  ${u.mr > 0 ? "${u.mr} MR" : "${u.lp} LP"}',
                              style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          if (sortedUsages.length > 3) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                setState(() {
                  _isLadderExpanded = !_isLadderExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLadderExpanded ? '收起角色榜单' : '展开查看其余 ${sortedUsages.length - 3} 位角色',
                      style: const TextStyle(
                        color: AppColors.accentNeonCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isLadderExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.accentNeonCyan,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayTimeCard(PlayTimeModel pt) {
    final displayItems = _isPlayTimeExpanded ? pt.items : pt.topModes;
    final hasItems = pt.items.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.pie_chart_outline, color: AppColors.accentNeonCyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '最爱内容 / 游玩时长',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (pt.totalSeconds > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentNeonYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.accentNeonYellow.withOpacity(0.5)),
                  ),
                  child: Text(
                    '总时长: ${pt.formattedTotalDuration}',
                    style: const TextStyle(
                      color: AppColors.accentNeonYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (pt.total != '--' && pt.total.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentNeonYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.accentNeonYellow.withOpacity(0.5)),
                  ),
                  child: Text(
                    '总时长: ${pt.total}',
                    style: const TextStyle(
                      color: AppColors.accentNeonYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Text(
                    '下拉刷新同步官方时长',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          if (!pt.hasData) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.bgSecondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '暂无官方游玩时长记录，下拉即可同步 Buckler 档案',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ),
          ] else ...[
            // Proportional progress bar like Capcom Buckler web
            if (hasItems && pt.totalSeconds > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: pt.items.map((item) {
                      final flex = item.seconds > 0 ? item.seconds : 1;
                      return Expanded(
                        flex: flex,
                        child: Container(color: item.color),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Top modes list
              Column(
                children: displayItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: item.color, width: 1.5),
                          ),
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              color: item.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          item.formattedDuration,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.bgSecondary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '${item.percentage}%',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (pt.items.length > 3)
                InkWell(
                  onTap: () => setState(() => _isPlayTimeExpanded = !_isPlayTimeExpanded),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isPlayTimeExpanded ? '收起更多模式' : '查看全部 ${pt.items.length} 个模式',
                          style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 11),
                        ),
                        Icon(
                          _isPlayTimeExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 14,
                          color: AppColors.accentNeonCyan,
                        ),
                      ],
                    ),
                  ),
                ),
            ] else ...[
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.1,
                children: [
                  _buildPlayTimeTile('排位赛', pt.ranked, AppColors.accentNeonCyan),
                  _buildPlayTimeTile('比赛间对战', pt.customRoom, AppColors.accentNeonPink),
                  _buildPlayTimeTile('休闲赛', pt.casual, AppColors.winGreen),
                  _buildPlayTimeTile('格斗中心', pt.battleHub, AppColors.accentNeonYellow),
                  _buildPlayTimeTile('练习模式', pt.training, AppColors.textSecondary),
                  _buildPlayTimeTile('环球游历', pt.worldTour, AppColors.textTertiary),
                ],
              ),
            ],

            // Official match counts from battle_stats if available
            if (pt.rankedMatches > 0 || pt.customRoomMatches > 0 || pt.casualMatches > 0 || pt.battleHubMatches > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '官方各模式生涯对局数',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMatchCountItem('排位赛', pt.rankedMatches, AppColors.accentNeonCyan),
                        _buildMatchCountItem('比赛间', pt.customRoomMatches, AppColors.accentNeonPink),
                        _buildMatchCountItem('休闲赛', pt.casualMatches, AppColors.winGreen),
                        _buildMatchCountItem('格斗中心', pt.battleHubMatches, AppColors.accentNeonYellow),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMatchCountItem(String title, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            '$count 场',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayTimeTile(String title, String duration, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            duration,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountSwitchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final accounts = authService.accounts;
        final activeId = authService.activeAccount?.id;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141622),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentNeonCyan, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentNeonCyan.withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.switch_account, color: AppColors.accentNeonCyan, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '切换玩家账号',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final acc = accounts[idx];
                    final isActive = acc.id == activeId;
                    final plat = acc.activePlatform;
                    final charId = plat?.mainCharId.isNotEmpty == true ? plat!.mainCharId : 'luke';
                    final lp = plat?.currentLp ?? 0;
                    final mr = plat?.currentMr ?? 0;
                    final name = plat?.fighterId.isNotEmpty == true ? plat!.fighterId : acc.displayName;
                    final sid = plat?.shortId.isNotEmpty == true ? plat!.shortId : acc.capcomId;

                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        if (!isActive) {
                          await authService.switchAccount(acc.id);
                          final plat = authService.activePlatform;
                          if (plat != null) {
                            await battleLogService.loadRecords(
                              shortId: plat.shortId,
                              platform: plat.platformType.code,
                              fighterId: plat.fighterId,
                              lp: plat.currentLp,
                              mr: plat.currentMr,
                              mainCharId: plat.mainCharId,
                              clubName: plat.clubName,
                              characterUsages: plat.characterUsages,
                            );
                            await statsService?.loadStats(
                              shortId: plat.shortId,
                              platform: plat.platformType.code,
                            );
                          }
                          _fetchPlayTime();
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.accentNeonCyan.withOpacity(0.12) : AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive ? AppColors.accentNeonCyan : AppColors.borderSubtle,
                            width: isActive ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CharacterAvatar(characterId: charId, size: 36),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isActive ? AppColors.accentNeonCyan : AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (isActive) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentNeonCyan,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            '当前使用',
                                            style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Short ID: $sid  •  ${plat?.platformType.displayName ?? "Steam"}  •  ${mr > 0 ? "$mr MR" : "$lp LP"}',
                                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            if (isActive)
                              const Icon(Icons.check_circle, color: AppColors.accentNeonCyan, size: 20)
                            else
                              const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add, size: 16, color: AppColors.accentNeonYellow),
                      label: const Text('添加/绑定新账号', style: TextStyle(color: AppColors.accentNeonYellow, fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accentNeonYellow),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showQuickBindDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSharePosterModal(
    BuildContext context,
    UserProfile? profile,
    PlatformProfile? platform,
    Sf6Character? mainChar,
    int lp,
    int mr,
    Sf6Rank rank,
  ) {
    final fighterName = profile?.fighterId ?? platform?.fighterId ?? 'SF6 Challenger';
    final sid = profile?.shortId ?? platform?.shortId ?? '';
    final club = profile?.clubName ?? platform?.clubName ?? '';
    final winRate = profile?.winRate ?? 0.0;
    final total = profile?.totalMatches ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141622),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentNeonCyan, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentNeonCyan.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.flash_on, color: AppColors.accentNeonYellow, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'STREET FIGHTER 6 CARD',
                        style: TextStyle(color: AppColors.accentNeonYellow, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 12),
              Row(
                children: [
                  CharacterAvatar(characterId: profile?.mainCharacterId ?? 'terry', size: 70),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fighterName,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: $sid  •  俱乐部: [$club]',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        RankBadge(lp: lp, mr: mr),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('官方段位', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(rank.displayName, style: TextStyle(color: rank.color, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('当前积分', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('$lp LP', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('排位胜率', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('${winRate.toStringAsFixed(1)}%', style: const TextStyle(color: AppColors.winGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.copy, color: Colors.black),
                  label: const Text('复制文字战绩名片 (可直接发送到群聊)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
                  onPressed: () {
                    final text = '【街霸6 玩家战绩名片】\n'
                        '玩家昵称: $fighterName\n'
                        'Short ID: $sid\n'
                        '官方段位: ${rank.displayName} ($lp LP)\n'
                        '主玩角色: ${mainChar?.nameZh ?? "特瑞"}\n'
                        '所属战队: [$club]\n'
                        '综合胜率: ${winRate.toStringAsFixed(1)}% (共 $total 局)\n'
                        'Generated by SF6 Fighter Tracker';
                    Clipboard.setData(ClipboardData(text: text));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已复制战绩名片文本到剪贴板！可以直接粘贴分享到微信/QQ群。'), backgroundColor: AppColors.winGreen),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


