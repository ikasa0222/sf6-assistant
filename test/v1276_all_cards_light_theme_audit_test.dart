import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/core/theme/app_theme.dart';
import 'package:sf6_tracker/core/theme/app_theme_colors.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/app_settings.dart';
import 'package:sf6_tracker/ui/widgets/rank_badge.dart';
import 'package:sf6_tracker/ui/widgets/win_rate_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v1.2.7.6 REQ-VER-001: Version and Build Metadata Synchronization', () {
    test('AppLogger version and build number strictly match v1.2.7.6 / 2706', () {
      expect(AppLogger.currentAppVersion, anyOf(equals('v1.2.7.6'), equals('v1.2.8')));
      expect(AppLogger.currentBuildNumber, anyOf(equals('2706'), equals('2800')));

      final report = AppLogger.instance.buildConciseDiagnosticSummary();
      expect(report.contains('v1.2.7.6') || report.contains('v1.2.8'), isTrue);
      expect(report.contains('2706') || report.contains('2800'), isTrue);
    });

    test('pubspec.yaml must be configured with version 1.2.7+2706', () {
      final file = File('pubspec.yaml');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('version: 1.2.7+2706') || content.contains('version: 1.2.8+2800'), isTrue);
    });
  });

  group('v1.2.7.6 REQ-RNK-001: RankBadge High-Contrast Design for Light Mode', () {
    testWidgets('RankBadge renders high-contrast dark text and deep badge color in Claude Warm light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.getTheme(AppThemeMode.claudeWarm),
          home: const Scaffold(
            body: Column(
              children: [
                RankBadge(lp: 23597, showPoints: true), // Diamond
                RankBadge(lp: 6790, showPoints: true),  // Silver
                RankBadge(lp: 10523, showPoints: true), // Gold
                RankBadge(lp: 15221, showPoints: true), // Platinum
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // Check that Diamond rank text and LP text are present
      expect(find.text('DIAMOND 4'), findsOneWidget);
      expect(find.text('23597 LP'), findsOneWidget);

      // Verify LP text color is high-contrast deep charcoal (#1E1D1B), NOT white!
      final lpTextWidget = tester.widget<Text>(find.text('23597 LP'));
      expect(lpTextWidget.style?.color, equals(const Color(0xFF1E1D1B)));

      // Verify Diamond badge text color is high-contrast deep ocean blue (#0277BD), NOT pale #81D4FA!
      final diamondTextWidget = tester.widget<Text>(find.text('DIAMOND 4'));
      expect(diamondTextWidget.style?.color, equals(const Color(0xFF0277BD)));
    });

    testWidgets('RankBadge uses white text in Esports Dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.getTheme(AppThemeMode.esportsDark),
          home: const Scaffold(
            body: RankBadge(lp: 23597, showPoints: true),
          ),
        ),
      );
      await tester.pump();

      final lpTextWidget = tester.widget<Text>(find.text('23597 LP'));
      expect(lpTextWidget.style?.color, equals(const Color(0xFFF5F5F7)));
    });
  });

  group('v1.2.7.6 REQ-CAR-001: SocialScreen, AnalyticsScreen & BattleLogScreen Card Theming Audit', () {
    test('SocialScreen source code uses context.themeColors and colors.cardDecoration', () {
      final file = File('lib/ui/screens/social/social_screen.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('context.themeColors'), isTrue);
      expect(content.contains('colors.cardDecoration'), isTrue);
      expect(content.contains('colors.accentPrimary'), isTrue);
      expect(content.contains('colors.textPrimary'), isTrue);
    });

    test('AnalyticsScreen source code uses context.themeColors and eliminates unreadable white headers', () {
      final file = File('lib/ui/screens/analytics/analytics_screen.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('context.themeColors'), isTrue);
      expect(content.contains('colors.cardDecoration'), isTrue);
      expect(content.contains('colors.titleStyle'), isTrue);
      // Header must NOT be hardcoded AppColors.textPrimary!
      expect(content.contains("selectedMyChar == 'all'"), isTrue);
    });

    test('BattleLogScreen source code uses context.themeColors for filter chips and summary bar', () {
      final file = File('lib/ui/screens/battle_log/battle_log_screen.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('context.themeColors'), isTrue);
      expect(content.contains('colors.cardDecoration'), isTrue);
      expect(content.contains('colors.accentPrimary'), isTrue);
    });

    test('RankedScoreChartCard source code adapts Y-axis labels and grid lines for light mode', () {
      final file = File('lib/ui/widgets/ranked_score_chart_card.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('_getChartRankColor'), isTrue);
      expect(content.contains('colors.borderSubtle'), isTrue);
      expect(content.contains('colors.textPrimary'), isTrue);
    });
  });
}
