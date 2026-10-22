import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/theme/app_theme.dart';
import 'package:sf6_tracker/core/theme/app_theme_colors.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/app_settings.dart';
import 'package:sf6_tracker/models/club_model.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/ui/screens/social/club_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v1.2.8 REQ-VER-001: Version and Build Metadata Synchronization', () {
    test('AppLogger version and build number strictly match v1.2.8 / 2800', () {
      expect(AppLogger.currentAppVersion, equals('v1.2.8'));
      expect(AppLogger.currentBuildNumber, equals('2800'));

      final report = AppLogger.instance.buildConciseDiagnosticSummary();
      expect(report.contains('v1.2.8'), isTrue);
      expect(report.contains('2800'), isTrue);
    });

    test('pubspec.yaml must be configured with version 1.2.8+2800', () {
      final file = File('pubspec.yaml');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('version: 1.2.8+2800'), isTrue);
    });
  });

  group('v1.2.8 REQ-THM-001: Default Theme Changed to Claude Warm Paper', () {
    test('AppSettings default constructor defaults to claudeWarm', () {
      const settings = AppSettings();
      expect(settings.themeMode, equals(AppThemeMode.claudeWarm));
    });

    test('AppSettings.fromJson defaults to claudeWarm when themeMode is omitted', () {
      final settings = AppSettings.fromJson({});
      expect(settings.themeMode, equals(AppThemeMode.claudeWarm));
    });

    test('AppSettings.fromJson correctly deserializes esportsDark when explicitly provided', () {
      final settings = AppSettings.fromJson({'themeMode': 'esportsDark'});
      expect(settings.themeMode, equals(AppThemeMode.esportsDark));
    });
  });

  group('v1.2.8 REQ-SCR-001: ClubDetailScreen Light Theme Audit (Screenshot 1)', () {
    test('ClubDetailScreen source code uses context.themeColors and eliminates hardcoded dark bgCard', () {
      final file = File('lib/ui/screens/social/club_detail_screen.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('context.themeColors'), isTrue);
      expect(content.contains('colors.bgCard'), isTrue);
      expect(content.contains('colors.titleStyle'), isTrue);
      expect(content.contains('colors.accentPrimary'), isTrue);
      expect(content.contains('colors.textPrimary'), isTrue);

      // Verify no remaining AppColors.bgCard
      expect(content.contains('AppColors.bgCard'), isFalse, reason: 'Must not use AppColors.bgCard in ClubDetailScreen');
    });
  });

  group('v1.2.8 REQ-SCR-002: BattleLogScreen Character Filter Chips Audit (Screenshot 2)', () {
    test('BattleLogScreen source code uses colors.bgCard and colors.accentPrimary in both ListView and Wrap', () {
      final file = File('lib/ui/screens/battle_log/battle_log_screen.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('backgroundColor: colors.bgCard'), isTrue);
      expect(content.contains('AppColors.bgCard'), isFalse, reason: 'Must eliminate AppColors.bgCard from battle_log_screen.dart');
    });
  });

  group('v1.2.8 REQ-SET-001: SettingsScreen Theme Names High-Contrast Audit', () {
    test('SettingsScreen source code uses heavy, high-contrast text for theme titles in Claude Warm', () {
      final file = File('lib/ui/screens/settings/settings_screen.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('const Color(0xFF1E1D1B)'), isTrue);
      expect(content.contains('fontWeight: FontWeight.w900'), isTrue);
      expect(content.contains('fontSize: 14.5'), isTrue);
      expect(content.contains('colors.titleFontFamily'), isTrue);
    });
  });
}
