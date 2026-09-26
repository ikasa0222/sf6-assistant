import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/utils/sf6_move_media_helper.dart';

class MoveActionPreview extends StatelessWidget {
  final String characterId;
  final FrameMove move;
  final double? width;
  final double height;
  final bool isBanner;
  final VoidCallback? onTap;

  const MoveActionPreview({
    super.key,
    required this.characterId,
    required this.move,
    this.width,
    required this.height,
    this.isBanner = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gifUrl = Sf6MoveMediaHelper.getHitboxGifUrl(characterId, move);

    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF12141C),
        borderRadius: BorderRadius.circular(isBanner ? 12 : 8),
        border: Border.all(
          color: AppColors.borderSubtle.withOpacity(0.6),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Training Grid
          Positioned.fill(
            child: CustomPaint(
              painter: _StageGridPainter(),
            ),
          ),

          // Main View: Network GIF or Stylized Character Action Card
          if (gifUrl != null)
            Image.network(
              gifUrl,
              width: width,
              height: height,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildFallbackVisual(context),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildFallbackVisual(context),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          '加载中',
                          style: TextStyle(color: AppColors.accentNeonCyan, fontSize: 8),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          else
            _buildFallbackVisual(context),

          // Top/Bottom Metadata Badges
          if (isBanner) ...[
            Positioned(
              top: 8,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                ),
                child: Text(
                  move.command,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.accentNeonCyan.withOpacity(0.5),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.accentNeonCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Sf6Characters.getById(characterId).nameZh,
                      style: const TextStyle(
                        color: AppColors.accentNeonCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Small badge for thumbnail
            Positioned(
              bottom: 3,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  move.startup.isNotEmpty && move.startup != '-' ? '${move.startup}F' : move.type.displayName.substring(0, 2),
                  style: const TextStyle(
                    color: Color(0xFFFFA726),
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }

  Widget _buildFallbackVisual(BuildContext context) {
    final char = Sf6Characters.getById(characterId);
    final isSpecial = move.type == MoveType.special || move.type == MoveType.superArt;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Fighter Action Avatar in Training Background
        Positioned(
          right: isBanner ? 16 : 4,
          top: 0,
          bottom: 0,
          width: isBanner ? 120 : 54,
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

        // Gradient Shadow Fade
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF12141C).withOpacity(0.9),
                  const Color(0xFF12141C).withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Action Strike Hitbox Silhouette Overlay
        Positioned(
          left: isBanner ? 14 : 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isSpecial ? const Color(0xFFFF1744) : const Color(0xFF2979FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    move.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isBanner ? 13 : 9,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (isBanner) ...[
                const SizedBox(height: 3),
                Text(
                  '${move.startup}F 发生 · ${move.onBlock} 被防 · ${move.damage} 伤害',
                  style: const TextStyle(
                    color: Color(0xFF9E9EB2),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StageGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.8;

    const step = 16.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Floor baseline
    final floorPaint = Paint()
      ..color = const Color(0xFF7C4DFF).withOpacity(0.2)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, size.height * 0.82), Offset(size.width, size.height * 0.82), floorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
