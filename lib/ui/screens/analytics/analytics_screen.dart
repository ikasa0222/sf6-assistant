import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
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
          appBar: AppBar(
            title: const Text('深度数据与克制分析', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: _isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentNeonCyan),
                      )
                    : const Icon(Icons.refresh, color: AppColors.accentNeonCyan),
                onPressed: _handleRefresh,
                tooltip: '从官方拉取最新对局并重新分析',
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentNeonCyan))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. My Character Selector Banner
                      _buildMyCharacterSelector(platform, selectedMyChar),
                      const SizedBox(height: 8),

                      // 1.1 Data Source Switcher (Official Career Stats vs Local Replays)
                      _buildDataSourceSelector(platform),
                      const SizedBox(height: 8),

                      // 1.2 Battle Type Filter Bar (shown only in local replays mode)
                      if (!widget.statsService.useOfficialStats) ...[
                        _buildBattleTypeFilterBar(platform),
                        const SizedBox(height: 12),
                      ],

                      // 2. Summary stats for selected character
                      _buildSummaryStatsCard(),
                      const SizedBox(height: 14),

                      // 3. MR Rating Trend Chart (only if master rated matches exist)
                      if (mrPoints.length >= 2) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MrTrendChart(mrPoints: mrPoints),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 4. Best & Worst Matchup Highlights
                      if (stats.isNotEmpty) ...[
                        _buildHighlights(stats),
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
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '共 ${stats.length} 名对手',
                              style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (stats.isEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(Icons.bar_chart, color: AppColors.textTertiary, size: 40),
                                SizedBox(height: 10),
                                Text('暂无该角色的实战对局记录', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('在官方网页登录同步或手动添加战绩后，将自动生成对战克制与胜率分析', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
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
                          return _buildMatchupItem(item);
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  bool _isGridExpanded = false;
  String _charSortMode = 'matches'; // 'matches' or 'default'

  Widget _buildMyCharacterSelector(dynamic platform, String selectedMyChar) {
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
      color: AppColors.bgSecondary,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.person_pin, size: 16, color: AppColors.accentNeonCyan),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    '我方角色',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
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
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _charSortMode == 'matches' ? Icons.sort : Icons.sort_by_alpha,
                          size: 12,
                          color: AppColors.accentNeonYellow,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _charSortMode == 'matches' ? '按场次' : '默认序',
                          style: const TextStyle(color: AppColors.accentNeonYellow, fontSize: 10, fontWeight: FontWeight.bold),
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
                      color: _isGridExpanded ? AppColors.accentNeonCyan.withOpacity(0.2) : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _isGridExpanded ? AppColors.accentNeonCyan : AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isGridExpanded ? Icons.view_carousel : Icons.grid_view, size: 12, color: AppColors.accentNeonCyan),
                        const SizedBox(width: 3),
                        Text(
                          _isGridExpanded ? '收起' : '展开',
                          style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 10, fontWeight: FontWeight.bold),
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
                    selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                    backgroundColor: AppColors.bgCard,
                    labelStyle: TextStyle(
                      color: selectedMyChar == 'all' ? AppColors.accentNeonCyan : AppColors.textSecondary,
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
                          color: isSelected ? AppColors.accentNeonCyan : (matchCount > 0 ? AppColors.textPrimary : AppColors.textTertiary),
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
                      selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                      backgroundColor: AppColors.bgCard,
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
                      selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                      backgroundColor: AppColors.bgCard,
                      labelStyle: TextStyle(
                        color: selectedMyChar == 'all' ? AppColors.accentNeonCyan : AppColors.textSecondary,
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
                        selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                        backgroundColor: AppColors.bgCard,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.accentNeonCyan : (matchCount > 0 ? AppColors.textPrimary : AppColors.textSecondary),
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

  Widget _buildSummaryStatsCard() {
    final total = widget.statsService.totalMatches;
    final wins = widget.statsService.totalWins;
    final winRate = widget.statsService.overallWinRate;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(child: _buildMiniStat('筛选场次', '$total 局', AppColors.textPrimary)),
          Expanded(child: _buildMiniStat('胜 / 负', '$wins 胜 / ${total - wins} 负', AppColors.accentNeonCyan)),
          Expanded(child: _buildMiniStat('综合胜率', '${winRate.toStringAsFixed(1)}%', winRate >= 50.0 ? AppColors.winGreen : AppColors.loseRed)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildHighlights(List<MatchupStat> stats) {
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
              color: AppColors.winGreen,
              icon: Icons.trending_up,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildHighlightCard(
              title: '苦战对局 (Worst Matchup)',
              items: worst,
              color: AppColors.loseRed,
              icon: Icons.trending_down,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
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
            const Text('暂无足够场次数据', style: TextStyle(color: AppColors.textTertiary, fontSize: 11))
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
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _buildMatchupItem(MatchupStat item) {
    final char = Sf6Characters.getById(item.characterId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
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
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${item.winRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: item.winRate >= 50.0 ? AppColors.winGreen : AppColors.loseRed,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '总对局: ${item.totalMatches}场  (${item.wins}胜 / ${item.losses}负)',
                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
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
                const Text('近 5 场走势: ', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                ...item.recentForm.map((isWin) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isWin ? AppColors.winGreen : AppColors.loseRed,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      isWin ? 'W' : 'L',
                      style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                    ),
                  );
                }),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    char.archetype,
                    style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBattleTypeFilterBar(dynamic platform) {
    final currentType = widget.statsService.selectedBattleType;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTypeFilterChip('全部模式', null, currentType == null, platform),
          const SizedBox(width: 8),
          _buildTypeFilterChip('排位赛', BattleType.ranked, currentType == BattleType.ranked, platform),
          const SizedBox(width: 8),
          _buildTypeFilterChip('休闲匹配', BattleType.casual, currentType == BattleType.casual, platform),
          const SizedBox(width: 8),
          _buildTypeFilterChip('自定义房间', BattleType.customRoom, currentType == BattleType.customRoom, platform),
          const SizedBox(width: 8),
          _buildTypeFilterChip('格斗中心', BattleType.battleHub, currentType == BattleType.battleHub, platform),
        ],
      ),
    );
  }

  Widget _buildTypeFilterChip(String label, BattleType? type, bool isSelected, dynamic platform) {
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
      selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
      backgroundColor: AppColors.bgSecondary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
    );
  }

  Widget _buildDataSourceSelector(dynamic platform) {
    if (!widget.statsService.hasOfficialStats) return const SizedBox.shrink();
    final useOfficial = widget.statsService.useOfficialStats;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
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
                  color: useOfficial ? AppColors.accentNeonCyan.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: useOfficial ? Border.all(color: AppColors.accentNeonCyan) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public, size: 14, color: useOfficial ? AppColors.accentNeonCyan : AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '官网全生涯对策',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: useOfficial ? AppColors.accentNeonCyan : AppColors.textTertiary,
                          fontWeight: useOfficial ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
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
                  color: !useOfficial ? AppColors.accentNeonYellow.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: !useOfficial ? Border.all(color: AppColors.accentNeonYellow) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 14, color: !useOfficial ? AppColors.accentNeonYellow : AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '本地实战 (近100场)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: !useOfficial ? AppColors.accentNeonYellow : AppColors.textTertiary,
                          fontWeight: !useOfficial ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
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
