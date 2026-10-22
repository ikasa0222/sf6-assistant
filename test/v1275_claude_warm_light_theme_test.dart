import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/theme/app_theme.dart';
import 'package:sf6_tracker/core/theme/app_theme_colors.dart';
import 'package:sf6_tracker/core/theme/liquid_glass_container.dart';
import 'package:sf6_tracker/core/theme/monet_ambient_canvas.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/app_settings.dart';
import 'package:sf6_tracker/ui/widgets/announcement_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v1.2.7.5 REQ-VER-001: Version and Build Metadata Synchronization', () {
    test('AppLogger version and build number strictly match v1.2.7.5 or v1.2.7.6', () {
      expect(AppLogger.currentAppVersion.startsWith('v1.2.7.'), isTrue);
      expect(int.parse(AppLogger.currentBuildNumber) >= 2705, isTrue);

      final report = AppLogger.instance.buildConciseDiagnosticSummary();
      expect(report.contains('v1.2.7.'), isTrue);
    });

    test('pubspec.yaml must be configured with version 1.2.7+2705 or newer', () {
      final file = File('pubspec.yaml');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains(RegExp(r'version: 1\.2\.7\+270[5-9]')), isTrue);
    });
  });

  group('v1.2.7.5 REQ-THM-001: Authentic Claude Warm Paper Light Theme System', () {
    test('Claude Warm theme strictly specifies Brightness.light and warm parchment palette', () {
      final theme = AppTheme.getTheme(AppThemeMode.claudeWarm);

      expect(theme.brightness, equals(Brightness.light));
      expect(theme.primaryColor, equals(const Color(0xFFD97757)));
      expect(theme.colorScheme.primary, equals(const Color(0xFFD97757)));
      expect(theme.colorScheme.surface, equals(const Color(0xFFFFFFFF)));
      expect(theme.colorScheme.onSurface, equals(const Color(0xFF1E1D1B)));
      expect(theme.colorScheme.outline, equals(const Color(0xFFE5DFC9)));
    });

    test('AppThemeColors defines pure warm ivory card, parchment canvas and high-contrast charcoal text', () {
      const colors = AppThemeColors(mode: AppThemeMode.claudeWarm);

      expect(colors.isClaudeWarm, isTrue);
      expect(colors.bgPrimary, equals(const Color(0xFFFAF7F2))); // Light parchment
      expect(colors.bgCard, equals(const Color(0xFFFFFFFF))); // Pure ivory white
      expect(colors.textPrimary, equals(const Color(0xFF1E1D1B))); // Deep warm charcoal ink
      expect(colors.accentPrimary, equals(const Color(0xFFD97757))); // Terracotta
      expect(colors.accentTertiary, equals(const Color(0xFF3B7248))); // Sage green
      expect(colors.accentSecondary, equals(const Color(0xFFD97706))); // Warm amber
    });

    test('MonetAmbientCanvas utilizes parchment light base (#FAF7F2)', () {
      final canvasFile = File('lib/core/theme/monet_ambient_canvas.dart');
      expect(canvasFile.existsSync(), isTrue);
      final content = canvasFile.readAsStringSync();
      expect(content.contains('0xFFFAF7F2'), isTrue);
      expect(content.contains('0xFF141413'), isFalse);
    });
  });

  group('v1.2.7.5 REQ-DOCK-001: Liquid Glass Dock for Both Themes & Settings Theming', () {
    test('lib/app.dart uses _buildLiquidGlassFloatingDock for both themes with null bottomNavigationBar', () {
      final appFile = File('lib/app.dart');
      expect(appFile.existsSync(), isTrue);
      final content = appFile.readAsStringSync();

      expect(content.contains('_buildLiquidGlassFloatingDock'), isTrue);
      expect(content.contains('bottomNavigationBar: null'), isTrue);
      expect(content.contains('extendBody: true'), isTrue);
    });

    test('lib/ui/screens/settings/settings_screen.dart uses context.themeColors and cardDecoration', () {
      final settingsFile = File('lib/ui/screens/settings/settings_screen.dart');
      expect(settingsFile.existsSync(), isTrue);
      final content = settingsFile.readAsStringSync();

      expect(content.contains('context.themeColors'), isTrue);
      expect(content.contains('colors.cardDecoration'), isTrue);
      expect(content.contains('0xFFFAF7F2'), isTrue);
    });
  });

  group('v1.2.7.5 REQ-ANN-001: Announcement Dialog Validation', () {
    testWidgets('AnnouncementDialog displays v1.2.7.5 and updated copy', (tester) async {
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
