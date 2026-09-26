import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/data/frame_data_database.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/services/frame_data_service.dart';
import 'package:sf6_tracker/ui/widgets/move_action_preview.dart';
import 'package:sf6_tracker/ui/widgets/move_detail_modal.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';

class MovelistScreen extends StatefulWidget {
  final String characterId;
  final FrameDataService frameDataService;

  const MovelistScreen({
    super.key,
    required this.characterId,
    required this.frameDataService,
  });

  @override
  State<MovelistScreen> createState() => _MovelistScreenState();
}

class _MovelistScreenState extends State<MovelistScreen> {
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
          '${char.nameZh} · 招式表',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Classic vs Modern Switcher (Screenshot 3 & 4)
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

          // Movelist
          Expanded(
            child: ListenableBuilder(
              listenable: widget.frameDataService,
              builder: (context, _) {
                final allMoves = FrameDataDatabase.getCharacterMoves(widget.characterId);

                final specials = allMoves.where((m) => m.type == MoveType.special).toList();
                final supers = allMoves.where((m) => m.type == MoveType.superArt).toList();
                final uniques = allMoves.where((m) => m.type == MoveType.unique).toList();
                final throws = allMoves.where((m) => m.type == MoveType.throwTech).toList();
                final drive = allMoves.where((m) => m.type == MoveType.driveAction).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    if (specials.isNotEmpty) ...[
                      _buildCategoryHeader('必杀技', 'SPECIAL MOVES'),
                      ...specials.map((m) => _buildMoveCard(m, char.nameZh)),
                    ],
                    if (supers.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildCategoryHeader('超必杀技', 'SUPER ARTS'),
                      ...supers.map((m) => _buildMoveCard(m, char.nameZh)),
                    ],
                    if (uniques.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildCategoryHeader('特殊技', 'UNIQUE MOVES'),
                      ...uniques.map((m) => _buildMoveCard(m, char.nameZh)),
                    ],
                    if (throws.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildCategoryHeader('普通投', 'THROWS'),
                      ...throws.map((m) => _buildMoveCard(m, char.nameZh)),
                    ],
                    if (drive.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildCategoryHeader('斗气系统', 'DRIVE SYSTEM'),
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
      padding: const EdgeInsets.only(top: 8, bottom: 8),
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
    final isSpecial = move.type == MoveType.special || move.type == MoveType.superArt;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle.withOpacity(0.6), width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          MoveDetailModal.show(
            context,
            move: move,
            characterNameZh: charName,
            characterId: widget.characterId,
            displayMode: _isModern ? CommandDisplayMode.modern : CommandDisplayMode.graphic,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Left Content: Title + Subtitle + Command
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          move.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (isSpecial) ...[
                          const SizedBox(width: 8),
                          // Green Drive Icon
                          Container(
                            width: 11,
                            height: 7,
                            decoration: BoxDecoration(
                              color: AppColors.winGreen,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            '2',
                            style: TextStyle(color: AppColors.winGreen, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      move.notes.isNotEmpty ? move.notes.split('，').first : move.command,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                    ),
                    const SizedBox(height: 6),

                    // Command display based on mode
                    if (!_isModern)
                      Sf6CommandView(
                        rawCommand: move.command,
                        mode: CommandDisplayMode.graphic,
                        iconSize: 16,
                      )
                    else ...[
                      Row(
                        children: [
                          const Text('常规输入 ', style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
                          Sf6CommandView(
                            rawCommand: move.command,
                            mode: CommandDisplayMode.modern,
                            iconSize: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Text('手动输入 ', style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
                          Sf6CommandView(
                            rawCommand: move.command,
                            mode: CommandDisplayMode.graphic,
                            iconSize: 14,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Right: Move Thumbnail
              MoveActionPreview(
                characterId: widget.characterId,
                move: move,
                width: 82,
                height: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
