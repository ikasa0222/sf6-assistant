import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/theme/theme_pack.dart';
import 'package:sf6_tracker/models/app_settings.dart';

/// 动态主题色彩与排版设计系统
///
/// 模块化设计：根据传入的 AppThemeMode 加载对应的 ThemePack：
/// - 暖纸美学：ClaudeWarmThemePack
/// - 电竞朋克：EsportsDarkThemePack
class AppThemeColors {
  final AppThemeMode mode;

  const AppThemeColors({required this.mode});

  static const AppThemeColors claudeWarm = AppThemeColors(mode: AppThemeMode.claudeWarm);
  static const AppThemeColors esportsDark = AppThemeColors(mode: AppThemeMode.esportsDark);

  ThemePack get pack => mode == AppThemeMode.claudeWarm
      ? const ClaudeWarmThemePack()
      : const EsportsDarkThemePack();

  bool get isClaudeWarm => pack.isClaudeWarm;

  // 1. 画布与容器背景
  Color get bgPrimary => pack.bgPrimary;
  Color get bgSecondary => pack.bgSecondary;
  Color get bgCard => pack.bgCard;
  Color get bgCardSolid => pack.bgCardSolid;
  Color get bgCardHighlight => pack.bgCardHighlight;
  Color get bgInput => pack.bgInput;

  // 2. 品牌主色与语义强调
  Color get accentPrimary => pack.accentPrimary;
  Color get accentSecondary => pack.accentSecondary;
  Color get accentWarning => pack.accentWarning;
  Color get accentTertiary => pack.accentTertiary;
  Color get accentError => pack.accentError;
  Color get winGreen => pack.winGreen;
  Color get loseRed => pack.loseRed;
  Color get drawGray => pack.drawGray;

  // 3. 段位色彩
  Color get rankRookie => pack.rankRookie;
  Color get rankIron => pack.rankIron;
  Color get rankBronze => pack.rankBronze;
  Color get rankSilver => pack.rankSilver;
  Color get rankGold => pack.rankGold;
  Color get rankPlatinum => pack.rankPlatinum;
  Color get rankDiamond => pack.rankDiamond;
  Color get rankMaster => pack.rankMaster;
  Color get rankLegend => pack.rankLegend;

  // 4. 边框与微光分割线
  Color get borderSubtle => pack.borderSubtle;
  Color get borderHighlight => pack.borderHighlight;
  Color get borderGlow => pack.borderGlow;
  Color get divider => pack.divider;

  // 5. 文字色彩
  Color get textPrimary => pack.textPrimary;
  Color get textSecondary => pack.textSecondary;
  Color get textTertiary => pack.textTertiary;
  Color get textHighlight => pack.textHighlight;

  // 6. 字体规范
  String? get titleFontFamily => pack.titleFontFamily;

  TextStyle titleStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return pack.titleStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle italicTitleStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: isClaudeWarm ? 'Georgia' : null,
      fontStyle: isClaudeWarm ? FontStyle.italic : FontStyle.normal,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      letterSpacing: -0.2,
    );
  }

  TextStyle bodyStyle({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
  }) {
    return pack.bodyStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // 7. 高级卡片装饰器
  BoxDecoration cardDecoration({
    BorderRadius? borderRadius,
    bool isHighlighted = false,
  }) {
    return pack.cardDecoration(
      borderRadius: borderRadius,
      isHighlighted: isHighlighted,
    );
  }

  // 快捷获取静态或上下文实例
  static AppThemeColors of(BuildContext context) {
    final theme = Theme.of(context);
    final isWarm = theme.brightness == Brightness.light || theme.primaryColor == const Color(0xFFD97757);
    return isWarm ? claudeWarm : esportsDark;
  }
}

extension AppThemeContextExt on BuildContext {
  AppThemeColors get themeColors => AppThemeColors.of(this);
}
