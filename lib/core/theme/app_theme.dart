import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/models/app_settings.dart';

class AppTheme {
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.claudeWarm:
        return _claudeWarmTheme;
      case AppThemeMode.esportsDark:
        return _esportsDarkTheme;
    }
  }

  /// Anthropic Claude 暖纸美学主题 (Parchment & Liquid Glass - Light Aesthetic)
  ///
  /// 羊皮纸温润明亮浅色底 (#FAF7F2)、纯净象牙白浮层卡片 (#FFFFFF)、赤陶红主色 (#D97757)、
  /// 典雅衬线标题 (Georgia) 与苹果液态玻璃质感悬浮 Dock。
  static final ThemeData _claudeWarmTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    primaryColor: const Color(0xFFD97757),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFD97757), // 赤陶红 Terracotta
      secondary: Color(0xFFD97706), // 琥珀黄 Amber
      tertiary: Color(0xFF3B7248), // 森林鼠尾草绿 Sage
      surface: Color(0xFFFFFFFF), // 象牙暖白 Ivory Card
      error: Color(0xFFC53030), // 警示深红
      onPrimary: Colors.white,
      onSurface: Color(0xFF1E1D1B), // 暖深炭黑正文
      onSurfaceVariant: Color(0xFF635F56), // 暖咖灰辅助字
      outline: Color(0xFFE5DFC9), // 极细暖奶油边框
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5DFC9), width: 1.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: Color(0xFF1E1D1B),
      ),
      iconTheme: IconThemeData(color: Color(0xFF1E1D1B)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFAF7F2),
      selectedItemColor: Color(0xFFD97757),
      unselectedItemColor: Color(0xFF7A756D),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEAE4D5),
      thickness: 1,
      space: 16,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5DFC9), width: 1.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2ECE1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5DFC9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5DFC9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD97757), width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF969085), fontSize: 14),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Georgia', color: Color(0xFFF5F4EE), fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontFamily: 'Georgia', color: Color(0xFFF5F4EE), fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontFamily: 'Georgia', color: Color(0xFFF5F4EE), fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Color(0xFFF5F4EE), fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: Color(0xFFF5F4EE), height: 1.6),
      bodyMedium: TextStyle(color: Color(0xFFB0AEA5), height: 1.6),
      bodySmall: TextStyle(color: Color(0xFF78766E), height: 1.5),
    ),
  );

  static final ThemeData _esportsDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgPrimary,
    primaryColor: AppColors.accentNeonCyan,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentNeonCyan,
      secondary: AppColors.accentNeonPink,
      surface: AppColors.bgCard,
      error: AppColors.loseRed,
      onPrimary: Colors.black,
      onSurface: AppColors.textPrimary,
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgSecondary,
      selectedItemColor: AppColors.accentNeonCyan,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 16,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accentNeonCyan, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
    ),
  );

  static final ThemeData _streetNeonTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF090A0F),
    primaryColor: AppColors.accentNeonPink,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentNeonPink,
      secondary: AppColors.accentNeonYellow,
      surface: Color(0xFF141622),
      error: AppColors.loseRed,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF141622),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF333852), width: 1.2),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF090A0F),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: 1.0,
        color: AppColors.accentNeonPink,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF10121A),
      selectedItemColor: AppColors.accentNeonPink,
      unselectedItemColor: Color(0xFF70758F),
      type: BottomNavigationBarType.fixed,
    ),
  );

  static final ThemeData _materialYouTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: const Color(0xFF3F51B5),
    scaffoldBackgroundColor: const Color(0xFF121316),
  );
}
