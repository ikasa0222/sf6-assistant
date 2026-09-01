import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';

class RankBadge extends StatelessWidget {
  final int lp;
  final int? mr;
  final int? rankPosition;
  final bool showPoints;
  final double scale;

  const RankBadge({
    super.key,
    required this.lp,
    this.mr,
    this.rankPosition,
    this.showPoints = true,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final rank = Sf6Rank.fromLpOrMr(lp, mr: mr, rankPosition: rankPosition);
    final isMasterOrLegend = rank.tier == RankTier.master || rank.tier == RankTier.legend;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: rank.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(
          color: rank.color.withOpacity(0.7),
          width: 1.2 * scale,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMasterOrLegend ? Icons.military_tech : Icons.shield,
            color: rank.color,
            size: 16 * scale,
          ),
          SizedBox(width: 4 * scale),
          Text(
            rank.nameEn.toUpperCase(),
            style: TextStyle(
              color: rank.color,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          if (showPoints) ...[
            SizedBox(width: 6 * scale),
            Container(
              width: 1,
              height: 12 * scale,
              color: rank.color.withOpacity(0.4),
            ),
            SizedBox(width: 6 * scale),
            Text(
              isMasterOrLegend && mr != null && mr! > 0
                  ? '$mr MR'
                  : '$lp LP',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
