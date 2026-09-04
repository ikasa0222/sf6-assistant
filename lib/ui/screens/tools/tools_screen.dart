import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/models/player_note.dart';
import 'package:sf6_tracker/services/frame_data_service.dart';
import 'package:sf6_tracker/services/notes_service.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';

class ToolsScreen extends StatefulWidget {
  final FrameDataService frameDataService;
  final NotesService notesService;

  const ToolsScreen({
    super.key,
    required this.frameDataService,
    required this.notesService,
  });

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.frameDataService.loadFrameDataForCharacter(widget.frameDataService.selectedCharacterId);
    widget.notesService.loadNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('格斗工具箱', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentNeonCyan,
          labelColor: AppColors.accentNeonCyan,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: '官方帧数表 (Frame Data)'),
            Tab(text: '对策与习惯笔记 (Notes)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFrameDataTab(),
          _buildNotesTab(),
        ],
      ),
    );
  }

  Widget _buildFrameDataTab() {
    return ListenableBuilder(
      listenable: widget.frameDataService,
      builder: (context, _) {
        final selectedCharId = widget.frameDataService.selectedCharacterId;
        final moves = widget.frameDataService.currentMoves;
        final plusFilter = widget.frameDataService.filterOnlyPlusOnBlock;
        final punishFilter = widget.frameDataService.filterOnlyPunishable;

        return Column(
          children: [
            // Character Picker List
            Container(
              height: 94,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: AppColors.bgSecondary,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: Sf6Characters.all.length,
                itemBuilder: (context, index) {
                  final char = Sf6Characters.all[index];
                  final isSelected = char.id == selectedCharId;
                  return GestureDetector(
                    onTap: () {
                      widget.frameDataService.selectCharacter(char.id);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.accentNeonCyan : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.accentNeonCyan.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: CharacterAvatar(
                              characterId: char.id,
                              size: 42,
                              showBorder: false,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            char.nameZh,
                            style: TextStyle(
                              color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: '搜索招式名称 / 指令 (如 2MK / 升龙)...',
                        prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textTertiary),
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      onChanged: widget.frameDataService.setSearchQuery,
                    ),
                  ),
                ],
              ),
            ),

            // Quick Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('被防有利 (+On Block)'),
                    selected: plusFilter,
                    selectedColor: AppColors.winGreen.withOpacity(0.25),
                    checkmarkColor: AppColors.winGreen,
                    labelStyle: TextStyle(
                      color: plusFilter ? AppColors.winGreen : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: plusFilter ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => widget.frameDataService.togglePlusOnBlockFilter(),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('大确反招式 (-On Block)'),
                    selected: punishFilter,
                    selectedColor: AppColors.loseRed.withOpacity(0.25),
                    checkmarkColor: AppColors.loseRed,
                    labelStyle: TextStyle(
                      color: punishFilter ? AppColors.loseRed : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: punishFilter ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => widget.frameDataService.togglePunishableFilter(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Frame Data Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.bgCard,
              child: const Row(
                children: [
                  Expanded(flex: 4, child: Text('招式名 / 指令', style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('发生', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('被防差', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('命中差', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('伤害', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold))),
                ],
              ),
            ),

            // Moves List
            Expanded(
              child: moves.isEmpty
                  ? const Center(
                      child: Text('没有找到符合条件的招式', style: TextStyle(color: AppColors.textTertiary)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: moves.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final move = moves[index];
                        final isPlus = move.isPlusOnBlock;
                        final isPunish = move.isPunishableOnBlock;

                        Color blockColor = AppColors.textPrimary;
                        if (isPlus) blockColor = AppColors.winGreen;
                        if (isPunish) blockColor = AppColors.loseRed;

                        return ExpansionTile(
                          dense: true,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                          title: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      move.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                    ),
                                    Text(
                                      move.command,
                                      style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('${move.startup}F', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  move.onBlock,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: blockColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(move.onHit, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('${move.damage}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              color: AppColors.bgSecondary,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _buildFrameDetailBadge('持续: ${move.active}F'),
                                      const SizedBox(width: 8),
                                      _buildFrameDetailBadge('硬直: ${move.recovery}F'),
                                      const SizedBox(width: 8),
                                      _buildFrameDetailBadge(move.isCancelable ? '可取消 (Cancelable)' : '不可取消', color: move.isCancelable ? AppColors.accentNeonCyan : AppColors.textTertiary),
                                    ],
                                  ),
                                  if (move.notes.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text('实战笔记: ${move.notes}', style: const TextStyle(color: AppColors.accentNeonYellow, fontSize: 12)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFrameDetailBadge(String text, {Color color = AppColors.textSecondary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildNotesTab() {
    return ListenableBuilder(
      listenable: widget.notesService,
      builder: (context, _) {
        final notes = widget.notesService.notes;

        return Scaffold(
          body: notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.note_alt_outlined, size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      const Text('暂无对策笔记', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text('添加第一条角色/对手对策', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
                        onPressed: () => _showAddNoteDialog(context),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final char = Sf6Characters.getById(note.targetKey);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
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
                                      Text(
                                        note.title.isNotEmpty ? note.title : '对阵 ${char.nameZh} (${char.nameEn})',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                      ),
                                      Text(
                                        '更新时间: ${note.updatedAt.month}月${note.updatedAt.day}日',
                                        style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.loseRed),
                                  onPressed: () => widget.notesService.deleteNote(note.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              note.content,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                            ),
                            if (note.tags.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                children: note.tags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgSecondary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('#$tag', style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 11)),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.accentNeonCyan,
            onPressed: () => _showAddNoteDialog(context),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        );
      },
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    String selectedChar = 'ryu';
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgCard,
              title: const Text('添加对策心得与习惯记录', style: TextStyle(color: AppColors.textPrimary)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('选择对手角色：', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedChar,
                      dropdownColor: AppColors.bgCard,
                      items: Sf6Characters.all.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.nameZh} (${c.nameEn})', style: const TextStyle(color: AppColors.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedChar = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: '对策标题 (可选)',
                        hintText: '例如: 对阵 肯 迅雷脚确反',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: '对策心得 / 起手习惯 / 弱点破绽',
                        hintText: '如：该玩家倒地极爱升龙凹招；中距离习惯用 2MK 抢打，多用波动拳压制...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: '标签 (用空格分隔)',
                        hintText: '凹招 偷下段 升龙确反',
                      ),
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
                    if (noteController.text.trim().isNotEmpty) {
                      final tags = tagsController.text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
                      final note = PlayerNote(
                        id: 'note_${DateTime.now().millisecondsSinceEpoch}',
                        targetKey: selectedChar,
                        isCharacterNote: true,
                        title: titleController.text.trim().isNotEmpty ? titleController.text.trim() : '对阵 ${Sf6Characters.getById(selectedChar).nameZh} 对策',
                        content: noteController.text.trim(),
                        tags: tags,
                        updatedAt: DateTime.now(),
                      );
                      await widget.notesService.addOrUpdateNote(note);
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('保存对策', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
