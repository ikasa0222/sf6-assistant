import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/theme/app_theme_colors.dart';

class WinRateBar extends StatelessWidget {
  final double winRate;
  final int wins;
  final int total;
  final double height;
  final bool showLabels;

  const WinRateBar({
    super.key,
    required this.winRate,
    this.wins = 0,
    this.total = 0,
    this.height = 8.0,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final rate = (winRate / 100.0).clamp(0.0, 1.0);
    final losses = total - wins;
    final winColor = colors.accentTertiary;
    final loseColor = colors.accentError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${winRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: winColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (total > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '($wins W - $losses L)',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              if (total > 0)
                Text(
                  '总 $total 场',
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            height: height,
            width: double.infinity,
            color: total > 0 ? loseColor : colors.bgSecondary,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: rate,
              child: Container(
                color: winColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
