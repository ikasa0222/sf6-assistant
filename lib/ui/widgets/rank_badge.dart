import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';

class RankBadge extends StatelessWidget {
  final int? lp;
  final int? mr;
  final int? rankPosition;
  final bool showPoints;
  final double scale;
  final Sf6Rank? rank;
  final bool showIconOnly;

  const RankBadge({
    super.key,
    this.lp,
    this.mr,
    this.rankPosition,
    this.showPoints = true,
    this.scale = 1.0,
    this.rank,
    this.showIconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRank = rank ?? Sf6Rank.fromLpOrMr(lp ?? 0, mr: mr, rankPosition: rankPosition);
    final isMasterOrLegend = effectiveRank.tier == RankTier.master || effectiveRank.tier == RankTier.legend;

    if (showIconOnly) {
      return Icon(
        isMasterOrLegend ? Icons.military_tech : Icons.shield,
        color: effectiveRank.color,
        size: 16 * scale,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: effectiveRank.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(
          color: effectiveRank.color.withOpacity(0.7),
          width: 1.2 * scale,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMasterOrLegend ? Icons.military_tech : Icons.shield,
            color: effectiveRank.color,
            size: 16 * scale,
          ),
          SizedBox(width: 4 * scale),
          Text(
            effectiveRank.nameEn.toUpperCase(),
            style: TextStyle(
              color: effectiveRank.color,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          if (showPoints && lp != null) ...[
            SizedBox(width: 6 * scale),
            Container(
              width: 1,
              height: 12 * scale,
              color: effectiveRank.color.withOpacity(0.4),
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
