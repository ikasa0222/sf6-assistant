import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/data/character_stats_database.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';

class HitboxViewerScreen extends StatefulWidget {
  final String characterId;

  const HitboxViewerScreen({
    super.key,
    required this.characterId,
  });

  @override
  State<HitboxViewerScreen> createState() => _HitboxViewerScreenState();
}

class _HitboxViewerScreenState extends State<HitboxViewerScreen> {
  String _selectedCategory = '全部';

  @override
  Widget build(BuildContext context) {
    final char = Sf6Characters.getById(widget.characterId);
    final stats = CharacterStatsDatabase.getStats(widget.characterId);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '碰撞框',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Character Banner Card (Screenshot 9)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CharacterAvatar(characterId: widget.characterId, size: 48, showBorder: false),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats.nameEn,
                        style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 10, letterSpacing: 0.8, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stats.nameZh,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'HITBOX LIBRARY',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 9, letterSpacing: 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Source bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.polyline, size: 14, color: AppColors.accentNeonCyan),
                  SizedBox(width: 6),
                  Text('数据源 (Source) : ', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  Text('ultimateframedata', style: TextStyle(color: AppColors.accentNeonCyan, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _categoryChip('全部', stats.hitboxCount),
                  const SizedBox(width: 6),
                  _categoryChip('必杀技', (stats.hitboxCount * 0.5).round()),
                  const SizedBox(width: 6),
                  _categoryChip('通常技', (stats.hitboxCount * 0.4).round()),
                  const SizedBox(width: 6),
                  _categoryChip('特殊技', (stats.hitboxCount * 0.1).round()),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Hitbox Cards (Sample representations)
            _buildHitboxCard(
              title: '轻 豪波动拳 (1 级)',
              subtitle: 'L Gou Hadoken (Lv1)',
              command: '236LP',
              frame: 20,
            ),
            const SizedBox(height: 12),
            _buildHitboxCard(
              title: '豪升龙拳 (重)',
              subtitle: 'H Gou Shoryuken',
              command: '623HP',
              frame: 5,
            ),
            const SizedBox(height: 12),
            _buildHitboxCard(
              title: '站立中拳 (5MP)',
              subtitle: 'Standing Medium Punch',
              command: '5MP',
              frame: 6,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String title, int count) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C4DFF).withOpacity(0.25) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF7C4DFF) : AppColors.borderSubtle,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                color: isSelected ? const Color(0xFFB388FF) : AppColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHitboxCard({
    required String title,
    required String subtitle,
    required String command,
    required int frame,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle.withOpacity(0.7), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Hitbox Frame Preview
          Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF14161D),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              border: Border.all(color: Colors.white.withOpacity(0.04), width: 0.5),
            ),
            child: Stack(
              children: [
                // Grid background lines
                CustomPaint(
                  size: const Size(double.infinity, 170),
                  painter: _GridPainter(),
                ),
                // Frame number indicator (bottom left)
                Positioned(
                  bottom: 8,
                  left: 10,
                  child: Text(
                    '$frame',
                    style: const TextStyle(
                      color: Color(0xFFFFA726),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Hurtbox & Hitbox simulation overlay boxes
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Green hurtbox
                      Container(
                        width: 70,
                        height: 110,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                          color: const Color(0xFF00E676).withOpacity(0.08),
                        ),
                      ),
                      // Blue core box
                      Container(
                        width: 45,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF2979FF), width: 1.5),
                          color: const Color(0xFF2979FF).withOpacity(0.08),
                        ),
                      ),
                      // Red active hitbox
                      Positioned(
                        right: 0,
                        top: 25,
                        child: Container(
                          width: 38,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFF1744), width: 1.5),
                            color: const Color(0xFFFF1744).withOpacity(0.18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Right: Open viewer chip
                Positioned(
                  bottom: 8,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('逐帧播放', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('OPEN VIEWER', style: TextStyle(color: AppColors.textTertiary, fontSize: 7)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Description & Command row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                ),
                const SizedBox(height: 6),
                Sf6CommandView(
                  rawCommand: command,
                  mode: CommandDisplayMode.graphic,
                  iconSize: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
