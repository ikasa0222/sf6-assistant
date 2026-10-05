import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/services/frame_data_service.dart';
import 'package:sf6_tracker/ui/widgets/move_detail_modal.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';

class FrameDataScreen extends StatefulWidget {
  final String characterId;
  final FrameDataService frameDataService;

  const FrameDataScreen({
    super.key,
    required this.characterId,
    required this.frameDataService,
  });

  @override
  State<FrameDataScreen> createState() => _FrameDataScreenState();
}

class _FrameDataScreenState extends State<FrameDataScreen> {
  bool _isModern = false;

  @override
  void initState() {
    super.initState();
    widget.frameDataService.selectCharacter(widget.characterId);
  }

  @override
  Widget build(BuildContext context) {
    final char = Sf6Characters.getById(widget.characterId);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${char.nameZh} · 帧数表',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Classic vs Modern Switcher (Screenshot 7)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isModern = false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: !_isModern ? const Color(0xFF7C4DFF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '经典 Classic',
                        style: TextStyle(
                          color: !_isModern ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: !_isModern ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isModern = true),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isModern ? const Color(0xFF7C4DFF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '现代 Modern',
                        style: TextStyle(
                          color: _isModern ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: _isModern ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Column Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: const Row(
              children: [
                Expanded(flex: 5, child: Text('招式名称', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('发生', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF8E8E93), fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('被防', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF8E8E93), fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('命中', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF8E8E93), fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          // Moves List
          Expanded(
            child: ListenableBuilder(
              listenable: widget.frameDataService,
              builder: (context, _) {
                final allMoves = widget.frameDataService.currentMoves;

                final normals = allMoves.where((m) => m.type == MoveType.normal).toList();
                final uniques = allMoves.where((m) => m.type == MoveType.unique).toList();
                final specials = allMoves.where((m) => m.type == MoveType.special).toList();
                final supers = allMoves.where((m) => m.type == MoveType.superArt).toList();
                final drive = allMoves.where((m) => m.type == MoveType.driveAction || m.type == MoveType.throwTech).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    if (normals.isNotEmpty) ...[
                      _buildCategoryHeader('普通技', 'NORMAL MOVES'),
                      ...normals.map((m) => _buildMoveCard(m, char.nameZh)),
                    ],
                    if (uniques.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildCategoryHeader('特殊技', 'UNIQUE MOVES'),
                      ...uniques.map((m) => _buildMoveCard(m, char.nameZh)),
                    ],
                    if (specials.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildCategoryHeader('必杀技', 'SPECIAL MOVES'),
                      ...specials.map((m) => _buildMoveCard(m, char.nameZh)),
                    ],
                    if (supers.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildCategoryHeader('超必杀技', 'SUPER ARTS'),
                      ...supers.map((m) => _buildMoveCard(m, char.nameZh)),
                    ],
                    if (drive.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildCategoryHeader('通用与投技', 'SYSTEM & THROWS'),
                      ...drive.map((m) => _buildMoveCard(m, char.nameZh)),
                    ],
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String zh, String en) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        children: [
          Text(
            zh,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Text(
            en,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 9, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveCard(FrameMove move, String charName) {
    Color blockColor = AppColors.textPrimary;
    if (move.onBlock.startsWith('+')) blockColor = const Color(0xFF00E676);
    if (move.onBlock.startsWith('-')) blockColor = const Color(0xFFFF5252);

    Color hitColor = AppColors.textPrimary;
    if (move.onHit.startsWith('+') || move.onHit.contains('KD')) hitColor = const Color(0xFF00E676);

    // Get strength badge (L / M / H)
    final badge = _getStrengthBadge(move);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle.withOpacity(0.5), width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          MoveDetailModal.show(
            context,
            move: move,
            characterNameZh: charName,
            characterId: widget.characterId,
            displayMode: _isModern ? CommandDisplayMode.modern : CommandDisplayMode.graphic,
            isAlreadyInFrameData: true,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Move Name + Badge
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        move.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      badge,
                    ],
                  ],
                ),
              ),

              // Startup
              Expanded(
                flex: 2,
                child: Text(
                  move.startup,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),

              // On Block
              Expanded(
                flex: 2,
                child: Text(
                  move.onBlock,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: blockColor, fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),

              // On Hit
              Expanded(
                flex: 2,
                child: Text(
                  move.onHit,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: hitColor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _getStrengthBadge(FrameMove move) {
    final cmd = move.command.toUpperCase();
    if (cmd.contains('LP') || cmd.contains('LK') || move.name.contains('轻')) {
      return _strengthBadge('L', Colors.blueAccent);
    }
    if (cmd.contains('MP') || cmd.contains('MK') || move.name.contains('中')) {
      return _strengthBadge('M', AppColors.rankGold);
    }
    if (cmd.contains('HP') || cmd.contains('HK') || move.name.contains('重')) {
      return _strengthBadge('H', AppColors.loseRed);
    }
    if (cmd.contains('OD') || move.name.contains('OD')) {
      return _strengthBadge('OD', const Color(0xFF7C4DFF));
    }
    return null;
  }

  Widget _strengthBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
