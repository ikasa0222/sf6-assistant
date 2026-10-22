import 'package:sf6_tracker/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/player_note.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/network/capcom_sync_engine.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/notes_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/battle_card_item.dart';
import 'package:sf6_tracker/ui/widgets/share_battle_card.dart';
import 'package:sf6_tracker/ui/widgets/share_battle_dialog.dart';

class BattleLogScreen extends StatefulWidget {
  final AuthService authService;
  final BattleLogService battleLogService;
  final NotesService notesService;
  final StatsService? statsService;
  final SocialService? socialService;

  const BattleLogScreen({
    super.key,
    required this.authService,
    required this.battleLogService,
    required this.notesService,
    this.statsService,
    this.socialService,
  });

  @override
  State<BattleLogScreen> createState() => _BattleLogScreenState();
}

class _BattleLogScreenState extends State<BattleLogScreen> {
  BattleType? _selectedFilter;
  String _selectedCharacterId = 'all';
  bool _isCharGridExpanded = false;
  String _charSortMode = 'matches'; // 'matches' or 'default'
  bool _isSyncing = false;

  Future<void> _performOnlineSync() async {
    if (_isSyncing || widget.battleLogService.isBackgroundSyncing) return;
    final activePlatform = widget.authService.activePlatform;
    if (activePlatform == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录或绑定 Capcom ID')),
      );
      return;
    }

    setState(() => _isSyncing = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在从卡普空官方同步最新战绩...'),
        duration: Duration(seconds: 2),
      ),
    );

    final res = await CapcomSyncEngine.performFullSync(
      authService: widget.authService,
      battleLogService: widget.battleLogService,
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
          content: Text(res.recordsUpdated > 0 ? '同步完成，已更新 ${res.recordsUpdated} 局最新对战' : '同步完成，当前已是最新战绩'),
          backgroundColor: AppColors.winGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message.isNotEmpty ? res.message : '网络同步未完成，已展示本地缓存'),
          backgroundColor: AppColors.accentNeonYellow,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.authService, widget.battleLogService]),
      builder: (context, _) {
        final records = widget.battleLogService.records;
        final isLoading = widget.battleLogService.isLoading || _isSyncing;

        // 1. Mode Filter
        final modeFiltered = _selectedFilter == null
            ? records
            : records.where((r) => r.battleType == _selectedFilter).toList();

        // Count matches per character in current mode filter using normalized character ID
        final charCounts = <String, int>{};
        for (final r in modeFiltered) {
          final stdId = Sf6Characters.getById(r.playerCharacterId).id;
          charCounts[stdId] = (charCounts[stdId] ?? 0) + 1;
        }

        // 2. Character Filter using normalized character ID
        final filteredRecords = _selectedCharacterId == 'all'
            ? modeFiltered
            : modeFiltered.where((r) {
                final stdId = Sf6Characters.getById(r.playerCharacterId).id;
                return stdId == _selectedCharacterId;
              }).toList();

        final colors = context.themeColors;

        return Scaffold(
          backgroundColor: colors.isClaudeWarm ? Colors.transparent : null,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('无限对战战绩库', style: colors.titleStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            iconTheme: IconThemeData(color: colors.textPrimary),
            actions: [
              IconButton(
                icon: _isSyncing || widget.battleLogService.isBackgroundSyncing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.accentPrimary),
                      )
                    : Icon(Icons.sync, color: colors.accentPrimary),
                onPressed: _performOnlineSync,
                tooltip: '从官方拉取最新战绩',
              ),
            ],
          ),
          body: Column(
            children: [
              // Mode Filter Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _buildModeFilterChip('全部模式', null, colors),
                    const SizedBox(width: 8),
                    _buildModeFilterChip('排位赛', BattleType.ranked, colors),
                    const SizedBox(width: 8),
                    _buildModeFilterChip('休闲赛', BattleType.casual, colors),
                    const SizedBox(width: 8),
                    _buildModeFilterChip('比赛间对战', BattleType.customRoom, colors),
                    const SizedBox(width: 8),
                    _buildModeFilterChip('格斗中心对战', BattleType.battleHub, colors),
                  ],
                ),
              ),

              // Character Filter Bar (Matches AnalyticsScreen design)
              _buildCharacterFilterBar(charCounts, colors),

              // Summary Stats Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: colors.cardDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已归档 ${filteredRecords.length} 局对战',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '胜率: ${_calculateWinRate(filteredRecords)}%',
                      style: TextStyle(color: colors.accentTertiary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Records List
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: colors.accentPrimary))
                    : filteredRecords.isEmpty
                        ? Center(
                            child: Text(
                              '暂无符合条件的战绩记录',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _performOnlineSync,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 110, top: 4),
                              itemCount: filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = filteredRecords[index];
                                return BattleCardItem(
                                  record: record,
                                  authService: widget.authService,
                                  onShare: () => _showShareDialog(context, record),
                                  onAddNote: () => _showAddNoteDialog(context, record),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeFilterChip(String label, BattleType? type, AppThemeColors colors) {
    final isSelected = _selectedFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = type),
      selectedColor: colors.accentPrimary.withOpacity(0.18),
      backgroundColor: colors.bgCard,
      labelStyle: TextStyle(
        color: isSelected ? colors.accentPrimary : colors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? colors.accentPrimary : colors.borderSubtle,
      ),
    );
  }

  Widget _buildCharacterFilterBar(Map<String, int> charCounts, AppThemeColors colors) {
    final sortedChars = List<Sf6Character>.from(Sf6Characters.all);
    if (_charSortMode == 'matches') {
      sortedChars.sort((a, b) {
        final countA = charCounts[a.id] ?? 0;
        final countB = charCounts[b.id] ?? 0;
        if (countA != countB) return countB.compareTo(countA);
        return a.nameZh.compareTo(b.nameZh);
      });
    }

    return Container(
      color: colors.isClaudeWarm ? Colors.transparent : AppColors.bgSecondary,
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                    '我方角色筛选',
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
                  onTap: () => setState(() => _isCharGridExpanded = !_isCharGridExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _isCharGridExpanded ? colors.accentPrimary.withOpacity(0.18) : colors.bgCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _isCharGridExpanded ? colors.accentPrimary : colors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isCharGridExpanded ? Icons.view_carousel : Icons.grid_view, size: 12, color: colors.accentPrimary),
                        const SizedBox(width: 3),
                        Text(
                          _isCharGridExpanded ? '收起' : '展开',
                          style: TextStyle(color: colors.accentPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (_isCharGridExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ChoiceChip(
                    label: const Text('全部角色综合'),
                    selected: _selectedCharacterId == 'all',
                    onSelected: (_) => setState(() => _selectedCharacterId = 'all'),
                    selectedColor: colors.accentPrimary.withOpacity(0.18),
                    backgroundColor: colors.bgCard,
                    side: BorderSide(color: _selectedCharacterId == 'all' ? colors.accentPrimary : colors.borderSubtle),
                    labelStyle: TextStyle(
                      color: _selectedCharacterId == 'all' ? colors.accentPrimary : colors.textSecondary,
                      fontWeight: _selectedCharacterId == 'all' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                  ...sortedChars.map((c) {
                    final isSelected = _selectedCharacterId == c.id;
                    final matchCount = charCounts[c.id] ?? 0;
                    return ChoiceChip(
                      avatar: CharacterAvatar(characterId: c.id, size: 20, showBorder: false),
                      label: Text(
                        c.nameZh + (matchCount > 0 ? ' ($matchCount)' : ''),
                        style: TextStyle(
                          color: isSelected ? colors.accentPrimary : (matchCount > 0 ? colors.textPrimary : colors.textSecondary),
                          fontWeight: isSelected || matchCount > 0 ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCharacterId = c.id),
                      selectedColor: colors.accentPrimary.withOpacity(0.18),
                      backgroundColor: colors.bgCard,
                      side: BorderSide(color: isSelected ? colors.accentPrimary : colors.borderSubtle),
                    );
                  }),
                ],
              ),
            )
          else
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  ChoiceChip(
                    label: const Text('全部角色综合'),
                    selected: _selectedCharacterId == 'all',
                    onSelected: (_) => setState(() => _selectedCharacterId = 'all'),
                    selectedColor: colors.accentPrimary.withOpacity(0.18),
                    backgroundColor: colors.bgCard,
                    side: BorderSide(color: _selectedCharacterId == 'all' ? colors.accentPrimary : colors.borderSubtle),
                    labelStyle: TextStyle(
                      color: _selectedCharacterId == 'all' ? colors.accentPrimary : colors.textSecondary,
                      fontWeight: _selectedCharacterId == 'all' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ...sortedChars.map((c) {
                    final isSelected = _selectedCharacterId == c.id;
                    final matchCount = charCounts[c.id] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        avatar: CharacterAvatar(characterId: c.id, size: 20, showBorder: false),
                        label: Text(
                          c.nameZh + (matchCount > 0 ? ' ($matchCount)' : ''),
                          style: TextStyle(
                            color: isSelected ? colors.accentPrimary : (matchCount > 0 ? colors.textPrimary : colors.textSecondary),
                            fontWeight: isSelected || matchCount > 0 ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCharacterId = c.id),
                        selectedColor: colors.accentPrimary.withOpacity(0.18),
                        backgroundColor: colors.bgCard,
                        side: BorderSide(color: isSelected ? colors.accentPrimary : colors.borderSubtle),
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

  String _calculateWinRate(List<BattleRecord> list) {
    if (list.isEmpty) return '0.0';
    final wins = list.where((r) => r.isWin).length;
    return ((wins / list.length) * 100.0).toStringAsFixed(1);
  }

  void _showShareDialog(BuildContext context, BattleRecord record) {
    ShareBattleDialog.show(context, record);
  }

  void _showAddNoteDialog(BuildContext context, BattleRecord record) {
    final colors = context.themeColors;
    final titleController = TextEditingController(text: '对战对策心得');
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.bgCardSolid,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '添加对策心得笔记',
            style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: colors.textPrimary),
                decoration: InputDecoration(
                  labelText: '笔记标题',
                  labelStyle: TextStyle(color: colors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                style: TextStyle(color: colors.textPrimary),
                decoration: InputDecoration(
                  labelText: '心得对策内容',
                  labelStyle: TextStyle(color: colors.textSecondary),
                  hintText: '如：该对手起身喜欢凹升龙，注意诱导防守确反...',
                  hintStyle: TextStyle(color: colors.textTertiary),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('取消', style: TextStyle(color: colors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accentPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final note = PlayerNote(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    targetKey: record.opponentFighterId.isNotEmpty ? record.opponentFighterId : record.opponentCharacterId,
                    isCharacterNote: false,
                    title: titleController.text,
                    content: contentController.text,
                    tags: ['实战记录'],
                    updatedAt: DateTime.now(),
                  );
                  await widget.notesService.addOrUpdateNote(note);
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('对策心得已保存至工具箱！')),
                    );
                  }
                }
              },
              child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
