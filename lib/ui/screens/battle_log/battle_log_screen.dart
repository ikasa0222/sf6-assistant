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
          content: Text(res.recordsUpdated > 0 ? '同步完成，已更新  局最新对战' : '同步完成，当前已是最新战绩'),
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

        // Count matches per character in current mode filter
        final charCounts = <String, int>{};
        for (final r in modeFiltered) {
          charCounts[r.playerCharacterId] = (charCounts[r.playerCharacterId] ?? 0) + 1;
        }

        // 2. Character Filter
        final filteredRecords = _selectedCharacterId == 'all'
            ? modeFiltered
            : modeFiltered.where((r) => r.playerCharacterId == _selectedCharacterId).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('无限对战战绩库', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: _isSyncing || widget.battleLogService.isBackgroundSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentNeonCyan),
                      )
                    : const Icon(Icons.sync, color: AppColors.accentNeonCyan),
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
                    _buildModeFilterChip('全部模式', null),
                    const SizedBox(width: 8),
                    _buildModeFilterChip('排位赛', BattleType.ranked),
                    const SizedBox(width: 8),
                    _buildModeFilterChip('格斗中心', BattleType.battleHub),
                    const SizedBox(width: 8),
                    _buildModeFilterChip('休闲赛', BattleType.casual),
                    const SizedBox(width: 8),
                    _buildModeFilterChip('自定义房', BattleType.customRoom),
                  ],
                ),
              ),

              // Character Filter Bar (Matches AnalyticsScreen design)
              _buildCharacterFilterBar(charCounts),

              // Summary Stats Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已归档  局对战',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '胜率: %',
                      style: const TextStyle(color: AppColors.winGreen, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Records List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accentNeonCyan))
                    : filteredRecords.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无符合条件的战绩记录',
                              style: TextStyle(color: AppColors.textTertiary),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _performOnlineSync,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24, top: 4),
                              itemCount: filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = filteredRecords[index];
                                return BattleCardItem(
                                  record: record,
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

  Widget _buildModeFilterChip(String label, BattleType? type) {
    final isSelected = _selectedFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = type),
      selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
      backgroundColor: AppColors.bgCard,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.accentNeonCyan : AppColors.borderSubtle,
      ),
    );
  }

  Widget _buildCharacterFilterBar(Map<String, int> charCounts) {
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
      color: AppColors.bgSecondary,
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                    '我方角色筛选',
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
                  onTap: () => setState(() => _isCharGridExpanded = !_isCharGridExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _isCharGridExpanded ? AppColors.accentNeonCyan.withOpacity(0.2) : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _isCharGridExpanded ? AppColors.accentNeonCyan : AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isCharGridExpanded ? Icons.view_carousel : Icons.grid_view, size: 12, color: AppColors.accentNeonCyan),
                        const SizedBox(width: 3),
                        Text(
                          _isCharGridExpanded ? '收起' : '展开',
                          style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 10, fontWeight: FontWeight.bold),
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
                    selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                    backgroundColor: AppColors.bgCard,
                    labelStyle: TextStyle(
                      color: _selectedCharacterId == 'all' ? AppColors.accentNeonCyan : AppColors.textSecondary,
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
                        c.nameZh + (matchCount > 0 ? ' ()' : ''),
                        style: TextStyle(
                          color: isSelected ? AppColors.accentNeonCyan : (matchCount > 0 ? AppColors.textPrimary : AppColors.textTertiary),
                          fontWeight: isSelected || matchCount > 0 ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCharacterId = c.id),
                      selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                      backgroundColor: AppColors.bgCard,
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
                    selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                    backgroundColor: AppColors.bgCard,
                    labelStyle: TextStyle(
                      color: _selectedCharacterId == 'all' ? AppColors.accentNeonCyan : AppColors.textSecondary,
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
                          c.nameZh + (matchCount > 0 ? ' ()' : ''),
                          style: TextStyle(
                            color: isSelected ? AppColors.accentNeonCyan : (matchCount > 0 ? AppColors.textPrimary : AppColors.textTertiary),
                            fontWeight: isSelected || matchCount > 0 ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCharacterId = c.id),
                        selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                        backgroundColor: AppColors.bgCard,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '对战战报预览',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ShareBattleCard(record: record),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share, color: Colors.black),
                      label: const Text('分享到社交平台', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentNeonCyan,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已准备好战报长图分享！')),
                        );
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

  void _showAddNoteDialog(BuildContext context, BattleRecord record) {
    final titleController = TextEditingController(text: '对战  对策');
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text('添加对策心得笔记', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '笔记标题'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '心得对策内容',
                  hintText: '如：该对手起身喜欢凹升龙，注意诱导防守确反...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: AppColors.textTertiary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
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
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('对策心得已保存至工具箱！')),
                    );
                  }
                }
              },
              child: const Text('保存', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
