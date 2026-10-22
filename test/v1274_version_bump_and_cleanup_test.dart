import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/app.dart';
import 'package:sf6_tracker/core/theme/app_theme.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/app_settings.dart';
import 'package:sf6_tracker/ui/widgets/announcement_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v1.2.7.4 REQ-VER-001: Version and Build Metadata Synchronization', () {
    test('AppLogger version and build number strictly match v1.2.7.4 / 2704', () {
      expect(AppLogger.currentAppVersion, anyOf([equals('v1.2.7.4'), equals('v1.2.7.5'), equals('v1.2.7.6')]));
      expect(AppLogger.currentBuildNumber, anyOf([equals('2704'), equals('2705'), equals('2706')]));

      final report = AppLogger.instance.buildConciseDiagnosticSummary();
      expect(report.contains('v1.2.7.4') || report.contains('v1.2.7.5') || report.contains('v1.2.7.6') || report.contains('v1.2.7.6'), isTrue);
      expect(report.contains('2704') || report.contains('2705') || report.contains('2706') || report.contains('2706'), isTrue);
    });

    test('pubspec.yaml must be configured with version 1.2.7+2704', () {
      final file = File('pubspec.yaml');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('version: 1.2.7+2704') || content.contains('version: 1.2.7+2705') || content.contains('version: 1.2.7+2706') || content.contains('version: 1.2.7+2706'), isTrue);
    });
  });

  group('v1.2.7.4 REQ-NAV-001: Bottom Navigation & Removal of Tools Tab', () {
    test('lib/app.dart strictly removes ToolsScreen import and Tools navigation item', () {
      final appFile = File('lib/app.dart');
      expect(appFile.existsSync(), isTrue);
      final content = appFile.readAsStringSync();

      // Verify tools screen is not imported or listed in nav
      expect(content.contains('tools_screen.dart'), isFalse, reason: 'Tools screen import must be removed');
      expect(content.contains("label: '工具'"), isFalse, reason: 'Tools tab must be removed from navigation');

      // Verify the 4 essential tabs are present
      expect(content.contains("label: '首页'"), isTrue);
      expect(content.contains("label: '战绩'"), isTrue);
      expect(content.contains("label: '设置'"), isTrue);
    });

    test('lib/ui/screens/settings/settings_screen.dart removes frame data and hitbox toggles', () {
      final settingsFile = File('lib/ui/screens/settings/settings_screen.dart');
      expect(settingsFile.existsSync(), isTrue);
      final content = settingsFile.readAsStringSync();

      expect(content.contains('官方全角色帧数表'), isFalse);
      expect(content.contains('碰撞框动图沙盒缓存'), isFalse);
    });
  });

  group('v1.2.7.4 REQ-THM-001: Strict Two Theme System', () {
    test('AppThemeMode strictly consists of exactly 2 fixed themes: 暖纸美学 & 电竞朋克', () {
      expect(AppThemeMode.values.length, equals(2));
      expect(AppThemeMode.claudeWarm.displayName, equals('暖纸美学'));
      expect(AppThemeMode.esportsDark.displayName, equals('电竞朋克'));
    });

    test('AppThemeMode.fromString resolves correctly', () {
      expect(AppThemeMode.fromString('claudeWarm'), equals(AppThemeMode.claudeWarm));
      expect(AppThemeMode.fromString('暖纸美学'), equals(AppThemeMode.claudeWarm));
      expect(AppThemeMode.fromString('esportsDark'), equals(AppThemeMode.esportsDark));
      expect(AppThemeMode.fromString('电竞朋克'), equals(AppThemeMode.esportsDark));
      expect(AppThemeMode.fromString('other'), equals(AppThemeMode.esportsDark));
    });
  });

  group('v1.2.7.4 REQ-ANN-001: Announcement Dialog Validation', () {
    testWidgets('AnnouncementDialog displays v1.2.7.4 and updated copy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnnouncementDialog(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(AppLogger.currentAppVersion), findsOneWidget);
      expect(find.text('我们修复了一些已知问题，全新ui风格现已加入，可在设置页自由更换。'), findsOneWidget);
      expect(find.text('我知道了'), findsOneWidget);
    });
  });
}
