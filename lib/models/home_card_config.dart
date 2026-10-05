import 'dart:convert';

class HomeCardConfig {
  final String key;
  final bool isVisible;

  const HomeCardConfig({
    required this.key,
    this.isVisible = true,
  });

  static const String keyHero = 'hero';
  static const String keyScoreChart = 'score_chart';
  static const String keyLadder = 'ladder';
  static const String keyRecentForm = 'recent_form';
  static const String keyPlayTime = 'play_time';
  static const String keyQuickStats = 'quick_stats';
  static const String keyRadar = 'radar';

  static String getCardNameZh(String key) {
    switch (key) {
      case keyHero:
        return '玩家主页资料';
      case keyScoreChart:
        return '排位分数走势';
      case keyLadder:
        return '角色天梯榜';
      case keyRecentForm:
        return '近期对局状态';
      case keyPlayTime:
        return '最爱角色与时长';
      case keyQuickStats:
        return '快速综合统计';
      case keyRadar:
        return '六维能力雷达';
      default:
        return key;
    }
  }

  static String getCardDescription(String key) {
    switch (key) {
      case keyHero:
        return '展示当前活跃账号、段位徽章与主玩角色信息（核心项不可隐藏）';
      case keyScoreChart:
        return '基于历史战绩绘制 LP / MR 动态涨跌走势折线图';
      case keyLadder:
        return '展示全角色排位积分榜与最高段位统计';
      case keyRecentForm:
        return '近 10 场对局胜负走势、胜率与连胜统计';
      case keyPlayTime:
        return '总对战时长、最常用角色使用率与对局盘数';
      case keyQuickStats:
        return '总对局数、综合胜率、常用对战模式数据概览';
      case keyRadar:
        return '进攻、防守、绿冲、立回等多维综合能力评估雷达';
      default:
        return '';
    }
  }

  static List<HomeCardConfig> get defaults => const [
    HomeCardConfig(key: keyHero, isVisible: true),
    HomeCardConfig(key: keyScoreChart, isVisible: true),
    HomeCardConfig(key: keyLadder, isVisible: true),
    HomeCardConfig(key: keyRecentForm, isVisible: true),
    HomeCardConfig(key: keyPlayTime, isVisible: true),
    HomeCardConfig(key: keyQuickStats, isVisible: true),
    HomeCardConfig(key: keyRadar, isVisible: true),
  ];

  HomeCardConfig copyWith({
    String? key,
    bool? isVisible,
  }) {
    return HomeCardConfig(
      key: key ?? this.key,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'isVisible': isVisible,
  };

  factory HomeCardConfig.fromJson(Map<String, dynamic> json) {
    return HomeCardConfig(
      key: json['key'] as String? ?? '',
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }
}
