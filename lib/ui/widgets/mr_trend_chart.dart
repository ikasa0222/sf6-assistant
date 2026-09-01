import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';

class MrTrendChart extends StatelessWidget {
  final List<int> mrPoints;
  final double height;

  const MrTrendChart({
    super.key,
    required this.mrPoints,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (mrPoints.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            '暂无 MR 变动数据',
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ),
      );
    }

    final minMr = mrPoints.reduce(min);
    final maxMr = mrPoints.reduce(max);
    final currentMr = mrPoints.last;
    final diff = currentMr - mrPoints.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MR 积分历史走势',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$currentMr MR',
                        style: const TextStyle(
                          color: AppColors.rankMaster,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (diff >= 0 ? AppColors.winGreen : AppColors.loseRed).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${diff >= 0 ? '+' : ''}$diff',
                          style: TextStyle(
                            color: diff >= 0 ? AppColors.winGreen : AppColors.loseRed,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '峰值: $maxMr',
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                  Text(
                    '谷底: $minMr',
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height - 80,
            width: double.infinity,
            child: CustomPaint(
              painter: _MrChartPainter(points: mrPoints, minVal: minMr, maxVal: maxMr),
            ),
          ),
        ],
      ),
    );
  }
}

class _MrChartPainter extends CustomPainter {
  final List<int> points;
  final int minVal;
  final int maxVal;

  _MrChartPainter({
    required this.points,
    required this.minVal,
    required this.maxVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final range = max(1, maxVal - minVal);
    final dx = size.width / (points.length - 1);

    final path = Path();
    final fillPath = Path();

    Offset getOffset(int i) {
      final normY = (points[i] - minVal) / range;
      final y = size.height - (normY * (size.height - 20) + 10);
      return Offset(i * dx, y);
    }

    final first = getOffset(0);
    path.moveTo(first.dx, first.dy);
    fillPath.moveTo(first.dx, size.height);
    fillPath.lineTo(first.dx, first.dy);

    for (var i = 1; i < points.length; i++) {
      final prev = getOffset(i - 1);
      final curr = getOffset(i);

      final midX = (prev.dx + curr.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
      fillPath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.accentNeonCyan.withOpacity(0.35),
        AppColors.accentNeonCyan.withOpacity(0.0),
      ],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.accentNeonCyan
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    final last = getOffset(points.length - 1);
    final glowPaint = Paint()
      ..color = AppColors.accentNeonCyan.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(last, 6, glowPaint);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(last, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _MrChartPainter oldDelegate) => true;
}
