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
    required this.displayMode,
  });

  @override
  State<ComboRecipeCard> createState() => _ComboRecipeCardState();
}

class _ComboRecipeCardState extends State<ComboRecipeCard> {
  bool _isExpanded = false;

  Color _getStarterColor(String starter) {
    final lower = starter.toLowerCase();
    if (lower.contains('punish')) return AppColors.loseRed;
    if (lower.contains('counter')) return Colors.orangeAccent;
    if (lower.contains('impact') || lower.contains('di')) return AppColors.accentNeonCyan;
    if (lower.contains('rush') || lower.contains('dr')) return AppColors.winGreen;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final starterColor = _getStarterColor(recipe.starterType);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Starter Badge + Position + Damage + Difficulty
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                // Starter badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: starterColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: starterColor.withOpacity(0.8), width: 1),
                  ),
                  child: Text(
                    recipe.starterZh,
                    style: TextStyle(
                      color: starterColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Position badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardHighlight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    recipe.positionZh,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),

                // Damage
                if (recipe.damage != '-' && recipe.damage.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '伤害 ',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
                      ),
                      Text(
                        recipe.damage,
                        style: const TextStyle(
                          color: AppColors.accentNeonCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                // Difficulty chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardHighlight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                  ),
                  child: Text(
                    recipe.difficultyZh,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Command Sequence Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Sf6CommandView(
              rawCommand: recipe.comboSequence,
              mode: widget.displayMode,
              iconSize: 20,
              textStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),

          // Footer Row: Gauges + Copy + Notes Toggle
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            child: Row(
              children: [
                // Drive Gauge Cost
                _buildGaugeCost('斗气', recipe.driveGauge, AppColors.winGreen),
                const SizedBox(width: 8),

                // Super Gauge Cost
                _buildGaugeCost('SA', recipe.superGauge, Colors.purpleAccent),
                const Spacer(),

                // Copy Button
                IconButton(
                  icon: const Icon(Icons.copy, size: 14, color: AppColors.textTertiary),
                  tooltip: '复制连招指令',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
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

                // Notes toggle button if notes exist
                if (recipe.notes.trim().isNotEmpty) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded ? '收起解析' : '要点解析',
                            style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                          ),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Expandable Notes
          if (_isExpanded && recipe.notes.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              child: Text(
                recipe.notes,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGaugeCost(String label, String cost, Color color) {
    final cleanCost = cost.trim();
    if (cleanCost.isEmpty || cleanCost == '0') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label 消耗: ', style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
          const Text('0', style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
          Text(cost, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
