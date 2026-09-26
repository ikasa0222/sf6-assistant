import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/data/character_stats_database.dart';
import 'package:sf6_tracker/models/character_stats.dart';

class CharacterAttributesScreen extends StatelessWidget {
  final String characterId;

  const CharacterAttributesScreen({
    super.key,
    required this.characterId,
  });

  @override
  Widget build(BuildContext context) {
    final stats = CharacterStatsDatabase.getStats(characterId);

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
          '${stats.nameZh} · 基础属性',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Row 1: Vitals & Throws
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vitals
                Expanded(
                  child: _buildSectionCard(
                    icon: Icons.monitor_heart_outlined,
                    iconColor: AppColors.accentNeonCyan,
                    title: '生命核心',
                    subtitle: 'Vitals',
                    items: [
                      _buildMetricTile('体力', 'LIFE POINTS', '${stats.lifePoints}', isLarge: true),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Throws
                Expanded(
                  child: _buildSectionCard(
                    icon: Icons.track_changes_outlined,
                    iconColor: AppColors.loseRed,
                    title: '投掷交锋',
                    subtitle: 'Throws',
                    items: [
                      _buildMetricTile('投掷范围', 'THROW RANGE', '${stats.throwRange}'),
                      const SizedBox(height: 8),
                      _buildMetricTile('投掷受击框', 'THROW HURTBOX', '${stats.throwHurtbox}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Row 2: Ground Movement
            _buildSectionCard(
              icon: Icons.compare_arrows_outlined,
              iconColor: AppColors.accentNeonCyan,
              title: '地面机动',
              subtitle: 'Ground Movement',
              items: [
                Row(
                  children: [
                    Expanded(child: _buildMetricTile('前进步行速度', 'FORWARD WALK SPEED', '${stats.forwardWalkSpeed}')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMetricTile('后退步行速度', 'BACKWARD WALK SPEED', '${stats.backwardWalkSpeed}')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildMetricTile('前冲速度', 'FORWARD DASH SPEED', '${stats.forwardDashSpeed} F')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMetricTile('后撤速度', 'BACKWARD DASH SPEED', '${stats.backwardDashSpeed} F')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildMetricTile('前冲距离', 'FORWARD DASH DISTANCE', '${stats.forwardDashDistance}')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMetricTile('后撤距离', 'BACKWARD DASH DISTANCE', '${stats.backwardDashDistance}')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildMetricTile('绿冲可投最短距离', 'DRIVE RUSH MIN. (THROW)', '${stats.driveRushMinThrow}')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMetricTile('绿冲可防最短距离', 'DRIVE RUSH MIN. (BLOCK)', '${stats.driveRushMinBlock}')),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMetricTile('绿冲最大距离', 'DRIVE RUSH MAX DISTANCE', '${stats.driveRushMax}'),
              ],
            ),
            const SizedBox(height: 14),

            // Row 3: Jumping
            _buildSectionCard(
              icon: Icons.timer_outlined,
              iconColor: AppColors.accentNeonYellow,
              title: '空中机动',
              subtitle: 'Jumping',
              items: [
                Row(
                  children: [
                    Expanded(child: _buildMetricTile('跳跃速度', 'JUMP SPEED', '${stats.jumpSpeed} F')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMetricTile('跳跃最高点', 'JUMP APEX', '${stats.jumpApex}')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.16),
                ),
                child: Icon(icon, size: 15, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              Text(
                '($subtitle)',
                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String subtitle, String value, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 8, letterSpacing: 0.2),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isLarge ? 22 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
