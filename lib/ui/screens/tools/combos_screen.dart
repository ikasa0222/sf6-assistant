import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/models/combo_recipe.dart';
import 'package:sf6_tracker/services/combo_service.dart';
import 'package:sf6_tracker/ui/widgets/combo_recipe_card.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';

class CombosScreen extends StatefulWidget {
  final String characterId;
  final ComboService comboService;

  const CombosScreen({
    super.key,
    required this.characterId,
    required this.comboService,
  });

  @override
  State<CombosScreen> createState() => _CombosScreenState();
}

class _CombosScreenState extends State<CombosScreen> {
  String? _selectedStarterFilter;
  CommandDisplayMode _displayMode = CommandDisplayMode.graphic;

  @override
  void initState() {
    super.initState();
    widget.comboService.selectCharacter(widget.characterId);
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
        title: Column(
          children: [
            Text(
              '${char.nameZh} · 连招推荐',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
            const Text(
              '数据源 (Source) : supercombo',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<CommandDisplayMode>(
            icon: const Icon(Icons.tune, size: 18, color: AppColors.accentNeonCyan),
            tooltip: '切换指令显示',
            color: AppColors.bgCard,
            onSelected: (mode) => setState(() => _displayMode = mode),
            itemBuilder: (_) => [
              const PopupMenuItem(value: CommandDisplayMode.graphic, child: Text('官方图形图标', style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
              const PopupMenuItem(value: CommandDisplayMode.numpad, child: Text('5LP 数字记法', style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
              const PopupMenuItem(value: CommandDisplayMode.chinese, child: Text('站轻腿 中文全称', style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
            ],
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.comboService,
        builder: (context, _) {
          final allCombos = widget.comboService.currentCombos;
          final filtered = allCombos.where((c) {
            if (_selectedStarterFilter != null) {
              if (!c.starterZh.contains(_selectedStarterFilter!) &&
                  !c.starterType.toLowerCase().contains(_selectedStarterFilter!.toLowerCase())) {
                return false;
              }
            }
            return true;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Starter filter horizontal chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  children: [
                    _buildFilterChip(null, '全部'),
                    const SizedBox(width: 6),
                    _buildFilterChip('确反', '确反康 (PC)'),
                    const SizedBox(width: 6),
                    _buildFilterChip('迸发', '斗气迸发 (DI)'),
                    const SizedBox(width: 6),
                    _buildFilterChip('绿冲', '绿冲连段 (DR)'),
                    const SizedBox(width: 6),
                    _buildFilterChip('打断', '打断康 (CH)'),
                    const SizedBox(width: 6),
                    _buildFilterChip('普通', '普通命中'),
                  ],
                ),
              ),

              // Title: 连招列表
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Text(
                      '连招列表',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${filtered.length} 套实用连招)',
                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Combos ListView
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          '当前分类下暂无连招',
                          style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final recipe = filtered[index];
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
      ),
    );
  }

  Widget _buildFilterChip(String? filterVal, String label) {
    final isSelected = _selectedStarterFilter == filterVal;
    return GestureDetector(
      onTap: () => setState(() => _selectedStarterFilter = filterVal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C4DFF).withOpacity(0.25) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF7C4DFF) : AppColors.borderSubtle,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFB388FF) : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
