import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';

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
    final rate = (winRate / 100.0).clamp(0.0, 1.0);
    final losses = total - wins;

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
                    style: const TextStyle(
                      color: AppColors.winGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (total > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '($wins W - $losses L)',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              if (total > 0)
                Text(
                  '总 $total 场',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                if (rate > 0)
                  Expanded(
                    flex: (rate * 100).round(),
                    child: Container(
                      color: AppColors.winGreen,
                    ),
                  ),
                if (rate < 1.0)
                  Expanded(
                    flex: ((1.0 - rate) * 100).round(),
                    child: Container(
                      color: AppColors.loseRed,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
