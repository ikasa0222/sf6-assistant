import 'package:flutter/material.dart';
import 'app_colors.dart';

enum RankTier {
  rookie,
  iron,
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  master,
  legend,
}

class Sf6Rank {
  final RankTier tier;
  final String nameZh;
  final String nameEn;
  final Color color;
  final int minLp;
  final int maxLp;
  final int star;
  final int nextRankLp;
  final String nextRankName;

  const Sf6Rank({
    required this.tier,
    required this.nameZh,
    required this.nameEn,
    required this.color,
    required this.minLp,
    required this.maxLp,
    this.star = 1,
    this.nextRankLp = 25000,
    this.nextRankName = '大师 (Master)',
  });

  String get displayName => star > 0 && tier != RankTier.master && tier != RankTier.legend && tier != RankTier.rookie
      ? '$nameZh $star星'
      : nameZh;

  double progressInTier(int currentLp) {
    if (tier == RankTier.master || tier == RankTier.legend) return 1.0;
    if (nextRankLp <= minLp) return 1.0;
    final p = (currentLp - minLp) / (maxLp - minLp + 1);
    return p.clamp(0.0, 1.0);
  }

  int lpNeeded(int currentLp) {
    if (tier == RankTier.master || tier == RankTier.legend) return 0;
    final diff = nextRankLp - currentLp;
    return diff > 0 ? diff : 0;
  }

  static Sf6Rank fromLpOrMr(int lp, {int? mr, int? rankPosition}) {
    if (rankPosition != null && rankPosition <= 500 && rankPosition > 0) {
      return const Sf6Rank(
        tier: RankTier.legend,
        nameZh: '传奇 (Top 500)',
        nameEn: 'Legend',
        color: AppColors.rankLegend,
        minLp: 25000,
        maxLp: 999999,
        star: 0,
      );
    }
    if ((mr != null && mr > 0) || lp >= 25000) {
      return const Sf6Rank(
        tier: RankTier.master,
        nameZh: '大师 (Master)',
        nameEn: 'Master',
        color: AppColors.rankMaster,
        minLp: 25000,
        maxLp: 999999,
        star: 0,
      );
    }

    // Diamond
    if (lp >= 23800) return const Sf6Rank(tier: RankTier.diamond, nameZh: '钻石', nameEn: 'Diamond 5', color: AppColors.rankDiamond, minLp: 23800, maxLp: 24999, star: 5, nextRankLp: 25000, nextRankName: '大师 (Master)');
    if (lp >= 22600) return const Sf6Rank(tier: RankTier.diamond, nameZh: '钻石', nameEn: 'Diamond 4', color: AppColors.rankDiamond, minLp: 22600, maxLp: 23799, star: 4, nextRankLp: 23800, nextRankName: '钻石 5星');
    if (lp >= 21400) return const Sf6Rank(tier: RankTier.diamond, nameZh: '钻石', nameEn: 'Diamond 3', color: AppColors.rankDiamond, minLp: 21400, maxLp: 22599, star: 3, nextRankLp: 22600, nextRankName: '钻石 4星');
    if (lp >= 20200) return const Sf6Rank(tier: RankTier.diamond, nameZh: '钻石', nameEn: 'Diamond 2', color: AppColors.rankDiamond, minLp: 20200, maxLp: 21399, star: 2, nextRankLp: 21400, nextRankName: '钻石 3星');
    if (lp >= 19000) return const Sf6Rank(tier: RankTier.diamond, nameZh: '钻石', nameEn: 'Diamond 1', color: AppColors.rankDiamond, minLp: 19000, maxLp: 20199, star: 1, nextRankLp: 20200, nextRankName: '钻石 2星');

    // Platinum
    if (lp >= 17800) return const Sf6Rank(tier: RankTier.platinum, nameZh: '白金', nameEn: 'Platinum 5', color: AppColors.rankPlatinum, minLp: 17800, maxLp: 18999, star: 5, nextRankLp: 19000, nextRankName: '钻石 1星');
    if (lp >= 16600) return const Sf6Rank(tier: RankTier.platinum, nameZh: '白金', nameEn: 'Platinum 4', color: AppColors.rankPlatinum, minLp: 16600, maxLp: 17799, star: 4, nextRankLp: 17800, nextRankName: '白金 5星');
    if (lp >= 15400) return const Sf6Rank(tier: RankTier.platinum, nameZh: '白金', nameEn: 'Platinum 3', color: AppColors.rankPlatinum, minLp: 15400, maxLp: 16599, star: 3, nextRankLp: 16600, nextRankName: '白金 4星');
    if (lp >= 14200) return const Sf6Rank(tier: RankTier.platinum, nameZh: '白金', nameEn: 'Platinum 2', color: AppColors.rankPlatinum, minLp: 14200, maxLp: 15399, star: 2, nextRankLp: 15400, nextRankName: '白金 3星');
    if (lp >= 13000) return const Sf6Rank(tier: RankTier.platinum, nameZh: '白金', nameEn: 'Platinum 1', color: AppColors.rankPlatinum, minLp: 13000, maxLp: 14199, star: 1, nextRankLp: 14200, nextRankName: '白金 2星');

    // Gold
    if (lp >= 12200) return const Sf6Rank(tier: RankTier.gold, nameZh: '黄金', nameEn: 'Gold 5', color: AppColors.rankGold, minLp: 12200, maxLp: 12999, star: 5, nextRankLp: 13000, nextRankName: '白金 1星');
    if (lp >= 11400) return const Sf6Rank(tier: RankTier.gold, nameZh: '黄金', nameEn: 'Gold 4', color: AppColors.rankGold, minLp: 11400, maxLp: 12199, star: 4, nextRankLp: 12200, nextRankName: '黄金 5星');
    if (lp >= 10600) return const Sf6Rank(tier: RankTier.gold, nameZh: '黄金', nameEn: 'Gold 3', color: AppColors.rankGold, minLp: 10600, maxLp: 11399, star: 3, nextRankLp: 11400, nextRankName: '黄金 4星');
    if (lp >= 9800) return const Sf6Rank(tier: RankTier.gold, nameZh: '黄金', nameEn: 'Gold 2', color: AppColors.rankGold, minLp: 9800, maxLp: 10599, star: 2, nextRankLp: 10600, nextRankName: '黄金 3星');
    if (lp >= 9000) return const Sf6Rank(tier: RankTier.gold, nameZh: '黄金', nameEn: 'Gold 1', color: AppColors.rankGold, minLp: 9000, maxLp: 9799, star: 1, nextRankLp: 9800, nextRankName: '黄金 2星');

    // Silver
    if (lp >= 8200) return const Sf6Rank(tier: RankTier.silver, nameZh: '白银', nameEn: 'Silver 5', color: AppColors.rankSilver, minLp: 8200, maxLp: 8999, star: 5, nextRankLp: 9000, nextRankName: '黄金 1星');
    if (lp >= 7400) return const Sf6Rank(tier: RankTier.silver, nameZh: '白银', nameEn: 'Silver 4', color: AppColors.rankSilver, minLp: 7400, maxLp: 8199, star: 4, nextRankLp: 8200, nextRankName: '白银 5星');
    if (lp >= 6600) return const Sf6Rank(tier: RankTier.silver, nameZh: '白银', nameEn: 'Silver 3', color: AppColors.rankSilver, minLp: 6600, maxLp: 7399, star: 3, nextRankLp: 7400, nextRankName: '白银 4星');
    if (lp >= 5800) return const Sf6Rank(tier: RankTier.silver, nameZh: '白银', nameEn: 'Silver 2', color: AppColors.rankSilver, minLp: 5800, maxLp: 6599, star: 2, nextRankLp: 6600, nextRankName: '白银 3星');
    if (lp >= 5000) return const Sf6Rank(tier: RankTier.silver, nameZh: '白银', nameEn: 'Silver 1', color: AppColors.rankSilver, minLp: 5000, maxLp: 5799, star: 1, nextRankLp: 5800, nextRankName: '白银 2星');

    // Bronze
    if (lp >= 3000) return const Sf6Rank(tier: RankTier.bronze, nameZh: '青铜', nameEn: 'Bronze', color: AppColors.rankBronze, minLp: 3000, maxLp: 4999, star: 1, nextRankLp: 5000, nextRankName: '白银 1星');

    // Iron
    if (lp >= 1200) return const Sf6Rank(tier: RankTier.iron, nameZh: '生铁', nameEn: 'Iron', color: AppColors.rankIron, minLp: 1200, maxLp: 2999, star: 1, nextRankLp: 3000, nextRankName: '青铜 1星');

    // Rookie
    return const Sf6Rank(
      tier: RankTier.rookie,
      nameZh: '新手',
      nameEn: 'Rookie',
      color: AppColors.rankRookie,
      minLp: 0,
      maxLp: 1199,
      star: 1,
      nextRankLp: 1200,
      nextRankName: '生铁 1星',
    );
  }
}
