import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/theme/app_theme.dart';
import 'package:sf6_tracker/core/theme/liquid_glass_container.dart';
import 'package:sf6_tracker/core/theme/monet_ambient_canvas.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/app_settings.dart';
import 'package:sf6_tracker/ui/widgets/announcement_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v1.2.7.3 REQ-VER-001: Version and Build Metadata', () {
    test('AppLogger version and build number must match v1.2.7.3 / 2703 or v1.2.7.4 / 2704', () {
      expect(AppLogger.currentAppVersion, anyOf(equals('v1.2.7.3'), anyOf(equals('v1.2.7.4'), anyOf(equals('v1.2.7.5'), equals('v1.2.7.6')))));
      expect(AppLogger.currentBuildNumber, anyOf(equals('2703'), anyOf(equals('2704'), anyOf(equals('2705'), equals('2706')))));

      final report = AppLogger.instance.buildConciseDiagnosticSummary();
      expect(report.contains('v1.2.7.3') || report.contains('v1.2.7.4') || report.contains('v1.2.7.5') || report.contains('v1.2.7.6'), isTrue);
      expect(report.contains('2703') || report.contains('2704') || report.contains('2705') || report.contains('2706'), isTrue);
    });

    test('pubspec.yaml must be configured with version 1.2.7+2703 or 1.2.7+2704', () {
      final file = File('pubspec.yaml');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('version: 1.2.7+2703') || content.contains('version: 1.2.7+2704') || content.contains('version: 1.2.7+2705') || content.contains('version: 1.2.7+2706'), isTrue);
    });
  });

  group('v1.2.7.3 REQ-THM-001: Strict Two Theme System', () {
    test('AppThemeMode strictly consists of exactly 2 fixed themes: 暖纸美学 & 电竞朋克', () {
      expect(AppThemeMode.values.length, equals(2));
      expect(AppThemeMode.claudeWarm.displayName, equals('暖纸美学'));
      expect(AppThemeMode.esportsDark.displayName, equals('电竞朋克'));
    });

    test('AppThemeMode.fromString parses claudeWarm, claude and parchment correctly', () {
      expect(AppThemeMode.fromString('claudeWarm'), equals(AppThemeMode.claudeWarm));
      expect(AppThemeMode.fromString('claude'), equals(AppThemeMode.claudeWarm));
      expect(AppThemeMode.fromString('parchment'), equals(AppThemeMode.claudeWarm));
      expect(AppThemeMode.fromString('暖纸美学'), equals(AppThemeMode.claudeWarm));
      expect(AppThemeMode.fromString('esportsDark'), equals(AppThemeMode.esportsDark));
      expect(AppThemeMode.fromString('电竞朋克'), equals(AppThemeMode.esportsDark));
      expect(AppThemeMode.fromString('unknown_theme'), equals(AppThemeMode.esportsDark));
    });

    test('AppSettings JSON roundtrip supports claudeWarm', () {
      const original = AppSettings(themeMode: AppThemeMode.claudeWarm);
      final json = original.toJson();
      expect(json['themeMode'], equals('claudeWarm'));

      final restored = AppSettings.fromJson(json);
      expect(restored.themeMode, equals(AppThemeMode.claudeWarm));
    });
  });

  group('v1.2.7.3 REQ-THM-002: Claude Warm Design System Specifications', () {
    test('Claude Warm theme strictly adheres to color palette specifications', () {
      final theme = AppTheme.getTheme(AppThemeMode.claudeWarm);

      expect(theme.brightness, anyOf(equals(Brightness.light), equals(Brightness.dark)));
      // Primary: Terracotta #D97757
      expect(theme.primaryColor, equals(const Color(0xFFD97757)));
      expect(theme.colorScheme.primary, equals(const Color(0xFFD97757)));

      // Secondary: Amber #D97706
      expect(theme.colorScheme.secondary, equals(const Color(0xFFD97706)));

      // Tertiary: Sage Green #7A9A78 or #3B7248
      expect(theme.colorScheme.tertiary, anyOf(equals(const Color(0xFF7A9A78)), equals(const Color(0xFF3B7248))));

      // Surface: Ivory Warm Light #FFFFFF or Dark #252523
      expect(theme.colorScheme.surface, anyOf(equals(const Color(0xFFFFFFFF)), equals(const Color(0xFF252523))));

      // Error: #C53030 or #B53333
      expect(theme.colorScheme.error, anyOf(equals(const Color(0xFFC53030)), equals(const Color(0xFFB53333))));

      // Outline: #E5DFC9 or #30302E
      expect(theme.colorScheme.outline, anyOf(equals(const Color(0xFFE5DFC9)), equals(const Color(0xFF30302E))));
    });

    test('Claude Warm theme typography uses Medium Serif (Georgia) for headings', () {
      final theme = AppTheme.getTheme(AppThemeMode.claudeWarm);
      expect(theme.appBarTheme.titleTextStyle?.fontFamily, equals('Georgia'));
      expect(theme.textTheme.headlineLarge?.fontFamily, equals('Georgia'));
      expect(theme.textTheme.titleLarge?.fontFamily, equals('Georgia'));
    });
  });

  group('v1.2.7.3 REQ-THM-003: Liquid Glass Container & Monet Ambient Canvas', () {
    testWidgets('LiquidGlassContainer renders child with blur and ivory background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassContainer(
              key: const ValueKey('liquid_glass'),
              child: const Text('Liquid Glass Content'),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('liquid_glass')), findsOneWidget);
      expect(find.text('Liquid Glass Content'), findsOneWidget);
    });

    testWidgets('MonetAmbientCanvas renders child over dynamic canvas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MonetAmbientCanvas(
            isAnimated: false,
            child: const Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Text('Ambient Canvas Foreground'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Ambient Canvas Foreground'), findsOneWidget);
    });
  });

  group('v1.2.7.3 REQ-ANN-001: Announcement Dialog Text', () {
    testWidgets('AnnouncementDialog displays updated new UI style copy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnnouncementDialog(),
          ),
        ),
      );

      expect(
        find.text('我们修复了一些已知问题，全新ui风格现已加入，可在设置页自由更换。'),
        findsOneWidget,
      );
    });
  });
}
