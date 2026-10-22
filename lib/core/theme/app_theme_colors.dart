import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/models/app_settings.dart';

/// 动态主题色彩与排版设计系统 (Web Design Engineer 规范)
///
/// 严格响应当前生效的主题（暖纸美学 vs 电竞朋克）：
/// - 暖纸美学：Anthropic Claude 暖调羊皮纸底色 + 莫奈流动呼吸漫游 + 象牙白卡片微光浮层 + Georgia 典雅衬线标题 + Apple 液态玻璃悬浮 Dock
/// - 电竞朋克：经典硬核暗黑底色 + 荧光青粉双色高对比霓虹
class AppThemeColors {
  final AppThemeMode mode;

  const AppThemeColors({required this.mode});

  bool get isClaudeWarm => mode == AppThemeMode.claudeWarm;

  // 1. 画布与容器背景
  Color get bgPrimary => isClaudeWarm ? const Color(0xFF141413) : AppColors.bgPrimary;
  Color get bgSecondary => isClaudeWarm ? const Color(0xFF1C1C1A) : AppColors.bgSecondary;
  Color get bgCard => isClaudeWarm ? const Color(0xF2222220) : AppColors.bgCard;
  Color get bgCardSolid => isClaudeWarm ? const Color(0xFF222220) : AppColors.bgCard;
  Color get bgCardHighlight => isClaudeWarm ? const Color(0xFF2B2B28) : AppColors.bgCardHighlight;
  Color get bgInput => isClaudeWarm ? const Color(0xFF171715) : AppColors.bgInput;

  // 2. 品牌与强调色（Anthropic 赤陶红 vs 荧光青）
  Color get accentPrimary => isClaudeWarm ? const Color(0xFFD97757) : AppColors.accentNeonCyan;
  Color get accentSecondary => isClaudeWarm ? const Color(0xFFD97706) : AppColors.accentNeonYellow;
  Color get accentTertiary => isClaudeWarm ? const Color(0xFF7A9A78) : AppColors.winGreen;
  Color get accentError => isClaudeWarm ? const Color(0xFFB53333) : AppColors.loseRed;

  // 3. 边框与微光分割线
  Color get borderSubtle => isClaudeWarm ? const Color(0xFF2F2F2C) : AppColors.borderSubtle;
  Color get borderHighlight => isClaudeWarm ? const Color(0xFFD97757) : AppColors.borderHighlight;
  Color get borderGlow => isClaudeWarm ? const Color(0x33D97757) : const Color(0x3300E5FF);
  Color get divider => isClaudeWarm ? const Color(0xFF2F2F2C) : AppColors.divider;

  // 4. 文字色彩规范（温润高对比度）
  Color get textPrimary => isClaudeWarm ? const Color(0xFFF7F5EE) : AppColors.textPrimary;
  Color get textSecondary => isClaudeWarm ? const Color(0xFFB3B0A6) : AppColors.textSecondary;
  Color get textTertiary => isClaudeWarm ? const Color(0xFF7A786F) : AppColors.textTertiary;
  Color get textHighlight => isClaudeWarm ? const Color(0xFFD97757) : AppColors.accentNeonCyan;

  // 5. 字体排版风格（Georgia 典雅衬线体）
  String? get titleFontFamily => isClaudeWarm ? 'Georgia' : null;

  TextStyle titleStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: isClaudeWarm ? 'Georgia' : null,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      height: height ?? (isClaudeWarm ? 1.35 : 1.2),
      letterSpacing: letterSpacing ?? (isClaudeWarm ? -0.2 : 0.5),
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
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textSecondary,
      height: height ?? 1.55,
    );
  }

  // 6. 高级卡片装饰器（Web Design 规范卡片质感）
  BoxDecoration cardDecoration({
    BorderRadius? borderRadius,
    bool isHighlighted = false,
  }) {
    final br = borderRadius ?? BorderRadius.circular(16);
    if (isClaudeWarm) {
      return BoxDecoration(
        color: bgCard,
        borderRadius: br,
        border: Border.all(
          color: isHighlighted ? accentPrimary.withOpacity(0.55) : borderSubtle,
          width: isHighlighted ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
          if (isHighlighted)
            BoxShadow(
              color: accentPrimary.withOpacity(0.08),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 0),
            ),
        ],
      );
    } else {
      return BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: br,
        border: Border.all(
          color: isHighlighted ? AppColors.accentNeonCyan.withOpacity(0.6) : AppColors.borderSubtle,
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

  // 快捷获取静态或上下文实例
  static AppThemeColors of(BuildContext context) {
    final theme = Theme.of(context);
    final isWarm = theme.primaryColor == const Color(0xFFD97757);
    return AppThemeColors(mode: isWarm ? AppThemeMode.claudeWarm : AppThemeMode.esportsDark);
  }
}

extension AppThemeContextExt on BuildContext {
  AppThemeColors get themeColors => AppThemeColors.of(this);
}
