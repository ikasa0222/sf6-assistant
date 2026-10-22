import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/theme/app_theme_colors.dart';

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

  Color _getBadgeRankColor(Sf6Rank effectiveRank, bool isLightMode) {
    if (!isLightMode) return effectiveRank.color;
    switch (effectiveRank.tier) {
      case RankTier.legend:
        return const Color(0xFFC62828);
      case RankTier.master:
        return const Color(0xFFC67C00);
      case RankTier.diamond:
        return const Color(0xFF0277BD);
      case RankTier.platinum:
        return const Color(0xFF00838F);
      case RankTier.gold:
        return const Color(0xFFB78103);
      case RankTier.silver:
        return const Color(0xFF455A64);
      case RankTier.bronze:
        return const Color(0xFF6D4C41);
      case RankTier.iron:
        return const Color(0xFF4E342E);
      case RankTier.rookie:
        return const Color(0xFF616161);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isLight = colors.isClaudeWarm;
    final effectiveRank = rank ?? Sf6Rank.fromLpOrMr(lp ?? 0, mr: mr, rankPosition: rankPosition);
    final isMasterOrLegend = effectiveRank.tier == RankTier.master || effectiveRank.tier == RankTier.legend;
    final badgeColor = _getBadgeRankColor(effectiveRank, isLight);

    if (showIconOnly) {
      return Icon(
        isMasterOrLegend ? Icons.military_tech : Icons.shield,
        color: badgeColor,
        size: 16 * scale,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: isLight ? badgeColor.withOpacity(0.08) : effectiveRank.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(
          color: isLight ? badgeColor.withOpacity(0.45) : effectiveRank.color.withOpacity(0.7),
          width: 1.2 * scale,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMasterOrLegend ? Icons.military_tech : Icons.shield,
            color: badgeColor,
            size: 16 * scale,
          ),
          SizedBox(width: 4 * scale),
          Text(
            effectiveRank.nameEn.toUpperCase(),
            style: TextStyle(
              color: badgeColor,
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
              color: isLight ? colors.borderSubtle : effectiveRank.color.withOpacity(0.4),
            ),
            SizedBox(width: 6 * scale),
            Text(
              isMasterOrLegend && mr != null && mr! > 0
                  ? '$mr MR'
                  : '$lp LP',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 12 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
