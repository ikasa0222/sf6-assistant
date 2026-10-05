import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/models/home_card_config.dart';

class HomeCardsManagementScreen extends StatefulWidget {
  const HomeCardsManagementScreen({super.key});

  @override
  State<HomeCardsManagementScreen> createState() => _HomeCardsManagementScreenState();
}

class _HomeCardsManagementScreenState extends State<HomeCardsManagementScreen> {
  List<HomeCardConfig> _configs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    final list = await StorageService.instance.getHomeCardConfigs();
    if (mounted) {
      setState(() {
        _configs = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConfigs() async {
    await StorageService.instance.saveHomeCardConfigs(_configs);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _configs.removeAt(oldIndex);
      _configs.insert(newIndex, item);
    });
    _saveConfigs();
  }

  void _toggleVisibility(int index, bool value) {
    if (_configs[index].key == 'hero' || _configs[index].key == HomeCardConfig.keyHero) return; // hero 核心项不可隐藏
    setState(() {
      _configs[index] = _configs[index].copyWith(isVisible: value);
    });
    _saveConfigs();
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('恢复默认设置', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          '确定要将首页卡片顺序和显示状态恢复为默认设置吗？',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认恢复', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _configs = List<HomeCardConfig>.from(HomeCardConfig.defaults);
      });
      await _saveConfigs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已恢复为默认卡片布局'),
            backgroundColor: AppColors.winGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页卡片管理', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '恢复默认设置',
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentNeonCyan))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppColors.bgSecondary.withOpacity(0.5),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.accentNeonCyan),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '长按右侧手柄可上下拖拽排序，开关控制模块显隐',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _configs.length,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final item = _configs[index];
                      final isHero = item.key == 'hero' || item.key == HomeCardConfig.keyHero;
                      final title = HomeCardConfig.getCardNameZh(item.key);
                      final desc = HomeCardConfig.getCardDescription(item.key);

                      return Container(
                        key: ValueKey(item.key),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isHero
                                ? AppColors.accentNeonCyan.withOpacity(0.4)
                                : AppColors.borderSubtle,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Row(
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (isHero) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentNeonCyan.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '不可隐藏',
                                    style: TextStyle(
                                      color: AppColors.accentNeonCyan,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            isHero ? '核心项不可隐藏（展示玩家基础信息）' : desc,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: isHero ? true : item.isVisible,
                                activeColor: AppColors.accentNeonCyan,
                                onChanged: isHero
                                    ? null
                                    : (val) => _toggleVisibility(index, val),
                              ),
                              const SizedBox(width: 4),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(
                                  Icons.drag_handle,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('恢复默认设置'),
                      onPressed: _resetToDefaults,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
