import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/theme/app_theme_colors.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/matchup_stat.dart';
import 'package:sf6_tracker/core/network/capcom_sync_engine.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/mr_trend_chart.dart';
import 'package:sf6_tracker/ui/widgets/win_rate_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  final AuthService authService;
  final StatsService statsService;
  final BattleLogService? battleLogService;
  final SocialService? socialService;

  const AnalyticsScreen({
    super.key,
    required this.authService,
    required this.statsService,
    this.battleLogService,
    this.socialService,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isSyncing = false;
  bool _isGridExpanded = false;
  String _charSortMode = 'matches'; // 'matches' or 'default'

  @override
  void initState() {
    super.initState();
    _loadInitialStats();
  }

  void _loadInitialStats() {
    final platform = widget.authService.activePlatform;
    if (platform != null) {
      widget.statsService.loadStats(
        shortId: platform.shortId,
        platform: platform.platformType.code,
      );
    }
  }

  Future<void> _handleRefresh() async {
    if (_isSyncing) return;
    final platform = widget.authService.activePlatform;
    if (platform == null) {
      _loadInitialStats();
      return;
    }

    if (widget.battleLogService != null) {
      setState(() => _isSyncing = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在从卡普空官方同步最新对战数据...'),
          duration: Duration(seconds: 2),
        ),
      );

      final res = await CapcomSyncEngine.performFullSync(
        authService: widget.authService,
        battleLogService: widget.battleLogService!,
        statsService: widget.statsService,
        socialService: widget.socialService,
      );

      if (!mounted) return;
      setState(() => _isSyncing = false);

      if (res.needLogin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('卡普空官方登录会话已过期，请重新登录'),
            backgroundColor: AppColors.loseRed,
          ),
        );
      } else if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.recordsUpdated > 0 ? '同步完成，已更新 ${res.recordsUpdated} 局战绩并重新分析' : '同步完成，当前已是最新战绩分析'),
            backgroundColor: AppColors.winGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message.isNotEmpty ? res.message : '网络同步未完成，已加载本地分析数据'),
            backgroundColor: AppColors.accentNeonYellow,
          ),
        );
      }
    } else {
      _loadInitialStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return ListenableBuilder(
      listenable: widget.statsService,
      builder: (context, _) {
        final platform = widget.authService.activePlatform;
        final stats = widget.statsService.matchupStats;
        final ratingHistory = widget.statsService.ratingHistory;
        final isLoading = widget.statsService.isLoading || _isSyncing;
        final selectedMyChar = widget.statsService.selectedMyCharacterId;

        final mrPoints = ratingHistory
            .where((r) => r['playerCurrentMr'] != null && (r['playerCurrentMr'] as int) > 0)
            .map((r) => r['playerCurrentMr'] as int)
            .toList();

        return Scaffold(
          backgroundColor: colors.isClaudeWarm ? Colors.transparent : null,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: colors.textPrimary),
            title: Text(
              '深度数据与克制分析',
              style: colors.titleStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: _isSyncing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.accentPrimary),
                      )
                    : Icon(Icons.refresh, color: colors.accentPrimary),
                onPressed: _handleRefresh,
                tooltip: '从官方拉取最新对局并重新分析',
              ),
            ],
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator(color: colors.accentPrimary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. My Character Selector Banner
                      _buildMyCharacterSelector(platform, selectedMyChar, colors),
                      const SizedBox(height: 6),

                      // 1.1 Battle Mode Filter Bar
                      _buildBattleTypeFilterBar(platform, colors),
                      const SizedBox(height: 6),

                      // 1.2 Data Source Switcher
                      if (widget.statsService.selectedBattleType == null) ...[
                        _buildDataSourceSelector(platform, colors),
                        const SizedBox(height: 8),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          child: Text(
                            '当前模式分析来源于本地实战记录 (${stats.length} 个角色对策)',
                            style: TextStyle(color: colors.textSecondary, fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 2. Summary stats for selected character
                      _buildSummaryStatsCard(colors),
                      const SizedBox(height: 14),

                      // 3. MR Rating Trend Chart
                      if (mrPoints.length >= 2) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MrTrendChart(mrPoints: mrPoints),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 4. Best & Worst Matchup Highlights
                      if (stats.isNotEmpty) ...[
                        _buildHighlights(stats, colors),
                        const SizedBox(height: 16),
                      ],

                      // 5. Matchup Win Rate Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedMyChar == 'all'
                                  ? '全角色面对各对手胜率表'
                                  : '使用 ${Sf6Characters.getById(selectedMyChar).nameZh} 面对各对手胜率',
                              style: colors.titleStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '共 ${stats.length} 名对手',
                              style: TextStyle(color: colors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (stats.isEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          padding: const EdgeInsets.all(24),
                          decoration: colors.cardDecoration(borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.bar_chart, color: colors.textTertiary, size: 40),
                                const SizedBox(height: 10),
                                Text(
                                  '暂无该角色的实战对局记录',
                                  style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '在官方网页登录同步或手动添加战绩后，将自动生成对战克制与胜率分析',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // 6. Matchup Rows
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: stats.length,
                        itemBuilder: (context, index) {
                          final item = stats[index];
                          return _buildMatchupItem(item, colors);
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMyCharacterSelector(dynamic platform, String selectedMyChar, AppThemeColors colors) {
    final counts = widget.statsService.myCharacterCounts;

    final sortedChars = List<Sf6Character>.from(Sf6Characters.all);
    if (_charSortMode == 'matches') {
      sortedChars.sort((a, b) {
        final countA = counts[a.id] ?? 0;
        final countB = counts[b.id] ?? 0;
        if (countA != countB) return countB.compareTo(countA);
        return a.nameZh.compareTo(b.nameZh);
      });
    }

    return Container(
      color: colors.isClaudeWarm ? colors.bgSecondary.withOpacity(0.5) : AppColors.bgSecondary,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.person_pin, size: 16, color: colors.accentPrimary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '我方角色',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _charSortMode = _charSortMode == 'matches' ? 'default' : 'matches';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.bgCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _charSortMode == 'matches' ? Icons.sort : Icons.sort_by_alpha,
                          size: 12,
                          color: colors.accentSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _charSortMode == 'matches' ? '按场次' : '默认序',
                          style: TextStyle(color: colors.accentSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => setState(() => _isGridExpanded = !_isGridExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _isGridExpanded ? colors.accentPrimary.withOpacity(0.2) : colors.bgCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _isGridExpanded ? colors.accentPrimary : colors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isGridExpanded ? Icons.view_carousel : Icons.grid_view, size: 12, color: colors.accentPrimary),
                        const SizedBox(width: 3),
                        Text(
                          _isGridExpanded ? '收起' : '展开',
                          style: TextStyle(color: colors.accentPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (_isGridExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ChoiceChip(
                    label: const Text('全部角色综合'),
                    selected: selectedMyChar == 'all',
                    onSelected: (_) {
                      if (platform != null) {
                        widget.statsService.selectMyCharacter('all', shortId: platform.shortId, platform: platform.platformType.code);
                      }
                    },
                    selectedColor: colors.accentPrimary.withOpacity(0.18),
                    backgroundColor: colors.bgCard,
                    side: BorderSide(
                      color: selectedMyChar == 'all' ? colors.accentPrimary : colors.borderSubtle,
                    ),
                    labelStyle: TextStyle(
                      color: selectedMyChar == 'all' ? colors.accentPrimary : colors.textSecondary,
                      fontWeight: selectedMyChar == 'all' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                  ...sortedChars.map((c) {
                    final isSelected = selectedMyChar == c.id;
                    final matchCount = counts[c.id] ?? 0;
                    return ChoiceChip(
                      avatar: CharacterAvatar(characterId: c.id, size: 20, showBorder: false),
                      label: Text(
                        c.nameZh + (matchCount > 0 ? ' ($matchCount局)' : ''),
                        style: TextStyle(
                          color: isSelected ? colors.accentPrimary : (matchCount > 0 ? colors.textPrimary : colors.textTertiary),
                          fontWeight: isSelected || matchCount > 0 ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        if (platform != null) {
                          widget.statsService.selectMyCharacter(c.id, shortId: platform.shortId, platform: platform.platformType.code);
                        }
                      },
                      selectedColor: colors.accentPrimary.withOpacity(0.18),
                      backgroundColor: colors.bgCard,
                      side: BorderSide(
                        color: isSelected ? colors.accentPrimary : colors.borderSubtle,
                      ),
                    );
                  }),
                ],
              ),
            )
          else
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('全部角色综合'),
                      selected: selectedMyChar == 'all',
                      onSelected: (_) {
                        if (platform != null) {
                          widget.statsService.selectMyCharacter('all', shortId: platform.shortId, platform: platform.platformType.code);
                        }
                      },
                      selectedColor: colors.accentPrimary.withOpacity(0.18),
                      backgroundColor: colors.bgCard,
                      side: BorderSide(
                        color: selectedMyChar == 'all' ? colors.accentPrimary : colors.borderSubtle,
                      ),
                      labelStyle: TextStyle(
                        color: selectedMyChar == 'all' ? colors.accentPrimary : colors.textSecondary,
                        fontWeight: selectedMyChar == 'all' ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...sortedChars.map((c) {
                    final isSelected = selectedMyChar == c.id;
                    final matchCount = counts[c.id] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: CharacterAvatar(characterId: c.id, size: 24, showBorder: false),
                        label: Text(c.nameZh + (matchCount > 0 ? ' ($matchCount)' : '')),
                        selected: isSelected,
                        onSelected: (_) {
                          if (platform != null) {
                            widget.statsService.selectMyCharacter(c.id, shortId: platform.shortId, platform: platform.platformType.code);
                          }
                        },
                        selectedColor: colors.accentPrimary.withOpacity(0.18),
                        backgroundColor: colors.bgCard,
                        side: BorderSide(
                          color: isSelected ? colors.accentPrimary : colors.borderSubtle,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? colors.accentPrimary : (matchCount > 0 ? colors.textPrimary : colors.textSecondary),
                          fontWeight: isSelected || matchCount > 0 ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatsCard(AppThemeColors colors) {
    final total = widget.statsService.totalMatches;
    final wins = widget.statsService.totalWins;
    final winRate = widget.statsService.overallWinRate;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: colors.cardDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(child: _buildMiniStat('筛选场次', '$total 局', colors.textPrimary, colors)),
          Expanded(child: _buildMiniStat('胜 / 负', '$wins 胜 / ${total - wins} 负', colors.accentPrimary, colors)),
          Expanded(
            child: _buildMiniStat(
              '综合胜率',
              '${winRate.toStringAsFixed(1)}%',
              winRate >= 50.0 ? colors.accentTertiary : colors.accentError,
              colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valColor, AppThemeColors colors) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildHighlights(List<MatchupStat> stats, AppThemeColors colors) {
    final best = widget.statsService.bestMatchups;
    final worst = widget.statsService.worstMatchups;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildHighlightCard(
              title: '优势对局 (Best Matchup)',
              items: best,
              color: colors.accentTertiary,
              icon: Icons.trending_up,
              colors: colors,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildHighlightCard(
              title: '苦战对局 (Worst Matchup)',
              items: worst,
              color: colors.accentError,
              icon: Icons.trending_down,
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required String title,
    required List<MatchupStat> items,
    required Color color,
    required IconData icon,
    required AppThemeColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: colors.cardDecoration(borderRadius: BorderRadius.circular(12)).copyWith(
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text('暂无足够场次数据', style: TextStyle(color: colors.textTertiary, fontSize: 11))
          else
            ...items.map((stat) {
              final char = Sf6Characters.getById(stat.characterId);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    CharacterAvatar(characterId: char.id, size: 24, showBorder: false),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        char.nameZh,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: colors.titleFontFamily,
                        ),
                      ),
                    ),
                    Text(
                      '${stat.winRate.toStringAsFixed(0)}% (${stat.totalMatches}场)',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMatchupItem(MatchupStat item, AppThemeColors colors) {
    final char = Sf6Characters.getById(item.characterId);
    final winRateColor = item.winRate >= 50.0 ? colors.accentTertiary : colors.accentError;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: colors.cardDecoration(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CharacterAvatar(characterId: char.id, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${char.nameZh} (${char.nameEn})',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: colors.titleFontFamily,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${item.winRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: winRateColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '总对局: ${item.totalMatches}场  (${item.wins}胜 / ${item.losses}负)',
                      style: TextStyle(color: colors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          WinRateBar(
            winRate: item.winRate,
            wins: item.wins,
            total: item.totalMatches,
            height: 6,
          ),
          if (item.recentForm.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text('近 5 场走势: ', style: TextStyle(color: colors.textSecondary, fontSize: 10)),
                ...item.recentForm.map((isWin) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isWin ? colors.accentTertiary : colors.accentError,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'W',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                    ),
                  );
                }),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    char.archetype,
                    style: TextStyle(color: colors.accentPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBattleTypeFilterBar(dynamic platform, AppThemeColors colors) {
    final currentType = widget.statsService.selectedBattleType;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTypeFilterChip('全部模式', null, currentType == null, platform, colors),
          const SizedBox(width: 8),
          _buildTypeFilterChip('排位赛', BattleType.ranked, currentType == BattleType.ranked, platform, colors),
          const SizedBox(width: 8),
          _buildTypeFilterChip('休闲赛', BattleType.casual, currentType == BattleType.casual, platform, colors),
          const SizedBox(width: 8),
          _buildTypeFilterChip('比赛间对战', BattleType.customRoom, currentType == BattleType.customRoom, platform, colors),
          const SizedBox(width: 8),
          _buildTypeFilterChip('格斗中心对战', BattleType.battleHub, currentType == BattleType.battleHub, platform, colors),
        ],
      ),
    );
  }

  Widget _buildTypeFilterChip(String label, BattleType? type, bool isSelected, dynamic platform, AppThemeColors colors) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        if (platform != null) {
          widget.statsService.selectBattleType(
            type,
            shortId: platform.shortId,
            platform: platform.platformType.code,
          );
        }
      },
      selectedColor: colors.accentPrimary.withOpacity(0.18),
      backgroundColor: colors.bgCard,
      side: BorderSide(
        color: isSelected ? colors.accentPrimary : colors.borderSubtle,
      ),
      labelStyle: TextStyle(
        color: isSelected ? colors.accentPrimary : colors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
    );
  }

  Widget _buildDataSourceSelector(dynamic platform, AppThemeColors colors) {
    final useOfficial = widget.statsService.useOfficialStats;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: colors.cardDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (platform != null) {
                  widget.statsService.setStatsSource(true, shortId: platform.shortId, platform: platform.platformType.code);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: useOfficial ? colors.accentPrimary.withOpacity(0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: useOfficial ? Border.all(color: colors.accentPrimary) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public, size: 14, color: useOfficial ? colors.accentPrimary : colors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '全部对局 (全生涯)',
                      style: TextStyle(
                        color: useOfficial ? colors.accentPrimary : colors.textSecondary,
                        fontWeight: useOfficial ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (platform != null) {
                  widget.statsService.setStatsSource(false, shortId: platform.shortId, platform: platform.platformType.code);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: !useOfficial ? colors.accentSecondary.withOpacity(0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: !useOfficial ? Border.all(color: colors.accentSecondary) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 14, color: !useOfficial ? colors.accentSecondary : colors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '近100场对局',
                      style: TextStyle(
                        color: !useOfficial ? colors.accentSecondary : colors.textSecondary,
                        fontWeight: !useOfficial ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
