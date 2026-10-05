import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/ui/widgets/move_action_preview.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';

class MoveDetailModal extends StatelessWidget {
  final FrameMove move;
  final String characterNameZh;
  final String characterId;
  final CommandDisplayMode displayMode;
  final VoidCallback? onOpenFullFrameData;
  final bool isAlreadyInFrameData;

  const MoveDetailModal({
    super.key,
    required this.move,
    required this.characterNameZh,
    this.characterId = 'ryu',
    this.displayMode = CommandDisplayMode.graphic,
    this.onOpenFullFrameData,
    this.isAlreadyInFrameData = false,
  });

  static void show(BuildContext context, {
    required FrameMove move,
    required String characterNameZh,
    String characterId = 'ryu',
    CommandDisplayMode displayMode = CommandDisplayMode.graphic,
    VoidCallback? onOpenFullFrameData,
    bool isAlreadyInFrameData = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MoveDetailModal(
        move: move,
        characterNameZh: characterNameZh,
        characterId: characterId,
        displayMode: displayMode,
        onOpenFullFrameData: onOpenFullFrameData,
        isAlreadyInFrameData: isAlreadyInFrameData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuperArt = move.type == MoveType.superArt || move.name.startsWith('SA') || move.name.startsWith('CA');
    final isOdMove = !isSuperArt && (move.name.startsWith('OD ') ||
        move.name.contains('OD') ||
        move.command.contains('PP') ||
        move.command.contains('KK'));
    final isNormalSpecial = (move.type == MoveType.special) && !isOdMove;

    int saLevel = 1;
    final nameUpper = move.name.toUpperCase();
    if (nameUpper.contains('SA3') || nameUpper.contains('CA') || nameUpper.contains('CRITICAL')) {
      saLevel = 3;
    } else if (nameUpper.contains('SA2')) {
      saLevel = 2;
    } else {
      saLevel = 1;
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                // Purple accent bar
                Container(
                  width: 3.5,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        move.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        move.command,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Move Action Preview Banner
                  MoveActionPreview(
                    characterId: characterId,
                    move: move,
                    width: double.infinity,
                    height: 160,
                    isBanner: true,
                  ),
                  const SizedBox(height: 12),

                  // Input box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '指令输入',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            if (isSuperArt) ...[
                              Text(
                                '消耗 SA ${saLevel}格',
                                style: TextStyle(
                                  color: saLevel == 3
                                      ? const Color(0xFFFF1744)
                                      : (saLevel == 2 ? const Color(0xFF7C4DFF) : const Color(0xFF00E5FF)),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ] else if (isOdMove) ...[
                              const Text('消耗 ', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                              Container(
                                width: 14,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.winGreen,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('2 (OD)', style: TextStyle(color: AppColors.winGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                            ] else if (isNormalSpecial) ...[
                              const Text('无斗气消耗 (0 气)', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Sf6CommandView(
                          rawCommand: move.command,
                          mode: displayMode,
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Variations Table
                  const Text(
                    '帧数判定与版本',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: const BoxDecoration(
                            color: AppColors.bgCardHighlight,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 2, child: Text('版本', style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('发生', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('被防', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('命中', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                        // Default main row
                        _buildVariationRow(
                          label: '标准',
                          labelColor: AppColors.accentNeonCyan,
                          startup: '${move.startup}F',
                          onBlock: move.onBlock,
                          onHit: move.onHit,
                          isLast: move.variations.isEmpty && !(isSuperArt && (saLevel == 3 || move.notes.contains('CA'))),
                        ),
                        if (move.variations.isNotEmpty) ...[
                          for (int i = 0; i < move.variations.length; i++) ...[
                            _buildVariationRow(
                              label: move.variations[i].version,
                              labelColor: _getVariationColor(move.variations[i].version),
                              startup: move.variations[i].startup.endsWith('F')
                                  ? move.variations[i].startup
                                  : '${move.variations[i].startup}F',
                              onBlock: move.variations[i].onBlock,
                              onHit: move.variations[i].onHit,
                              isLast: i == move.variations.length - 1 && !(isSuperArt && (saLevel == 3 || move.notes.contains('CA'))),
                            ),
                          ],
                        ] else if (isSuperArt && (saLevel == 3 || move.notes.contains('CA'))) ...[
                          _buildVariationRow(
                            label: 'CA (残血爆发)',
                            labelColor: const Color(0xFFFF1744),
                            startup: '${move.startup}F',
                            onBlock: move.onBlock,
                            onHit: 'CA 爆发',
                            isLast: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  const Text(
                    'DESCRIPTION 招式说明',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      move.notes.isNotEmpty
                          ? move.notes
                          : '核心常规招式。发生${move.startup}帧，命中造成${move.damage}点伤害，被防硬直差为${move.onBlock}，可用于立回牵制或连招取消。',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                    label: const Text(
                      '分享招式 SHARE',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final notesText = (move.notes != null && move.notes!.trim().isNotEmpty) ? move.notes! : '基础战术招式';
                      final formattedText = '【街霸6 招式数据】$characterNameZh - ${move.name}\n'
                          '• 指令: ${move.command}\n'
                          '• 阶段: 发生 ${move.startup}F | 持续 ${move.active} | 硬直 ${move.recovery}\n'
                          '• 帧差: 被防 ${move.onBlock} | 命中 ${move.onHit} | 伤害 ${move.damage}\n'
                          '• 特性: $notesText\n'
                          '—— 数据来自 街霸6助手 (SF6 Assistant)';
                      try {
                        await Clipboard.setData(ClipboardData(text: formattedText));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('已复制 ${move.name} 完整指令与帧数到剪贴板'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('写入剪贴板失败，请检查系统权限'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAlreadyInFrameData
                          ? AppColors.bgCardHighlight
                          : const Color(0xFF7C4DFF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(
                      isAlreadyInFrameData ? Icons.arrow_back : Icons.arrow_forward,
                      size: 16,
                      color: isAlreadyInFrameData ? AppColors.textSecondary : Colors.white,
                    ),
                    label: Text(
                      isAlreadyInFrameData ? '返回列表 BACK' : '查看完整帧数 FULL',
                      style: TextStyle(
                        color: isAlreadyInFrameData ? AppColors.textSecondary : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (!isAlreadyInFrameData) {
                        onOpenFullFrameData?.call();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationRow({
    required String label,
    required Color labelColor,
    required String startup,
    required String onBlock,
    required String onHit,
    bool isLast = false,
  }) {
    Color blockColor = AppColors.textPrimary;
    if (onBlock.startsWith('+')) blockColor = AppColors.winGreen;
    if (onBlock.startsWith('-')) blockColor = AppColors.loseRed;

    Color hitColor = AppColors.textPrimary;
    if (onHit.startsWith('+') || onHit.contains('KD')) hitColor = AppColors.winGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: labelColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(startup, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text(onBlock, textAlign: TextAlign.center, style: TextStyle(color: blockColor, fontSize: 12, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            flex: 2,
            child: Text(onHit, textAlign: TextAlign.right, style: TextStyle(color: hitColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Color _getVariationColor(String version) {
    if (version.startsWith('L') || version.contains('轻')) return Colors.blueAccent;
    if (version.startsWith('M') || version.contains('中')) return AppColors.rankGold;
    if (version.startsWith('H') || version.contains('重')) return AppColors.loseRed;
    if (version.startsWith('OD') || version.contains('强化')) return const Color(0xFF7C4DFF);
    return AppColors.textSecondary;
  }
}
