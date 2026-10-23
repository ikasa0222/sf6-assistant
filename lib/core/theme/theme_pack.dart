import 'package:flutter/material.dart';
import 'package:sf6_tracker/models/app_settings.dart';

/// 抽象主题色彩与字体包接口 (Modular Theme Pack)
abstract class ThemePack {
  AppThemeMode get mode;
  bool get isClaudeWarm;

  // 画布与卡片背景
  Color get bgPrimary;
  Color get bgSecondary;
  Color get bgCard;
  Color get bgCardSolid;
  Color get bgCardHighlight;
  Color get bgInput;

  // 品牌主色与语义强调
  Color get accentPrimary;
  Color get accentSecondary;
  Color get accentWarning => accentSecondary;
  Color get accentTertiary;
  Color get accentError;
  Color get winGreen;
  Color get loseRed;
  Color get drawGray;

  // 段位专用色（在浅色/深色下自适应对比度）
  Color get rankRookie;
  Color get rankIron;
  Color get rankBronze;
  Color get rankSilver;
  Color get rankGold;
  Color get rankPlatinum;
  Color get rankDiamond;
  Color get rankMaster;
  Color get rankLegend;

  // 边框与微光
  Color get borderSubtle;
  Color get borderHighlight;
  Color get borderGlow;
  Color get divider;

  // 文字色彩
  Color get textPrimary;
  Color get textSecondary;
  Color get textTertiary;
  Color get textHighlight;

  // 字体规范
  String? get titleFontFamily;

  TextStyle titleStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
    double? letterSpacing,
  });

  TextStyle bodyStyle({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
  });

  BoxDecoration cardDecoration({
    BorderRadius? borderRadius,
    bool isHighlighted = false,
  });
}

/// 暖纸美学色彩与字体包 (Claude Warm Paper Theme Pack)
class ClaudeWarmThemePack implements ThemePack {
  const ClaudeWarmThemePack();

  @override
  AppThemeMode get mode => AppThemeMode.claudeWarm;

  @override
  bool get isClaudeWarm => true;

  // 1. 画布与容器背景（温润明亮羊皮纸浅底与象牙白卡片）
  @override
  Color get bgPrimary => const Color(0xFFFAF7F2); // 羊皮纸色
  @override
  Color get bgSecondary => const Color(0xFFF2ECE1); // 柔和暖奶油底色（副卡片/标签槽）
  @override
  Color get bgCard => const Color(0xFFFFFFFF); // 象牙暖白卡片
  @override
  Color get bgCardSolid => const Color(0xFFFFFFFF);
  @override
  Color get bgCardHighlight => const Color(0xFFFFFDF9);
  @override
  Color get bgInput => const Color(0xFFF2ECE1);

  // 2. 品牌主色与语义强调（Anthropic 暖调体系）
  @override
  Color get accentPrimary => const Color(0xFFD97757); // 赤陶红 Terracotta
  @override
  Color get accentSecondary => const Color(0xFFD97706); // 琥珀金黄 Amber
  @override
  Color get accentWarning => const Color(0xFFD97706);
  @override
  Color get accentTertiary => const Color(0xFF3B7248); // 森林鼠尾草绿 Sage
  @override
  Color get accentError => const Color(0xFFC53030); // 警示深红
  @override
  Color get winGreen => const Color(0xFF2E6930); // 高对比度深绿
  @override
  Color get loseRed => const Color(0xFFC53030); // 高对比度深红
  @override
  Color get drawGray => const Color(0xFF78766E);

  // 3. 段位色彩（针对浅色背景深度调优的高对比度色相）
  @override
  Color get rankRookie => const Color(0xFF546E7A);
  @override
  Color get rankIron => const Color(0xFF5D4037);
  @override
  Color get rankBronze => const Color(0xFF8D5325);
  @override
  Color get rankSilver => const Color(0xFF607D8B);
  @override
  Color get rankGold => const Color(0xFFB45309);
  @override
  Color get rankPlatinum => const Color(0xFF0E7490);
  @override
  Color get rankDiamond => const Color(0xFF0369A1);
  @override
  Color get rankMaster => const Color(0xFFB45309);
  @override
  Color get rankLegend => const Color(0xFFC2410C);

  // 4. 边框与微光分割线
  @override
  Color get borderSubtle => const Color(0xFFE5DFC9); // 极细暖奶油边框
  @override
  Color get borderHighlight => const Color(0xFFD97757);
  @override
  Color get borderGlow => const Color(0x33D97757);
  @override
  Color get divider => const Color(0xFFEAE4D5);

  // 5. 文字色彩（高对比度深墨炭黑与深暖灰，严禁发白）
  @override
  Color get textPrimary => const Color(0xFF1E1D1B); // 核心正文字：深墨炭黑
  @override
  Color get textSecondary => const Color(0xFF524E46); // 次级说明字：深暖灰
  @override
  Color get textTertiary => const Color(0xFF8C8578); // 辅助字：青铜深灰
  @override
  Color get textHighlight => const Color(0xFFD97757);

  // 6. 字体规范（Georgia 典雅书籍扉页衬线体）
  @override
  String? get titleFontFamily => 'Georgia';

  @override
  TextStyle titleStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Georgia',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      height: height ?? 1.35,
      letterSpacing: letterSpacing ?? -0.2,
    );
  }

  @override
  TextStyle bodyStyle({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textSecondary,
      height: height ?? 1.55,
    );
  }

  @override
  BoxDecoration cardDecoration({
    BorderRadius? borderRadius,
    bool isHighlighted = false,
  }) {
    final br = borderRadius ?? BorderRadius.circular(16);
    return BoxDecoration(
      color: bgCard,
      borderRadius: br,
      border: Border.all(
        color: isHighlighted ? accentPrimary.withOpacity(0.65) : borderSubtle,
        width: isHighlighted ? 1.5 : 1.0,
      ),
      boxShadow: [
        const BoxShadow(
          color: Color(0x0C402010),
          blurRadius: 14,
          spreadRadius: 0,
          offset: Offset(0, 4),
        ),
        if (isHighlighted)
          BoxShadow(
            color: accentPrimary.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
      ],
    );
  }
}

/// 电竞朋克色彩与字体包 (Esports Dark Punk Theme Pack)
class EsportsDarkThemePack implements ThemePack {
  const EsportsDarkThemePack();

  @override
  AppThemeMode get mode => AppThemeMode.esportsDark;

  @override
  bool get isClaudeWarm => false;

  // 1. 画布与容器背景（经典硬核暗黑）
  @override
  Color get bgPrimary => const Color(0xFF0D0E12);
  @override
  Color get bgSecondary => const Color(0xFF16181F);
  @override
  Color get bgCard => const Color(0xFF1E212B);
  @override
  Color get bgCardSolid => const Color(0xFF1E212B);
  @override
  Color get bgCardHighlight => const Color(0xFF262B37);
  @override
  Color get bgInput => const Color(0xFF13151B);

  // 2. 品牌主色与语义强调（荧光青、霓虹粉高对比）
  @override
  Color get accentPrimary => const Color(0xFF00E5FF); // 荧光青
  @override
  Color get accentSecondary => const Color(0xFFFFE600); // 荧光黄
  @override
  Color get accentWarning => const Color(0xFFFFE600);
  @override
  Color get accentTertiary => const Color(0xFF00FF7F); // 荧光绿
  @override
  Color get accentError => const Color(0xFFFF3366); // 霓虹红
  @override
  Color get winGreen => const Color(0xFF00E676);
  @override
  Color get loseRed => const Color(0xFFFF3366);
  @override
  Color get drawGray => const Color(0xFF9E9E9E);

  // 3. 段位色彩
  @override
  Color get rankRookie => const Color(0xFF78909C);
  @override
  Color get rankIron => const Color(0xFF8D6E63);
  @override
  Color get rankBronze => const Color(0xFFCD7F32);
  @override
  Color get rankSilver => const Color(0xFFB0BEC5);
  @override
  Color get rankGold => const Color(0xFFFFD54F);
  @override
  Color get rankPlatinum => const Color(0xFF4DD0E1);
  @override
  Color get rankDiamond => const Color(0xFF81D4FA);
  @override
  Color get rankMaster => const Color(0xFFFFAB00);
  @override
  Color get rankLegend => const Color(0xFFFF3D00);

  // 4. 边框与微光分割线
  @override
  Color get borderSubtle => const Color(0xFF2A2D3A);
  @override
  Color get borderHighlight => const Color(0xFF00E5FF);
  @override
  Color get borderGlow => const Color(0x3300E5FF);
  @override
  Color get divider => const Color(0xFF222530);

  // 5. 文字色彩
  @override
  Color get textPrimary => const Color(0xFFF5F5F7);
  @override
  Color get textSecondary => const Color(0xFF9E9EB2);
  @override
  Color get textTertiary => const Color(0xFF6B6E7E);
  @override
  Color get textHighlight => const Color(0xFF00E5FF);

  // 6. 字体规范
  @override
  String? get titleFontFamily => null;

  @override
  TextStyle titleStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      height: height ?? 1.2,
      letterSpacing: letterSpacing ?? 0.5,
    );
  }

  @override
  TextStyle bodyStyle({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textSecondary,
      height: height ?? 1.55,
    );
  }

  @override
  BoxDecoration cardDecoration({
    BorderRadius? borderRadius,
    bool isHighlighted = false,
  }) {
    final br = borderRadius ?? BorderRadius.circular(16);
    return BoxDecoration(
      color: bgCard,
      borderRadius: br,
      border: Border.all(
        color: isHighlighted ? accentPrimary.withOpacity(0.6) : borderSubtle,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
