import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/core/theme/app_theme_colors.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';

class RankedScoreChartCard extends StatefulWidget {
  final BattleLogService battleLogService;
  final AuthService? authService;

  const RankedScoreChartCard({
    super.key,
    required this.battleLogService,
    this.authService,
  });

  @override
  State<RankedScoreChartCard> createState() => _RankedScoreChartCardState();
}

class _RankedScoreChartCardState extends State<RankedScoreChartCard> {
  int _selectedHorizon = 20; // 20: 近20场, 100: 近100场, 0: 全部
  String? _selectedCharacterId;
  String? _lastMainChar;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.battleLogService,
        if (widget.authService != null) widget.authService!,
      ]),
      builder: (context, _) {
        final allRecords = widget.battleLogService.records;
        final rankedRecords = allRecords.where((r) => r.battleType == BattleType.ranked).toList();

        // Extract characters with ranked matches
        final availableCharIds = <String>{};
        for (final r in rankedRecords) {
          if (r.playerCharacterId.isNotEmpty) {
            availableCharIds.add(r.playerCharacterId.toLowerCase());
          }
        }

        // Adaptive default character resolution
        final activeChar = widget.authService?.activePlatform?.mainCharId.toLowerCase();
        final profileChar = widget.battleLogService.userProfile?.mainCharacterId.toLowerCase();
        final mainChar = (activeChar != null && activeChar.isNotEmpty)
            ? activeChar
            : (profileChar != null && profileChar.isNotEmpty ? profileChar : null);

        if (_lastMainChar != mainChar) {
          _lastMainChar = mainChar;
          if (mainChar != null) {
            _selectedCharacterId = mainChar;
          }
        }

        if (_selectedCharacterId == null) {
          _selectedCharacterId = mainChar ?? (availableCharIds.isNotEmpty ? availableCharIds.first : 'ryu');
        }

        final allCharIdsList = List<String>.from(availableCharIds);
        if (_selectedCharacterId != null && !allCharIdsList.contains(_selectedCharacterId)) {
          allCharIdsList.insert(0, _selectedCharacterId!);
        }

        // Filter records for selected character
        final charRanked = rankedRecords
            .where((r) => r.playerCharacterId.toLowerCase() == _selectedCharacterId)
            .toList();
        charRanked.sort((a, b) => a.playedAt.compareTo(b.playedAt));

        // Slice horizon
        List<BattleRecord> sliced;
        if (_selectedHorizon == 20) {
          sliced = charRanked.length > 20 ? charRanked.sublist(charRanked.length - 20) : charRanked;
        } else if (_selectedHorizon == 100) {
          sliced = charRanked.length > 100 ? charRanked.sublist(charRanked.length - 100) : charRanked;
        } else {
          sliced = charRanked;
        }

        final colors = context.themeColors;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: colors.cardDecoration(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.show_chart, color: colors.accentPrimary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '排位分数走势',
                          style: colors.titleStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _buildHorizonSelector(colors),
                  ],
                ),
              ),

              // Character Capsule Selector (Horizontal)
              if (allCharIdsList.length > 1) ...[
                _buildCharacterSelector(allCharIdsList, charRanked, colors),
                const SizedBox(height: 8),
              ],

              // Chart Area or Empty Protection Placeholder
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 14),
                child: sliced.length < 2
                    ? _buildEmptyPlaceholder(colors)
                    : _buildChart(sliced, colors),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorizonSelector(AppThemeColors colors) {
    String label;
    if (_selectedHorizon == 20) {
      label = '近20场';
    } else if (_selectedHorizon == 100) {
      label = '近100场';
    } else {
      label = '全部';
    }

    return PopupMenuButton<int>(
      initialValue: _selectedHorizon,
      tooltip: '切换对局范围',
      onSelected: (val) {
        setState(() {
          _selectedHorizon = val;
        });
      },
      color: colors.bgCardSolid,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colors.borderSubtle),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 20,
          child: Text('近20场', style: TextStyle(color: colors.textPrimary, fontSize: 12)),
        ),
        PopupMenuItem<int>(
          value: 100,
          child: Text('近100场', style: TextStyle(color: colors.textPrimary, fontSize: 12)),
        ),
        PopupMenuItem<int>(
          value: 0,
          child: Text('全部', style: TextStyle(color: colors.textPrimary, fontSize: 12)),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label ▾',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getChartRankColor(Sf6Rank rank) {
    switch (rank.tier) {
      case RankTier.legend:
        return const Color(0xFFC62828);
      case RankTier.master:
        return const Color(0xFFC67C00);
      case RankTier.diamond:
        return const Color(0xFF0277BD);
      case RankTier.platinum:
        return const Color(0xFF00838F);
      case RankTier.gold:
        return const Color(0xFFB78103);
      case RankTier.silver:
        return const Color(0xFF455A64);
      case RankTier.bronze:
        return const Color(0xFF6D4C41);
      case RankTier.iron:
        return const Color(0xFF4E342E);
      case RankTier.rookie:
        return const Color(0xFF616161);
    }
  }

  Widget _buildCharacterSelector(List<String> characterIds, List<BattleRecord> currentRecords, AppThemeColors colors) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: characterIds.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final charId = characterIds[index];
          final isSelected = charId == _selectedCharacterId;
          final char = Sf6Characters.getById(charId);

          return InkWell(
            onTap: () => setState(() => _selectedCharacterId = charId),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? colors.accentPrimary.withOpacity(0.18) : colors.bgSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? colors.accentPrimary : colors.borderSubtle,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CharacterAvatar(characterId: charId, size: 20, showBorder: false),
                  const SizedBox(width: 6),
                  Text(
                    char.nameZh,
                    style: TextStyle(
                      fontFamily: colors.titleFontFamily,
                      color: isSelected ? colors.accentPrimary : colors.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyPlaceholder(AppThemeColors colors) {
    final char = Sf6Characters.getById(_selectedCharacterId ?? 'ryu');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.bgSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CharacterAvatar(
            characterId: _selectedCharacterId ?? 'ryu',
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            '【${char.nameZh}】暂无排位赛记录',
            textAlign: TextAlign.center,
            style: colors.titleStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '请在《街霸6》中进行 2 场以上排位赛，同步后即可生成走势图',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<BattleRecord> records, AppThemeColors colors) {
    final latestRecord = records.last;
    final isMaster = (latestRecord.playerCurrentMr ?? 0) > 0;
    final unit = isMaster ? 'MR' : 'LP';

    final spots = <FlSpot>[];
    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      final double score = isMaster
          ? ((r.playerCurrentMr != null && r.playerCurrentMr! > 0) ? r.playerCurrentMr!.toDouble() : 1500.0)
          : (r.playerCurrentLp?.toDouble() ?? 0.0);
      spots.add(FlSpot(i.toDouble(), score));
    }

    final minScore = spots.map((s) => s.y).reduce(min);
    final maxScore = spots.map((s) => s.y).reduce(max);

    double minY;
    double maxY;
    if (isMaster) {
      minY = (minScore < 1500 ? minScore : 1500) - 25;
      maxY = (maxScore > 1500 ? maxScore : 1500) + 25;
    } else {
      final span = maxScore - minScore;
      final margin = (span * 0.1).clamp(50.0, 500.0);
      minY = (minScore - margin).clamp(0.0, double.infinity);
      maxY = maxScore + margin;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Extrema Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isMaster ? AppColors.rankMaster.withOpacity(0.15) : colors.accentPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isMaster ? AppColors.rankMaster.withOpacity(0.4) : colors.accentPrimary.withOpacity(0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                isMaster ? '大师排位 (Master League)' : '积分天梯 (LP League)',
                style: TextStyle(
                  color: isMaster ? AppColors.rankMaster : colors.accentPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  'MAX: ${maxScore.toInt()} $unit',
                  style: TextStyle(color: colors.accentTertiary, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  'MIN: ${minScore.toInt()} $unit',
                  style: TextStyle(color: colors.accentError, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Line Chart
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (records.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: isMaster ? 50 : max(100.0, (maxY - minY) / 4),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colors.borderSubtle.withOpacity(colors.isClaudeWarm ? 0.6 : 0.3),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: colors.borderSubtle.withOpacity(colors.isClaudeWarm ? 0.8 : 0.5)),
                  left: BorderSide(color: colors.borderSubtle.withOpacity(colors.isClaudeWarm ? 0.8 : 0.5)),
                ),
              ),
              extraLinesData: ExtraLinesData(
                extraLinesOnTop: false,
                horizontalLines: isMaster
                    ? [
                        HorizontalLine(
                          y: 1500,
                          color: AppColors.textTertiary.withOpacity(0.6),
                          strokeWidth: 1.5,
                          dashArray: [5, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 6, bottom: 2),
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            labelResolver: (_) => '1500 基准',
                          ),
                        ),
                      ]
                    : [],
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) return const SizedBox.shrink();
                      final valInt = value.toInt();
                      final rank = Sf6Rank.fromLpOrMr(isMaster ? 25000 : valInt, mr: isMaster ? valInt : null);
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '$valInt',
                          style: TextStyle(color: rank.color, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= records.length) return const SizedBox.shrink();
                      if (index == 0 || index == records.length - 1 || index == (records.length / 2).floor()) {
                        final rec = records[index];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            DateFormat('MM/dd').format(rec.playedAt),
                            style: const TextStyle(color: AppColors.textTertiary, fontSize: 9),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: colors.bgCardSolid.withOpacity(0.95),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final idx = spot.spotIndex;
                      if (idx < 0 || idx >= records.length) return null;
                      final rec = records[idx];
                      final change = isMaster ? rec.playerMrChange : rec.playerLpChange;
                      final changeStr = change > 0 ? '+$change' : '$change';
                      final changeUnit = isMaster ? 'MR' : 'LP';
                      final oppChar = Sf6Characters.getById(rec.opponentCharacterId);
                      final winStr = rec.isWin ? '胜局 (WIN)' : '败局 (LOSE)';
                      final changeText = change != 0 ? ' $changeStr $changeUnit' : '';
                      final scoreText = '${spot.y.toInt()} $changeUnit';
                      final dateText = DateFormat('MM-dd HH:mm').format(rec.playedAt);

                      return LineTooltipItem(
                        '$winStr$changeText',
                        TextStyle(
                          color: rec.isWin ? AppColors.winGreen : AppColors.loseRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        children: [
                          TextSpan(
                            text: '\n对手: ${oppChar.nameZh}\n结算: $scoreText | $dateText',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.2,
                  preventCurveOverShooting: true,
                  gradient: LinearGradient(
                    colors: colors.isClaudeWarm
                        ? const [Color(0xFFD97757), Color(0xFFD97706)]
                        : const [AppColors.accentNeonCyan, AppColors.brandPurple],
                  ),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: spots.length <= 25,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 3.5,
                      color: colors.accentPrimary,
                      strokeWidth: 1.5,
                      strokeColor: colors.bgPrimary,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        colors.accentPrimary.withOpacity(0.32),
                        colors.accentPrimary.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
