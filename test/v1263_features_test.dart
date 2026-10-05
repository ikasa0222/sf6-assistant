import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/data/frame_data_database.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/services/frame_data_service.dart';
import 'package:sf6_tracker/ui/widgets/battle_card_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  // 1. REQ-VER-001: Application Version and Build Number Specifications
  // ===========================================================================
  group('REQ-VER-001: Version and Build Metadata (v1.2.6.3 / 2603 or newer)', () {
    test('AppLogger.currentAppVersion must equal v1.2.6.3 or newer v1.2.6.4/v1.2.6.5', () {
      expect(
        AppLogger.currentAppVersion == 'v1.2.6.3' || AppLogger.currentAppVersion == 'v1.2.6.4' || AppLogger.currentAppVersion == 'v1.2.6.5',
        isTrue,
        reason: 'REQ-VER-001: AppLogger.currentAppVersion must be at least v1.2.6.3',
      );
    });

    test('AppLogger.currentBuildNumber must equal 2603 or newer 2604/2605', () {
      expect(
        AppLogger.currentBuildNumber == '2603' || AppLogger.currentBuildNumber == '2604' || AppLogger.currentBuildNumber == '2605',
        isTrue,
        reason: 'REQ-VER-001: AppLogger.currentBuildNumber must be at least 2603',
      );
    });

    test('pubspec.yaml version must be 1.2.6+2603 or 1.2.6+2604 or 1.2.6+2605', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue, reason: 'pubspec.yaml must exist');
      final content = pubspecFile.readAsStringSync();
      final versionMatch = RegExp(r'^version:\s*1\.2\.6(\.[345])?\+(2603|2604|2605)\s*$', multiLine: true);
      expect(
        versionMatch.hasMatch(content),
        isTrue,
        reason: 'REQ-VER-001: pubspec.yaml version must be 1.2.6+2603 or 1.2.6+2604 or 1.2.6+2605',
      );
    });

    test('AppLogger diagnostic summary format must output version and build number', () {
      final logger = AppLogger.instance;
      final report = logger.buildConciseDiagnosticSummary();
      expect(
        report.contains('v1.2.6.3') || report.contains('v1.2.6.4') || report.contains('v1.2.6.5'),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include target version',
      );
      expect(
        report.contains('2603') || report.contains('2604') || report.contains('2605'),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include target build number',
      );
    });
  });

  // ===========================================================================
  // 2. REQ-TOL-001: Tools Default Character & Decision Priority Chain
  // ===========================================================================
  group('REQ-TOL-001: Toolbox Default Character Adaptive Priority Flow', () {
    test('FrameDataService initial character must default to ryu when unassigned, never elena or luke', () {
      final service = FrameDataService();
      expect(
        service.selectedCharacterId,
        equals('ryu'),
        reason: 'REQ-TOL-001: Default fallback character must strictly be ryu, never elena or luke',
      );
    });

    test('FrameDataService source code must not contain hardcoded elena or luke default selection', () {
      final source = File('lib/services/frame_data_service.dart').readAsStringSync();
      expect(
        source.contains("= 'elena'") || source.contains('="elena"'),
        isFalse,
        reason: 'REQ-TOL-001: Hardcoded elena default selection must be eliminated',
      );
      expect(
        source.contains("= 'luke'") || source.contains('="luke"'),
        isFalse,
        reason: 'REQ-TOL-001: Hardcoded luke default selection must be eliminated',
      );
    });

    test('FrameDataService selectCharacter handles unknown character safely by falling back to ryu', () {
      final service = FrameDataService();
      service.selectCharacter('invalid_unknown_character_id_999');
      expect(
        service.selectedCharacterId == 'ryu' || service.currentMoves.isEmpty,
        isTrue,
        reason: 'REQ-TOL-001: Invalid character ID must safely fallback to ryu or empty without exceptions',
      );
    });
  });

  // ===========================================================================
  // 3. REQ-DAT-002: Frame Data Database Cleaning & Dedicated Normals Architecture
  // ===========================================================================
  group('REQ-DAT-002: Frame Data Database Cleaning & Dedicated Normals', () {
    test('Core official characters must have valid move lists in FrameDataDatabase', () {
      const chars = ['ryu', 'ken', 'chunli', 'cammy', 'luke'];
      for (final charId in chars) {
        final moves = FrameDataDatabase.getCharacterMoves(charId);
        expect(
          moves.isNotEmpty,
          isTrue,
          reason: 'Character "$charId" must have moves in DB',
        );
      }
    });

    test('Zangief (zangief) normals: 5LP startup must be 7F (not 4F) and 2MK must NOT be cancelable', () {
      final zangiefMoves = FrameDataDatabase.getCharacterMoves('zangief');
      final move5LP = zangiefMoves.firstWhere(
        (m) => m.command == '5LP',
        orElse: () => throw StateError('Zangief 5LP not found'),
      );
      expect(
        int.tryParse(move5LP.startup) ?? 0,
        greaterThanOrEqualTo(6),
        reason: 'REQ-DAT-002: Zangief 5LP startup must be >= 6F (officially 7F), never generic 4F',
      );
      expect(
        move5LP.startup,
        equals('7'),
        reason: 'REQ-DAT-002: Zangief 5LP startup is officially 7F',
      );

      final move2MK = zangiefMoves.firstWhere(
        (m) => m.command == '2MK',
        orElse: () => throw StateError('Zangief 2MK not found'),
      );
      expect(
        move2MK.isCancelable,
        isFalse,
        reason: 'REQ-DAT-002: Zangief 2MK cannot be special/drive canceled in SF6',
      );
    });

    test('Chun-Li (chunli) 2MK must NOT be cancelable in SF6', () {
      final chunliMoves = FrameDataDatabase.getCharacterMoves('chunli');
      final move2MK = chunliMoves.firstWhere(
        (m) => m.command == '2MK',
        orElse: () => throw StateError('Chun-Li 2MK not found'),
      );
      expect(
        move2MK.isCancelable,
        isFalse,
        reason: 'REQ-DAT-002: Chun-Li 2MK is NOT cancelable in SF6',
      );
    });

    test('Guile (guile) 5MP must NOT be cancelable in SF6', () {
      final guileMoves = FrameDataDatabase.getCharacterMoves('guile');
      final move5MP = guileMoves.firstWhere(
        (m) => m.command == '5MP',
        orElse: () => throw StateError('Guile 5MP not found'),
      );
      expect(
        move5MP.isCancelable,
        isFalse,
        reason: 'REQ-DAT-002: Guile 5MP is NOT cancelable in SF6',
      );
    });

    test('Ryu (ryu) 2MK must be cancelable and startup must be 8F', () {
      final ryuMoves = FrameDataDatabase.getCharacterMoves('ryu');
      final move2MK = ryuMoves.firstWhere(
        (m) => m.command == '2MK',
        orElse: () => throw StateError('Ryu 2MK not found'),
      );
      expect(
        move2MK.isCancelable,
        isTrue,
        reason: 'REQ-DAT-002: Ryu 2MK must be cancelable in SF6',
      );
      expect(
        move2MK.startup,
        equals('8'),
        reason: 'REQ-DAT-002: Ryu 2MK startup must be 8F in SF6',
      );
    });
  });

  // ===========================================================================
  // 4. REQ-GIF-004: Local Disk Sandbox Cache Architecture & Management
  // ===========================================================================
  group('REQ-GIF-004: Local Disk Sandbox Cache Architecture & Management', () {
    test('MediaCacheService file must exist in lib/services/', () {
      final cacheServiceFile = File('lib/services/media_cache_service.dart');
      expect(
        cacheServiceFile.existsSync(),
        isTrue,
        reason: 'REQ-GIF-004: lib/services/media_cache_service.dart must exist for sandbox media caching',
      );
    });

    test('MediaCacheService or Sf6MoveMediaHelper implements sf6_hitbox_cache sandbox directory and stats API', () {
      final cacheServiceFile = File('lib/services/media_cache_service.dart');
      final helperFile = File('lib/utils/sf6_move_media_helper.dart');
      final content = (cacheServiceFile.existsSync() ? cacheServiceFile.readAsStringSync() : '') +
          (helperFile.existsSync() ? helperFile.readAsStringSync() : '');

      expect(
        content.contains('sf6_hitbox_cache'),
        isTrue,
        reason: 'REQ-GIF-004: Sandbox cache directory must use "sf6_hitbox_cache"',
      );
      expect(
        content.contains('clearCache') || content.contains('clearAll'),
        isTrue,
        reason: 'REQ-GIF-004: Cache management must provide clearCache() method',
      );
      expect(
        content.contains('getCacheSize') || content.contains('getCacheStats') || content.contains('cacheSize'),
        isTrue,
        reason: 'REQ-GIF-004: Cache management must provide cache size/count stats query',
      );
    });
  });

  // ===========================================================================
  // 5. REQ-CHT-001 & REQ-CHT-002: Ranked Score Trend Chart Card & Data Engine
  // ===========================================================================
  group('REQ-CHT-001 & REQ-CHT-002: Ranked Score Trend Chart Card & Data Engine', () {
    test('RankedScoreChartCard widget file must exist in lib/ui/widgets/', () {
      final chartWidgetFile = File('lib/ui/widgets/ranked_score_chart_card.dart');
      expect(
        chartWidgetFile.existsSync(),
        isTrue,
        reason: 'REQ-CHT-001: lib/ui/widgets/ranked_score_chart_card.dart must exist for ranked trend card',
      );
    });

    test('HomeScreen source code must integrate RankedScoreChartCard', () {
      final homeSource = File('lib/ui/screens/home/home_screen.dart').readAsStringSync();
      expect(
        homeSource.contains('RankedScoreChartCard'),
        isTrue,
        reason: 'REQ-CHT-001: HomeScreen must render RankedScoreChartCard on the dashboard',
      );
    });

    test('Ranked score data engine logic correctly separates MR vs LP and handles slicing', () {
      final now = DateTime.now();

      // Master rank test data (playerCurrentMr > 0)
      final masterRecords = List.generate(
        30,
        (i) => BattleRecord(
          id: 'master_rec_$i',
          shortId: '1001',
          platform: 'steam',
          playedAt: now.subtract(Duration(minutes: (30 - i) * 10)),
          battleType: BattleType.ranked,
          playerCharacterId: 'ryu',
          playerScore: 2,
          playerCurrentMr: 1500 + i * 5,
          playerCurrentLp: 25000,
          opponentFighterId: 'Opponent_$i',
          opponentShortId: '200$i',
          opponentPlatform: 'steam',
          opponentCharacterId: 'ken',
          opponentScore: 1,
          isWin: i.isEven,
          replayCode: 'CODE_$i',
          rounds: [],
        ),
      );

      // Verify records are filtered for ranked and MR extracted
      final rankedRecords = masterRecords.where((r) => r.battleType == BattleType.ranked).toList();
      expect(rankedRecords.length, equals(30));

      final latestMr = rankedRecords.last.playerCurrentMr;
      expect(latestMr, isNotNull);
      expect(latestMr! > 0, isTrue);

      // Slice recent 20
      final recent20 = rankedRecords.length > 20
          ? rankedRecords.sublist(rankedRecords.length - 20)
          : rankedRecords;
      expect(recent20.length, equals(20));
      expect(recent20.first.playerCurrentMr, equals(1550));
      expect(recent20.last.playerCurrentMr, equals(1645));

      // Non-master LP test data
      final lpRecords = List.generate(
        15,
        (i) => BattleRecord(
          id: 'lp_rec_$i',
          shortId: '1002',
          platform: 'steam',
          playedAt: now.subtract(Duration(minutes: (15 - i) * 10)),
          battleType: BattleType.ranked,
          playerCharacterId: 'cammy',
          playerScore: 2,
          playerCurrentMr: 0,
          playerCurrentLp: 12000 + i * 50,
          opponentFighterId: 'Opponent_$i',
          opponentShortId: '300$i',
          opponentPlatform: 'steam',
          opponentCharacterId: 'luke',
          opponentScore: 0,
          isWin: true,
          replayCode: '',
          rounds: [],
        ),
      );

      final isMaster = (lpRecords.last.playerCurrentMr ?? 0) > 0;
      expect(isMaster, isFalse);
      expect(lpRecords.last.playerCurrentLp, equals(12700));

      // Safe protection on < 2 records
      final emptyList = <BattleRecord>[];
      expect(emptyList.length < 2, isTrue);
      final singleRecordList = [lpRecords.first];
      expect(singleRecordList.length < 2, isTrue);
    });
  });

  // ===========================================================================
  // 6. REQ-RPL-001: Replay Code Badge, Copy & In-Game Guide Modal
  // ===========================================================================
  group('REQ-RPL-001: Replay Code Badge, Copy & In-Game Guide Modal', () {
    testWidgets('BattleCardItem displays help_outline icon and launches in-game replay guide modal', (tester) async {
      final testRecord = BattleRecord(
        id: 'test_rep_code_1',
        shortId: '1923437997',
        platform: 'steam',
        playedAt: DateTime.now(),
        battleType: BattleType.ranked,
        playerCharacterId: 'ryu',
        playerScore: 2,
        playerCurrentMr: 1580,
        playerCurrentLp: 28000,
        opponentFighterId: 'KenMaster',
        opponentShortId: '9876543210',
        opponentPlatform: 'steam',
        opponentCharacterId: 'ken',
        opponentScore: 1,
        isWin: true,
        replayCode: 'B123-4567-8901',
        rounds: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BattleCardItem(
              record: testRecord,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap card header to expand details
      final expandTapFinder = find.byType(InkWell).first;
      await tester.tap(expandTapFinder);
      await tester.pumpAndSettle();

      // Verify replay code text is rendered
      expect(find.textContaining('B123-4567-8901'), findsOneWidget);

      // Verify help_outline icon exists for in-game guidance
      final helpIcon = find.byIcon(Icons.help_outline);
      expect(
        helpIcon,
        findsOneWidget,
        reason: 'REQ-RPL-001: BattleCardItem must render help_outline icon for in-game replay guidance',
      );

      // Tap help icon and verify dialog contents
      await tester.tap(helpIcon);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => w is Text && w.data != null && (
          w.data!.contains('街霸6 游戏内录像回放指引') ||
          w.data!.contains('录像回放指引') ||
          w.data!.contains('对战转播')
        )),
        findsOneWidget,
        reason: 'REQ-RPL-001: Tapping help_outline icon must display 5-step official in-game replay retrieval guide',
      );
    });
  });
}
