import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/models/combo_recipe.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';

class ComboRecipeCard extends StatefulWidget {
  final ComboRecipe recipe;
  final CommandDisplayMode displayMode;

  const ComboRecipeCard({
    super.key,
    required this.recipe,
    this.displayMode = CommandDisplayMode.graphic,
  });

  @override
  State<ComboRecipeCard> createState() => _ComboRecipeCardState();
}

class _ComboRecipeCardState extends State<ComboRecipeCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle.withOpacity(0.6), width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line 1: Starter Pills + Full Graphic Motion Sequence
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                runSpacing: 5,
                children: [
                  // Starter Badge (Red pill for 确反康)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      recipe.starterZh,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Secondary action badge (e.g. 斗气迸发 / 绿冲)
                  if (_hasSecondaryAction(recipe))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                      ),
                      child: Text(
                        _getSecondaryActionText(recipe),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // Graphic Command Sequence
                  Sf6CommandView(
                    rawCommand: _cleanComboForGraphic(recipe.comboSequence),
                    mode: widget.displayMode,
                    iconSize: 18,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Line 2: 4 Columns (伤害, 位置, 难度, 资源)
              Row(
                children: [
                  // 伤害
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '伤害',
                          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          recipe.damage.isNotEmpty && recipe.damage != '-' ? recipe.damage : '-',
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 位置
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '位置',
                          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          recipe.positionZh,
                          style: const TextStyle(
                            color: Color(0xFFFFA726),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 难度
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '难度',
                          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          recipe.difficultyZh,
                          style: const TextStyle(
                            color: Color(0xFFB388FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 资源
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '资源',
                          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Drive Gauge Bar
                            _meterIcon(const Color(0xFF00E676)),
                            const SizedBox(width: 3),
                            Text(
                              recipe.driveGauge.isNotEmpty ? recipe.driveGauge : '1',
                              style: const TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            // SA Gauge Bar
                            _meterIcon(const Color(0xFFFF4081)),
                            const SizedBox(width: 3),
                            Text(
                              recipe.superGauge.isNotEmpty && recipe.superGauge != '0' ? recipe.superGauge : '-',
                              style: const TextStyle(color: Color(0xFFFF4081), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Expanded Section (Notes & Copy)
              if (_isExpanded) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 8),
                if (recipe.notes.trim().isNotEmpty) ...[
                  Text(
                    recipe.notes,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.45),
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.copy, size: 13, color: AppColors.accentNeonCyan),
                      label: const Text(
                        '复制连招文本',
                        style: TextStyle(color: AppColors.accentNeonCyan, fontSize: 11),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: recipe.comboSequence));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('已复制: ${recipe.comboSequence}'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _meterIcon(Color color) {
    return Container(
      width: 12,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  bool _hasSecondaryAction(ComboRecipe r) {
    final seq = r.comboSequence.toUpperCase();
    return seq.contains('DI') || seq.contains('DR') || r.starterType.toLowerCase().contains('impact');
  }

  String _getSecondaryActionText(ComboRecipe r) {
    final seq = r.comboSequence.toUpperCase();
    if (seq.contains('DI') || r.starterType.toLowerCase().contains('impact')) return '斗气迸发';
    if (seq.contains('DR')) return '绿冲起手';
    return '实战连段';
  }

  String _cleanComboForGraphic(String seq) {
    // If it has PC or DI in front, remove them from the command line because they are rendered as badges
    String res = seq;
    res = res.replaceAll(RegExp(r'^(PC|CH)\s*(DI|DR)?\s*', caseSensitive: false), '');
    return res.trim();
  }
}
