import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/data/character_stats_database.dart';
import 'package:sf6_tracker/models/character_stats.dart';
import 'package:sf6_tracker/models/combo_recipe.dart';
import 'package:sf6_tracker/models/player_note.dart';
import 'package:sf6_tracker/services/combo_service.dart';
import 'package:sf6_tracker/services/frame_data_service.dart';
import 'package:sf6_tracker/services/notes_service.dart';
import 'package:sf6_tracker/ui/screens/tools/character_attributes_screen.dart';
import 'package:sf6_tracker/ui/screens/tools/combos_screen.dart';
import 'package:sf6_tracker/ui/screens/tools/frame_data_screen.dart';
import 'package:sf6_tracker/ui/screens/tools/hitbox_viewer_screen.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/ui/screens/tools/movelist_screen.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';

class ToolsScreen extends StatefulWidget {
  final FrameDataService frameDataService;
  final NotesService notesService;
  final ComboService? comboService;
  final AuthService? authService;
  final BattleLogService? battleLogService;

  const ToolsScreen({
    super.key,
    required this.frameDataService,
    required this.notesService,
    this.comboService,
    this.authService,
    this.battleLogService,
  });

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  late ComboService _comboService;
  late String _selectedCharId;

  @override
  void initState() {
    super.initState();
    _comboService = widget.comboService ?? ComboService();
    _comboService.init();

    final mainChar = widget.authService?.activePlatform?.mainCharId ??
        widget.battleLogService?.userProfile?.mainCharacterId ??
        '';
    if (mainChar.isNotEmpty && Sf6Characters.all.any((c) => c.id == mainChar)) {
      widget.frameDataService.setDefaultCharacter(mainChar);
    }

    _selectedCharId = widget.frameDataService.selectedCharacterId;
    widget.frameDataService.loadFrameDataForCharacter(_selectedCharId);
    _comboService.loadCombosForCharacter(_selectedCharId);
    widget.notesService.loadNotes();
  }

  void _onSelectCharacter(String charId) {
    setState(() {
      _selectedCharId = charId;
    });
    widget.frameDataService.selectCharacter(charId);
    _comboService.selectCharacter(charId);
  }

  @override
  Widget build(BuildContext context) {
    final stats = CharacterStatsDatabase.getStats(_selectedCharId);
    final char = Sf6Characters.getById(_selectedCharId);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          stats.nameZh,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline, color: AppColors.accentNeonCyan),
            tooltip: '切换角色',
            onPressed: () => _showCharacterPickerSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Character Hero Section (Screenshot 1)
            _buildHeroSection(stats, char),
            const SizedBox(height: 16),

            // Card 1: 基础属性 (Basic Attributes)
            _buildAttributesCard(stats),
            const SizedBox(height: 12),

            // Card 2 & 3: 招式表 & 帧数表 (2-Column Grid)
            Row(
              children: [
                Expanded(
                  child: _buildNavCard(
                    icon: Icons.sports_esports_outlined,
                    iconBgColor: const Color(0xFF7C4DFF),
                    title: '招式表',
                    subtitle: '必杀技 / SA',
                    tag: 'CLASSIC & MODERN >',
                    tagColor: const Color(0xFFB388FF),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovelistScreen(
                            characterId: _selectedCharId,
                            frameDataService: widget.frameDataService,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNavCard(
                    icon: Icons.timer_outlined,
                    iconBgColor: const Color(0xFF00E676),
                    title: '帧数表',
                    subtitle: '发生 / 确反',
                    tag: 'FRAME DATA >',
                    tagColor: const Color(0xFF00E676),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FrameDataScreen(
                            characterId: _selectedCharId,
                            frameDataService: widget.frameDataService,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Card 4: 实用连招 (Practical Combos)
            _buildCombosCard(context),
            const SizedBox(height: 12),

            // Card 5 & 6: 碰撞框 & 精选笔记 (2-Column Grid)
            Row(
              children: [
                // 碰撞框
                Expanded(
                  child: _buildHitboxCard(context, stats),
                ),
                const SizedBox(width: 12),
                // 精选笔记
                Expanded(
                  child: _buildNotesCard(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(CharacterStats stats, Sf6Character char) {
    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1E212B).withOpacity(0.5),
            const Color(0xFF0C0D12),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Character Render
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 220,
            child: Opacity(
              opacity: 0.85,
              child: Image.asset(
                'assets/images/characters/${char.id}.png',
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          // Gradient Fade Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF0C0D12),
                    const Color(0xFF0C0D12).withOpacity(0.7),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          // Foreground Text (Title & Lore Quote)
          Positioned(
            left: 16,
            bottom: 20,
            right: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stats.nameZh,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stats.quote,
                  style: const TextStyle(
                    color: Color(0xFF9E9EB2),
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesCard(CharacterStats stats) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle.withOpacity(0.7), width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CharacterAttributesScreen(characterId: _selectedCharId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentNeonCyan.withOpacity(0.18),
                    ),
                    child: const Icon(Icons.monitor_heart_outlined, size: 14, color: AppColors.accentNeonCyan),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '基础属性',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textTertiary),
                ],
              ),
              const SizedBox(height: 12),

              // 4 Metrics
              Row(
                children: [
                  _attributeMetric('体力', '${stats.lifePoints}'),
                  _attributeMetric('前进速度', '${stats.forwardWalkSpeed}'),
                  _attributeMetric('后退速度', '${stats.backwardWalkSpeed}'),
                  _attributeMetric('难度', stats.difficulty),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attributeMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle.withOpacity(0.7), width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconBgColor.withOpacity(0.2),
                    ),
                    child: Icon(icon, size: 15, color: iconBgColor),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tag,
                    style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombosCard(BuildContext context) {
    return ListenableBuilder(
      listenable: _comboService,
      builder: (context, _) {
        final combos = _comboService.currentCombos;
        final previewCombos = combos.take(2).toList();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle.withOpacity(0.7), width: 0.8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CombosScreen(
                    characterId: _selectedCharId,
                    comboService: _comboService,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFA726).withOpacity(0.18),
                        ),
                        child: const Icon(Icons.flash_on, size: 15, color: Color(0xFFFFA726)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '实用连招',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textTertiary),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Preview Rows (Screenshot 1)
                  if (previewCombos.isNotEmpty)
                    ...previewCombos.map((c) => _comboPreviewRow(c))
                  else
                    _comboPreviewFallback(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _comboPreviewRow(ComboRecipe c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              c.comboSequence,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${c.damage.isNotEmpty && c.damage != "-" ? c.damage : "2820"} DMG',
            style: const TextStyle(
              color: Color(0xFFFFA726),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _comboPreviewFallback() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'PC DI HK,MK>214HK',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '2820 DMG',
            style: TextStyle(color: Color(0xFFFFA726), fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHitboxCard(BuildContext context, CharacterStats stats) {
    return Container(
      height: 135,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle.withOpacity(0.7), width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HitboxViewerScreen(characterId: _selectedCharId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.loseRed.withOpacity(0.18),
                    ),
                    child: const Icon(Icons.track_changes_outlined, size: 14, color: AppColors.loseRed),
                  ),
                  const SizedBox(width: 6),
                  const Text('碰撞框', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${stats.hitboxCount} 项', style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
                  ),
                ],
              ),
              const Text(
                '按招式进入碰撞框列表与逐帧查看。',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('点击查阅 >', style: TextStyle(color: AppColors.loseRed, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notesService,
      builder: (context, _) {
        final notes = widget.notesService.notes.where((n) => n.targetKey == _selectedCharId).toList();

        return Container(
          height: 135,
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle.withOpacity(0.7), width: 0.8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showNotesDialog(context),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E88E5).withOpacity(0.18),
                        ),
                        child: const Icon(Icons.menu_book_outlined, size: 14, color: Color(0xFF1E88E5)),
                      ),
                      const SizedBox(width: 6),
                      const Text('精选笔记', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(
                    '${notes.isNotEmpty ? notes.length : widget.notesService.notes.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const Text('查看全部 >', style: TextStyle(color: Color(0xFF1E88E5), fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCharacterPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('选择出战格斗家', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Sf6Characters.all.map((c) {
                      final isSelected = c.id == _selectedCharId;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _onSelectCharacter(c.id);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentNeonCyan.withOpacity(0.2) : AppColors.bgSecondary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? AppColors.accentNeonCyan : AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CharacterAvatar(characterId: c.id, size: 24, showBorder: false),
                              const SizedBox(width: 6),
                              Text(
                                c.nameZh,
                                style: TextStyle(
                                  color: isSelected ? AppColors.accentNeonCyan : AppColors.textPrimary,
                                  fontSize: 12,
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
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotesDialog(BuildContext context) {
    final currentChar = Sf6Characters.getById(_selectedCharId);
    int selectedTab = 0; // 0: current character, 1: all characters

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final allNotes = widget.notesService.notes;
            final charNotes = allNotes.where((n) => n.targetKey == _selectedCharId).toList();
            final displayedNotes = selectedTab == 0 ? charNotes : allNotes;

            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('精选对策心得与习惯笔记', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.accentNeonCyan),
                        tooltip: '添加新对策',
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAddNoteDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Tab switch: Current character vs All
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setModalState(() => selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selectedTab == 0 ? AppColors.accentNeonCyan.withOpacity(0.2) : AppColors.bgSecondary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedTab == 0 ? AppColors.accentNeonCyan : AppColors.borderSubtle,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '当前: ${currentChar.nameZh} (${charNotes.length})',
                            style: TextStyle(
                              color: selectedTab == 0 ? AppColors.accentNeonCyan : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setModalState(() => selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selectedTab == 1 ? const Color(0xFF7C4DFF).withOpacity(0.25) : AppColors.bgSecondary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedTab == 1 ? const Color(0xFF7C4DFF) : AppColors.borderSubtle,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '全部对策库 (${allNotes.length})',
                            style: TextStyle(
                              color: selectedTab == 1 ? Colors.white : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: displayedNotes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('暂无该角色专属笔记', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => setModalState(() => selectedTab = 1),
                                  child: const Text('查看其他角色对策 >', style: TextStyle(color: AppColors.accentNeonCyan, fontSize: 12)),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: displayedNotes.length,
                            itemBuilder: (_, i) {
                              final n = displayedNotes[i];
                              final isCustom = !n.id.startsWith('note_');

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSecondary,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.borderSubtle.withOpacity(0.6), width: 0.8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CharacterAvatar(characterId: n.targetKey, size: 22, showBorder: false),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                                          ),
                                        ),
                                        if (isCustom)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.textTertiary),
                                            onPressed: () async {
                                              await widget.notesService.deleteNote(n.id);
                                              setModalState(() {});
                                            },
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n.content,
                                      style: const TextStyle(color: Color(0xFFD0D0DC), fontSize: 11.5, height: 1.45),
                                    ),
                                    if (n.tags.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: n.tags.map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.bgCard,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '#$tag',
                                              style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 9.5),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    String selectedChar = _selectedCharId;
    final titleController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text('添加对策心得记录', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '对策标题', hintText: '例如: 对阵 豪鬼 斩空波确反'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '对策心得 / 破绽分析', hintText: '记录打法与心得...'),
              ),
            ],
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
                  final note = PlayerNote(
                    id: 'note_${DateTime.now().millisecondsSinceEpoch}',
                    targetKey: selectedChar,
                    isCharacterNote: true,
                    title: titleController.text.trim().isNotEmpty ? titleController.text.trim() : '对策笔记',
                    content: noteController.text.trim(),
                    updatedAt: DateTime.now(),
                  );
                  await widget.notesService.addOrUpdateNote(note);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
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
