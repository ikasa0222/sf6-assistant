import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/models/player_note.dart';
import 'package:sf6_tracker/services/frame_data_service.dart';
import 'package:sf6_tracker/services/notes_service.dart';
import 'package:sf6_tracker/services/combo_service.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/combo_recipe_card.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';

class ToolsScreen extends StatefulWidget {
  final FrameDataService frameDataService;
  final NotesService notesService;
  final ComboService? comboService;

  const ToolsScreen({
    super.key,
    required this.frameDataService,
    required this.notesService,
    this.comboService,
  });

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ComboService _comboService;
  bool _isFrameCharGridExpanded = false;
  bool _isComboCharGridExpanded = false;
  CommandDisplayMode _displayMode = CommandDisplayMode.graphic;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _comboService = widget.comboService ?? ComboService();
    _comboService.init();

    final charId = widget.frameDataService.selectedCharacterId;
    widget.frameDataService.loadFrameDataForCharacter(charId);
    _comboService.loadCombosForCharacter(charId);
    widget.notesService.loadNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCharacterChanged(String charId) {
    widget.frameDataService.selectCharacter(charId);
    _comboService.selectCharacter(charId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('格斗工具箱', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accentNeonCyan,
                labelColor: AppColors.accentNeonCyan,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(text: '官方帧数表 (Frames)'),
                  Tab(text: '连招推荐与确反 (Combos)'),
                  Tab(text: '对策习惯笔记 (Notes)'),
                ],
              ),
              _buildDisplayModeSelector(),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFrameDataTab(),
          _buildCombosTab(),
          _buildNotesTab(),
        ],
      ),
    );
  }

  Widget _buildDisplayModeSelector() {
    return Container(
      color: AppColors.bgSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.style, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 6),
          const Text(
            '指令显示:',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
              ),
              child: Row(
                children: [
                  _buildModeBtn(CommandDisplayMode.graphic, '官方图形'),
                  _buildModeBtn(CommandDisplayMode.numpad, '5LP 数字'),
                  _buildModeBtn(CommandDisplayMode.chinese, '站轻腿 中文'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(CommandDisplayMode mode, String label) {
    final isSelected = _displayMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _displayMode = mode;
          });
          widget.frameDataService.setDisplayMode(mode);
          _comboService.setDisplayMode(mode);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentNeonCyan.withOpacity(0.22) : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: isSelected ? Border.all(color: AppColors.accentNeonCyan.withOpacity(0.8), width: 1) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
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
            // Character Picker Header
            Container(
              color: AppColors.bgSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.sports_kabaddi, size: 16, color: AppColors.accentNeonCyan),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '当前角色: ${Sf6Characters.getById(selectedCharId).nameZh}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _isFrameCharGridExpanded = !_isFrameCharGridExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _isFrameCharGridExpanded ? AppColors.accentNeonCyan.withOpacity(0.2) : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _isFrameCharGridExpanded ? AppColors.accentNeonCyan : AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isFrameCharGridExpanded ? Icons.view_carousel : Icons.grid_view, size: 12, color: AppColors.accentNeonCyan),
                          const SizedBox(width: 4),
                          Text(
                            _isFrameCharGridExpanded ? '收起' : '展开全角色',
                            style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Character Picker (Grid Wrap or Horizontal List)
            if (_isFrameCharGridExpanded)
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                color: AppColors.bgSecondary,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Sf6Characters.all.map((char) {
                      final isSelected = char.id == selectedCharId;
                      return InkWell(
                        onTap: () => _onCharacterChanged(char.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentNeonCyan.withOpacity(0.2) : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? AppColors.accentNeonCyan : AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CharacterAvatar(characterId: char.id, size: 24, showBorder: false),
                              const SizedBox(width: 6),
                              Text(
                                char.nameZh,
                                style: TextStyle(
                                  color: isSelected ? AppColors.accentNeonCyan : AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            else
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
                      onTap: () => _onCharacterChanged(char.id),
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
                                    const SizedBox(height: 2),
                                    Sf6CommandView(
                                      rawCommand: move.command,
                                      mode: _displayMode,
                                      iconSize: 14,
                                      wrap: false,
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
                                      Text('持续: ${move.active}F', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                      const SizedBox(width: 16),
                                      Text('收招: ${move.recovery}F', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                      const SizedBox(width: 16),
                                      Text('可取消: ${move.isCancelable ? "是" : "否"}', style: TextStyle(color: move.isCancelable ? AppColors.winGreen : AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  if (move.notes.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      '特性要点: ${move.notes}',
                                      style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 12),
                                    ),
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

  Widget _buildCombosTab() {
    return ListenableBuilder(
      listenable: _comboService,
      builder: (context, _) {
        final selectedCharId = _comboService.selectedCharacterId;
        final combos = _comboService.filteredCombos;
        final currentFilter = _comboService.selectedStarterFilter;

        return Column(
          children: [
            // Character Picker Header
            Container(
              color: AppColors.bgSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, size: 16, color: AppColors.accentNeonCyan),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '连招角色: ${Sf6Characters.getById(selectedCharId).nameZh} (${combos.length} 套实用连招)',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _isComboCharGridExpanded = !_isComboCharGridExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _isComboCharGridExpanded ? AppColors.accentNeonCyan.withOpacity(0.2) : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _isComboCharGridExpanded ? AppColors.accentNeonCyan : AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isComboCharGridExpanded ? Icons.view_carousel : Icons.grid_view, size: 12, color: AppColors.accentNeonCyan),
                          const SizedBox(width: 4),
                          Text(
                            _isComboCharGridExpanded ? '收起' : '展开全角色',
                            style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Character Picker
            if (_isComboCharGridExpanded)
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                color: AppColors.bgSecondary,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Sf6Characters.all.map((char) {
                      final isSelected = char.id == selectedCharId;
                      return InkWell(
                        onTap: () => _onCharacterChanged(char.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentNeonCyan.withOpacity(0.2) : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? AppColors.accentNeonCyan : AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CharacterAvatar(characterId: char.id, size: 24, showBorder: false),
                              const SizedBox(width: 6),
                              Text(
                                char.nameZh,
                                style: TextStyle(
                                  color: isSelected ? AppColors.accentNeonCyan : AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            else
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
                      onTap: () => _onCharacterChanged(char.id),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: '搜索连招 / 起手 / 要点 (如 确反 / 升龙 / 2HP)...',
                        prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textTertiary),
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      onChanged: _comboService.setSearchQuery,
                    ),
                  ),
                ],
              ),
            ),

            // Starter Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _buildStarterChip(null, '全部起手', currentFilter == null),
                  const SizedBox(width: 6),
                  _buildStarterChip('确反', '确反康 (PC)', currentFilter == '确反'),
                  const SizedBox(width: 6),
                  _buildStarterChip('迸发', '斗气迸发 (DI)', currentFilter == '迸发'),
                  const SizedBox(width: 6),
                  _buildStarterChip('绿冲', '绿冲起手 (DR)', currentFilter == '绿冲'),
                  const SizedBox(width: 6),
                  _buildStarterChip('打断', '打断康 (CH)', currentFilter == '打断'),
                  const SizedBox(width: 6),
                  _buildStarterChip('普通', '普通命中', currentFilter == '普通'),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Combo List
            Expanded(
              child: combos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.playlist_remove, size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 8),
                          Text(
                            '当前分类下暂无连招数据',
                            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24, top: 4),
                      itemCount: combos.length,
                      itemBuilder: (context, index) {
                        final recipe = combos[index];
                        return ComboRecipeCard(
                          recipe: recipe,
                          displayMode: _displayMode,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStarterChip(String? filterValue, String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentNeonCyan.withOpacity(0.2),
      checkmarkColor: AppColors.accentNeonCyan,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => _comboService.setStarterFilter(filterValue),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.note_alt_outlined, size: 54, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      const Text(
                        '暂无对策笔记',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '在对战后记录对手的角色习惯、凹招破绽与反制思路',
                        style: TextStyle(fontSize: 12, color: AppColors.textTertiary.withOpacity(0.8)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      color: AppColors.bgCard,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (note.isCharacterNote)
                                  CharacterAvatar(characterId: note.targetKey, size: 28, showBorder: false)
                                else
                                  const Icon(Icons.person, color: AppColors.accentNeonCyan, size: 24),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.title.isNotEmpty ? note.title : '对策笔记',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                      ),
                                      Text(
                                        note.isCharacterNote
                                            ? '角色对策: ${Sf6Characters.getById(note.targetKey).nameZh}'
                                            : '玩家记录: ${note.targetKey}',
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
                            const SizedBox(height: 8),
                            Text(note.content, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                            if (note.tags.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: note.tags.map((t) => Chip(
                                  label: Text(t, style: const TextStyle(fontSize: 10, color: AppColors.accentNeonCyan)),
                                  backgroundColor: AppColors.bgSecondary,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                )).toList(),
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
