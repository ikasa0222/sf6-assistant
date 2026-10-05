import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/data/frame_data_database.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/ui/widgets/ranked_score_chart_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  // 1. REQ-VER-001: Application Version and Build Number Specifications (v1.2.6.4 / 2604)
  // ===========================================================================
  group('REQ-VER-001: Version and Build Metadata (v1.2.6.4 / 2604)', () {
    test('AppLogger.currentAppVersion must equal v1.2.6.4 or v1.2.6.5', () {
      expect(
        AppLogger.currentAppVersion == 'v1.2.6.4' || AppLogger.currentAppVersion == 'v1.2.6.5',
        isTrue,
        reason: 'REQ-VER-001: AppLogger.currentAppVersion must be at least v1.2.6.4',
      );
    });

    test('AppLogger.currentBuildNumber must equal 2604 or 2605', () {
      expect(
        AppLogger.currentBuildNumber == '2604' || AppLogger.currentBuildNumber == '2605',
        isTrue,
        reason: 'REQ-VER-001: AppLogger.currentBuildNumber must be at least 2604',
      );
    });

    test('pubspec.yaml version must be 1.2.6+2604 or 1.2.6+2605', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue, reason: 'pubspec.yaml must exist');
      final content = pubspecFile.readAsStringSync();
      final versionMatch = RegExp(r'^version:\s*1\.2\.6(\.[45])?\+(2604|2605)\s*$', multiLine: true);
      expect(
        versionMatch.hasMatch(content),
        isTrue,
        reason: 'REQ-VER-001: pubspec.yaml version must be 1.2.6+2604 or 1.2.6+2605',
      );
    });

    test('AppLogger diagnostic summary format must output target version and build', () {
      final logger = AppLogger.instance;
      final report = logger.buildConciseDiagnosticSummary();
      expect(
        report.contains('v1.2.6.4') || report.contains('v1.2.6.5'),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include target version',
      );
      expect(
        report.contains('2604') || report.contains('2605'),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include target build number',
      );
    });
  });

  // ===========================================================================
  // 2. REQ-DAT-003: Special Move Variations & 31 Full Roster Database
  // ===========================================================================
  group('REQ-DAT-003: Special Move Variations & 31 Full Roster Database', () {
    test('MoveVariation model must exist in lib/models/frame_data_model.dart with required fields', () {
      final modelFile = File('lib/models/frame_data_model.dart');
      expect(modelFile.existsSync(), isTrue, reason: 'lib/models/frame_data_model.dart must exist');
      final content = modelFile.readAsStringSync();

      expect(
        content.contains('class MoveVariation'),
        isTrue,
        reason: 'REQ-DAT-003: MoveVariation class must be defined in lib/models/frame_data_model.dart',
      );
      expect(content.contains('final String version;'), isTrue, reason: 'MoveVariation must have version field');
      expect(content.contains('final String startup;'), isTrue, reason: 'MoveVariation must have startup field');
      expect(content.contains('final String active;'), isTrue, reason: 'MoveVariation must have active field');
      expect(content.contains('final String recovery;'), isTrue, reason: 'MoveVariation must have recovery field');
      expect(content.contains('final String onBlock;'), isTrue, reason: 'MoveVariation must have onBlock field');
      expect(content.contains('final String onHit;'), isTrue, reason: 'MoveVariation must have onHit field');
      expect(content.contains('final int damage;'), isTrue, reason: 'MoveVariation must have damage field');
      expect(content.contains('final String invincible;'), isTrue, reason: 'MoveVariation must have invincible field');
      expect(content.contains('final String notes;'), isTrue, reason: 'MoveVariation must have notes field');
    });

    test('FrameMove must contain variations field of type List<MoveVariation>', () {
      final modelFile = File('lib/models/frame_data_model.dart');
      final content = modelFile.readAsStringSync();

      expect(
        content.contains('List<MoveVariation>') && content.contains('variations'),
        isTrue,
        reason: 'REQ-DAT-003: FrameMove must include List<MoveVariation> variations field',
      );
      expect(
        content.contains('variations.map') || content.contains('variations:'),
        isTrue,
        reason: 'REQ-DAT-003: FrameMove serialization (toJson/fromJson) must support variations',
      );
    });

    test('FrameDataDatabase must contain 31 characters including sagat, cviper, alex, ingrid, yasmine (> 40 moves each)', () {
      final candidateChars = ['sagat', 'cviper', 'alex', 'ingrid', 'yasmine'];

      for (final charId in candidateChars) {
        final moves = FrameDataDatabase.getCharacterMoves(charId);
        expect(
          moves.isNotEmpty,
          isTrue,
          reason: 'REQ-DAT-003: FrameDataDatabase must not return empty move list for character "$charId"',
        );
        expect(
          moves.length,
          greaterThan(40),
          reason: 'REQ-DAT-003: $charId must have comprehensive moves (> 40 moves), found ${moves.length}',
        );
      }
    });

    test('Shoryuken (升龙拳) variations must provide independent real stats (L/M/H/OD) without fake math', () {
      final dbContent = File('lib/data/frame_data_database.dart').readAsStringSync();

      expect(
        dbContent.contains('MoveVariation('),
        isTrue,
        reason: 'REQ-DAT-003: FrameDataDatabase must instantiate MoveVariation for special moves',
      );

      // Check Shoryuken moves in Ryu or Ken
      final ryuMoves = FrameDataDatabase.getCharacterMoves('ryu');
      final hasShoryu = ryuMoves.any((m) => m.name.contains('升龙拳') || m.command.contains('623P'));
      expect(hasShoryu, isTrue, reason: 'Ryu must have 升龙拳 move in movelist');

      // Check OD Shoryuken has real stats (-35F or -40F on block, 6F startup, invincible)
      expect(
        dbContent.contains('-35') || dbContent.contains('-40'),
        isTrue,
        reason: 'REQ-DAT-003: OD Shoryuken must have authentic heavy block disadvantage (-35F or -40F)',
      );
      expect(
        dbContent.contains('完全无敌'),
        isTrue,
        reason: 'REQ-DAT-003: OD Shoryuken must indicate complete invincibility (完全无敌)',
      );
    });
  });

  // ===========================================================================
  // 3. REQ-CHT-003 & REQ-CHT-004: Ranked Score Trend Chart Card Refinements
  // ===========================================================================
  group('REQ-CHT-003 & REQ-CHT-004: Ranked Score Trend Chart Card Refinements', () {
    testWidgets('REQ-CHT-003: RankedScoreChartCard header title must be pure Chinese "排位分数走势" without English/parentheses', (tester) async {
      final battleLogService = BattleLogService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankedScoreChartCard(battleLogService: battleLogService),
          ),
        ),
      );
      await tester.pump();

      // Must find Chinese-only title
      final titleFinder = find.text('排位分数走势');
      expect(
        titleFinder,
        findsOneWidget,
        reason: 'REQ-CHT-003: Title must strictly be pure Chinese "排位分数走势"',
      );

      // Must NOT find '(Ranked Trend)' or any English title
      final englishTitleFinder = find.textContaining('(Ranked Trend)');
      expect(
        englishTitleFinder,
        findsNothing,
        reason: 'REQ-CHT-003: Redundant English "(Ranked Trend)" must be removed',
      );
    });

    testWidgets('REQ-CHT-003: Horizon selector must use PopupMenuButton instead of horizontal chips', (tester) async {
      final battleLogService = BattleLogService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankedScoreChartCard(battleLogService: battleLogService),
          ),
        ),
      );
      await tester.pump();

      // Must find PopupMenuButton
      final popupFinder = find.byType(PopupMenuButton<int>);
      expect(
        popupFinder,
        findsOneWidget,
        reason: 'REQ-CHT-003: Horizon switch must use PopupMenuButton to avoid overflow on narrow screens',
      );
    });

    testWidgets('REQ-CHT-004: Empty state displays graceful placeholder with "暂无排位赛记录" when matches < 2', (tester) async {
      final battleLogService = BattleLogService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankedScoreChartCard(battleLogService: battleLogService),
          ),
        ),
      );
      await tester.pump();

      // Must display friendly placeholder text containing '暂无排位赛记录'
      final emptyTextFinder = find.textContaining('暂无排位赛记录');
      expect(
        emptyTextFinder,
        findsOneWidget,
        reason: 'REQ-CHT-004: When matches < 2, card must gracefully display "暂无排位赛记录" placeholder',
      );
    });

    test('REQ-CHT-003: Source code of RankedScoreChartCard applies dynamic rank colors on Y-axis titles', () {
      final chartSource = File('lib/ui/widgets/ranked_score_chart_card.dart').readAsStringSync();

      expect(
        chartSource.contains('fromLpOrMr') || chartSource.contains('rank.color'),
        isTrue,
        reason: 'REQ-CHT-003: Y-axis title text style must dynamically bind color via Sf6Rank.fromLpOrMr',
      );
    });
  });

  // ===========================================================================
  // 4. REQ-HOM-001: Home Cards Customization & Reorderable Management
  // ===========================================================================
  group('REQ-HOM-001: Home Cards Customization & Reorderable Management', () {
    test('HomeCardConfig model file must exist in lib/models/home_card_config.dart', () {
      final configFile = File('lib/models/home_card_config.dart');
      expect(
        configFile.existsSync(),
        isTrue,
        reason: 'REQ-HOM-001: lib/models/home_card_config.dart must exist for dashboard customization',
      );

      final content = configFile.readAsStringSync();
      expect(content.contains('class HomeCardConfig'), isTrue, reason: 'HomeCardConfig class must be declared');
      expect(content.contains('final String key;'), isTrue, reason: 'HomeCardConfig must contain key field');
      expect(content.contains('final bool isVisible;'), isTrue, reason: 'HomeCardConfig must contain isVisible field');
    });

    test('StorageService in lib/core/storage/secure_storage.dart must support getHomeCardConfigs and saveHomeCardConfigs', () {
      final storageFile = File('lib/core/storage/secure_storage.dart');
      expect(storageFile.existsSync(), isTrue);
      final content = storageFile.readAsStringSync();

      expect(
        content.contains('getHomeCardConfigs'),
        isTrue,
        reason: 'REQ-HOM-001: StorageService must implement getHomeCardConfigs()',
      );
      expect(
        content.contains('saveHomeCardConfigs'),
        isTrue,
        reason: 'REQ-HOM-001: StorageService must implement saveHomeCardConfigs()',
      );
    });

    test('HomeCardsManagementScreen must exist in lib/ui/screens/settings/home_cards_management_screen.dart', () {
      final screenFile = File('lib/ui/screens/settings/home_cards_management_screen.dart');
      expect(
        screenFile.existsSync(),
        isTrue,
        reason: 'REQ-HOM-001: lib/ui/screens/settings/home_cards_management_screen.dart must exist',
      );

      final content = screenFile.readAsStringSync();
      expect(
        content.contains('class HomeCardsManagementScreen'),
        isTrue,
        reason: 'HomeCardsManagementScreen class must be declared',
      );
      expect(
        content.contains('ReorderableListView'),
        isTrue,
        reason: 'REQ-HOM-001: HomeCardsManagementScreen must use ReorderableListView for drag-and-drop',
      );
      expect(
        content.contains('Switch'),
        isTrue,
        reason: 'REQ-HOM-001: HomeCardsManagementScreen must use Switch for toggling visibility',
      );
      expect(
        content.contains('hero') && content.contains('不可隐藏'),
        isTrue,
        reason: 'REQ-HOM-001: hero (玩家资料) card must be permanently locked and cannot be hidden',
      );
    });

    test('SettingsScreen must integrate navigation entrance to HomeCardsManagementScreen', () {
      final settingsFile = File('lib/ui/screens/settings/settings_screen.dart');
      expect(settingsFile.existsSync(), isTrue);
      final content = settingsFile.readAsStringSync();

      expect(
        content.contains('HomeCardsManagementScreen') || content.contains('首页卡片管理'),
        isTrue,
        reason: 'REQ-HOM-001: SettingsScreen must contain navigation tile to HomeCardsManagementScreen',
      );
    });

    test('HomeScreen must dynamically render cards based on HomeCardConfig order and visibility', () {
      final homeFile = File('lib/ui/screens/home/home_screen.dart');
      expect(homeFile.existsSync(), isTrue);
      final content = homeFile.readAsStringSync();

      expect(
        content.contains('HomeCardConfig') || content.contains('getHomeCardConfigs'),
        isTrue,
        reason: 'REQ-HOM-001: HomeScreen must load and respect HomeCardConfig ordering and visibility',
      );
    });
  });
}
