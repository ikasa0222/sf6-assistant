import 'package:flutter/material.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/player_note.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/notes_service.dart';
import 'package:sf6_tracker/ui/widgets/battle_card_item.dart';
import 'package:sf6_tracker/ui/widgets/share_battle_card.dart';

class BattleLogScreen extends StatefulWidget {
  final AuthService authService;
  final BattleLogService battleLogService;
  final NotesService notesService;

  const BattleLogScreen({
    super.key,
    required this.authService,
    required this.battleLogService,
    required this.notesService,
  });

  @override
  State<BattleLogScreen> createState() => _BattleLogScreenState();
}

class _BattleLogScreenState extends State<BattleLogScreen> {
  BattleType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.authService, widget.battleLogService]),
      builder: (context, _) {
        final activePlatform = widget.authService.activePlatform;
        final records = widget.battleLogService.records;
        final isLoading = widget.battleLogService.isLoading;

        final filteredRecords = _selectedFilter == null
            ? records
            : records.where((r) => r.battleType == _selectedFilter).toList();

        return Scaffold(
      appBar: AppBar(
        title: const Text('无限对战战绩库', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.accentNeonCyan),
            onPressed: () {
              if (activePlatform != null) {
                widget.battleLogService.loadRecords(
                  shortId: activePlatform.shortId,
                  platform: activePlatform.platformType.code,
                  fighterId: activePlatform.fighterId,
                  lp: activePlatform.currentLp,
                  mr: activePlatform.currentMr,
                  forceSync: true,
                );
              }
            },
            tooltip: '拉取最新战局',
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('全部模式', null),
                const SizedBox(width: 8),
                _buildFilterChip('排位赛', BattleType.ranked),
                const SizedBox(width: 8),
                _buildFilterChip('格斗中心', BattleType.battleHub),
                const SizedBox(width: 8),
                _buildFilterChip('休闲赛', BattleType.casual),
                const SizedBox(width: 8),
                _buildFilterChip('自定义房', BattleType.customRoom),
              ],
            ),
          ),
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
                  '已归档 ${filteredRecords.length} 局对战',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  '胜率: ${_calculateWinRate(filteredRecords)}%',
                  style: const TextStyle(color: AppColors.winGreen, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
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
                        onRefresh: () async {
                          if (activePlatform != null) {
                            await widget.battleLogService.loadRecords(
                              shortId: activePlatform.shortId,
                              platform: activePlatform.platformType.code,
                              forceSync: true,
                            );
                          }
                        },
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

  Widget _buildFilterChip(String label, BattleType? type) {
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
    final titleController = TextEditingController(text: '对战 ${record.opponentFighterId} 对策');
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
                  hintText: '记录该玩家起手习惯、受创确反点、防守破绽等...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
              onPressed: () async {
                if (contentController.text.trim().isNotEmpty) {
                  final newNote = PlayerNote(
                    id: 'note_${DateTime.now().millisecondsSinceEpoch}',
                    targetKey: record.opponentFighterId,
                    isCharacterNote: false,
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    tags: ['玩家习惯', record.opponentCharacterId],
                    updatedAt: DateTime.now(),
                  );
                  await widget.notesService.addOrUpdateNote(newNote);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('笔记已成功保存至工具箱！')),
                    );
                  }
                }
              },
              child: const Text('保存笔记', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
