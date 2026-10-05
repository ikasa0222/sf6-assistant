import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/services/frame_data_service.dart';
import 'package:sf6_tracker/ui/screens/tools/movelist_screen.dart';
import 'package:sf6_tracker/ui/widgets/move_action_preview.dart';
import 'package:sf6_tracker/ui/widgets/move_detail_modal.dart';
import 'package:sf6_tracker/utils/sf6_move_media_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  // 1. REQ-VER-001: Application Version and Build Metadata Specifications
  // ===========================================================================
  group('REQ-VER-001: Application Version and Build Number (v1.2.6.2 or higher)', () {
    test('AppLogger.currentAppVersion must equal v1.2.6.2 or higher', () {
      expect(
        AppLogger.currentAppVersion.startsWith('v1.2.6'),
        isTrue,
        reason: 'REQ-VER-001: AppLogger.currentAppVersion must be at least v1.2.6.2',
      );
    });

    test('AppLogger.currentBuildNumber must equal 2602 or higher', () {
      expect(
        int.parse(AppLogger.currentBuildNumber) >= 2602,
        isTrue,
        reason: 'REQ-VER-001: AppLogger.currentBuildNumber must be at least 2602',
      );
    });

    test('pubspec.yaml version must be 1.2.6+2602 or higher', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue, reason: 'pubspec.yaml must exist');
      final content = pubspecFile.readAsStringSync();
      final versionMatch = RegExp(r'^version:\s*1\.2\.6(\.[2345])?\+260[2345]\s*$', multiLine: true);
      expect(
        versionMatch.hasMatch(content),
        isTrue,
        reason: 'REQ-VER-001: pubspec.yaml version must be 1.2.6+2602 or higher',
      );
    });

    test('AppLogger diagnostic summary format must output target version and build', () {
      final logger = AppLogger.instance;
      final report = logger.buildConciseDiagnosticSummary();
      expect(
        report.contains('v1.2.6'),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include version v1.2.6',
      );
      expect(
        report.contains('2602') || report.contains('2603') || report.contains('2604') || report.contains('2605'),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include build number',
      );
    });
  });

  // ===========================================================================
  // 2. REQ-COS-001 & REQ-COS-002: Accurate Resource Gauge Indicators (OD vs Normal vs SA)
  // ===========================================================================
  group('REQ-COS-001 & REQ-COS-002: Resource Consumption Indicators (Movelist & Modal)', () {
    testWidgets('REQ-COS-001: Normal specials (波动拳 236P, 升龙拳 623P) in movelist must NOT show green drive box or 2', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: MovelistScreen(
            characterId: 'ken',
            frameDataService: FrameDataService(),
          ),
        ),
      );
      await tester.pump();

      // Find the title text for standard Hadoken '波动拳' (fontSize 14)
      final hadokenFinder = find.byWidgetPredicate((w) => w is Text && w.data == '波动拳' && (w.style?.fontSize ?? 0) >= 14);
      expect(hadokenFinder, findsOneWidget, reason: 'Ken should have standard 波动拳 title in movelist');

      final hadokenRowFinder = find.ancestor(of: hadokenFinder, matching: find.byType(Row)).first;

      // In v1.2.6.1, hadokenRow has a Container with AppColors.winGreen and Text('2').
      // Under REQ-COS-001, normal specials cost 0 drive gauge and MUST NOT display green drive box or number 2!
      final drive2Finder = find.descendant(of: hadokenRowFinder, matching: find.text('2'));
      expect(
        drive2Finder,
        findsNothing,
        reason: 'REQ-COS-001: Standard special 波动拳 (236P) costs 0 Drive gauge and must NOT display number 2',
      );

      final rowContainers = tester.widgetList<Container>(find.descendant(of: hadokenRowFinder, matching: find.byType(Container))).toList();
      final hasGreenBox = rowContainers.any((c) {
        final decoration = c.decoration;
        return decoration is BoxDecoration && decoration.color == AppColors.winGreen;
      });
      expect(
        hasGreenBox,
        isFalse,
        reason: 'REQ-COS-001: Standard special 波动拳 (236P) must NOT display green drive gauge container',
      );

      // Same check for Shoryuken '升龙拳'
      final shoryukenFinder = find.byWidgetPredicate((w) => w is Text && w.data == '升龙拳' && (w.style?.fontSize ?? 0) >= 14);
      expect(shoryukenFinder, findsOneWidget);
      final shoryuRowFinder = find.ancestor(of: shoryukenFinder, matching: find.byType(Row)).first;
      final shoryuDrive2Finder = find.descendant(of: shoryuRowFinder, matching: find.text('2'));
      expect(
        shoryuDrive2Finder,
        findsNothing,
        reason: 'REQ-COS-001: Standard special 升龙拳 (623P) costs 0 Drive gauge and must NOT display number 2',
      );
    });

    testWidgets('REQ-COS-001: Super Arts (SA1, SA2, SA3) in movelist must NOT show green drive box or 2', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovelistScreen(
            characterId: 'ken',
            frameDataService: FrameDataService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Super Art 1 'SA1: 龙卷裂风脚' by scrolling until visible
      final sa1Finder = find.byWidgetPredicate((w) => w is Text && w.data != null && w.data!.startsWith('SA1') && (w.style?.fontSize ?? 0) >= 14);
      await tester.scrollUntilVisible(sa1Finder, 500, scrollable: find.byType(Scrollable).first);
      expect(sa1Finder, findsOneWidget, reason: 'Ken should have SA1 in movelist');

      final sa1RowFinder = find.ancestor(of: sa1Finder, matching: find.byType(Row)).first;

      // Super Art consumes SA gauge, NOT Drive gauge! Must NOT show green box or 2.
      final sa1Drive2Finder = find.descendant(of: sa1RowFinder, matching: find.text('2'));
      expect(
        sa1Drive2Finder,
        findsNothing,
        reason: 'REQ-COS-001: Super Art SA1 consumes SA gauge, NOT 2 Drive gauges! Green 2 is strictly forbidden',
      );

      final sa1RowContainers = tester.widgetList<Container>(find.descendant(of: sa1RowFinder, matching: find.byType(Container))).toList();
      final sa1HasGreenBox = sa1RowContainers.any((c) {
        final decoration = c.decoration;
        return decoration is BoxDecoration && decoration.color == AppColors.winGreen;
      });
      expect(
        sa1HasGreenBox,
        isFalse,
        reason: 'REQ-COS-001: Super Art SA1 must NOT display green drive gauge container',
      );
    });

    testWidgets('REQ-COS-001: Only genuine OD specials (name containing OD or command containing PP/KK) show green drive indicator 2', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: MovelistScreen(
            characterId: 'ken',
            frameDataService: FrameDataService(),
          ),
        ),
      );
      await tester.pump();

      // Find 'OD 波动拳'
      final odHadokenFinder = find.byWidgetPredicate((w) => w is Text && w.data == 'OD 波动拳' && (w.style?.fontSize ?? 0) >= 14);
      expect(odHadokenFinder, findsOneWidget, reason: 'Ken movelist should contain OD 波动拳');
      final odRowFinder = find.ancestor(of: odHadokenFinder, matching: find.byType(Row)).first;

      // Genuine OD special must show drive gauge 2
      final odDrive2Finder = find.descendant(of: odRowFinder, matching: find.text('2'));
      expect(
        odDrive2Finder,
        findsOneWidget,
        reason: 'REQ-COS-001: Genuine OD special OD 波动拳 (236PP) must display drive gauge number 2',
      );
    });

    testWidgets('REQ-COS-002: MoveDetailModal for normal special must NOT display "消耗 2 (OD)"', (tester) async {
      final normalHadoken = FrameMove(
        name: '波动拳',
        command: '236P',
        type: MoveType.special,
        startup: '14',
        active: '-',
        recovery: '34',
        onBlock: '-6',
        onHit: '+1',
        damage: 600,
        notes: '标准地波牵制',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoveDetailModal(
              characterId: 'ken',
              characterNameZh: '肯',
              move: normalHadoken,
            ),
          ),
        ),
      );
      await tester.pump();

      // In v1.2.6.1, line 167 hardcodes Text('2 (OD)') whenever isSpecial is true!
      // Under REQ-COS-002, normal special move must NOT claim to consume 2 (OD)!
      expect(
        find.textContaining('2 (OD)'),
        findsNothing,
        reason: 'REQ-COS-002: MoveDetailModal must NOT show "2 (OD)" for normal special moves (236P)',
      );
      expect(
        find.textContaining('消耗 2'),
        findsNothing,
        reason: 'REQ-COS-002: MoveDetailModal must NOT show "消耗 2" for normal special moves',
      );
    });

    testWidgets('REQ-COS-002: MoveDetailModal for Super Arts must NOT display "消耗 2 (OD)" or generate L/M/H/OD variations', (tester) async {
      final sa3Move = FrameMove(
        name: 'SA3: 神龙拳',
        command: '236236P',
        type: MoveType.superArt,
        startup: '7',
        active: '8',
        recovery: '48',
        onBlock: '-26',
        onHit: '烈火龙卷',
        damage: 4000,
        notes: '完全无敌爆发终结，红血CA 4500',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoveDetailModal(
              characterId: 'ken',
              characterNameZh: '肯',
              move: sa3Move,
            ),
          ),
        ),
      );
      await tester.pump();

      // Must not display false OD badge
      expect(
        find.textContaining('2 (OD)'),
        findsNothing,
        reason: 'REQ-COS-002: Super Arts in MoveDetailModal must NOT show false "2 (OD)" cost badge',
      );

      // Must not generate L / M / H / OD variations for Super Arts!
      expect(
        find.text('L (轻)'),
        findsNothing,
        reason: 'REQ-COS-002: Super Arts must NOT generate L (轻) variation in MoveDetailModal',
      );
      expect(
        find.text('M (中)'),
        findsNothing,
        reason: 'REQ-COS-002: Super Arts must NOT generate M (中) variation in MoveDetailModal',
      );
      expect(
        find.text('H (重)'),
        findsNothing,
        reason: 'REQ-COS-002: Super Arts must NOT generate H (重) variation in MoveDetailModal',
      );
      expect(
        find.text('OD'),
        findsNothing,
        reason: 'REQ-COS-002: Super Arts must NOT generate OD variation row in MoveDetailModal',
      );
    });
  });

  // ===========================================================================
  // 3. REQ-CMB-001 & REQ-CMB-002: Combos Dataset Governance, Cleaning and Starter Types
  // ===========================================================================
  group('REQ-CMB-001 & REQ-CMB-002: Combos Dataset Cleaning and Governance', () {
    test('REQ-CMB-001: sf6_combos.json is strictly free of \\uFFFD and corrupted encoding characters', () {
      final file = File('assets/data/sf6_combos.json');
      expect(file.existsSync(), isTrue, reason: 'assets/data/sf6_combos.json must exist');
      final rawContent = file.readAsStringSync(encoding: utf8);

      // Check Unicode Replacement Character \uFFFD
      expect(
        rawContent.contains('\uFFFD'),
        isFalse,
        reason: 'REQ-CMB-001: sf6_combos.json must not contain \\uFFFD replacement characters',
      );

      // Check known corrupted encoding tokens (Ͽ, ŷ, ̳, ͨ, ȷ, etc.)
      const corruptTokens = ['Ͽ', 'ŷ', '̳', 'ͨ', 'ȷ'];
      final foundCorrupt = <String>[];
      for (final token in corruptTokens) {
        if (rawContent.contains(token)) {
          foundCorrupt.add(token);
        }
      }
      expect(
        foundCorrupt,
        isEmpty,
        reason: 'REQ-CMB-001: sf6_combos.json must be purged of corrupt encoding characters. Found: $foundCorrupt',
      );
    });

    test('REQ-CMB-001: Chun-Li (chunli) combos damage field must not contain move command text (e.g. 214P~LK)', () {
      final file = File('assets/data/sf6_combos.json');
      final Map<String, dynamic> data = jsonDecode(file.readAsStringSync(encoding: utf8));
      final chunliList = data['chunli'] as List? ?? [];
      expect(chunliList.isNotEmpty, isTrue, reason: 'Chun-Li combos must exist in sf6_combos.json');

      final misalignedDamages = <String>[];
      // Regex detecting move command markers in damage column (e.g. 214P, ~LK, DRC, lvl)
      final commandPattern = RegExp(r'[~>+]|[0-9]+[PK]|DRC|lvl', caseSensitive: false);

      for (final item in chunliList) {
        final damage = (item['damage'] ?? '').toString().trim();
        if (commandPattern.hasMatch(damage)) {
          misalignedDamages.add('id: ${item['id']}, damage: "$damage"');
        }
      }

      expect(
        misalignedDamages,
        isEmpty,
        reason: 'REQ-CMB-001: Chun-Li damage fields must not contain move commands. Found misaligned: $misalignedDamages',
      );
    });

    test('REQ-CMB-002: All combos across all characters must use standard 6 Chinese starterType, no English "Combo" or noise', () {
      final file = File('assets/data/sf6_combos.json');
      final Map<String, dynamic> data = jsonDecode(file.readAsStringSync(encoding: utf8));

      const standardStarters = {
        '确反康',
        '斗气迸发',
        '绿冲起手',
        '打断康',
        '普通命中',
        '版边崩防',
      };

      final nonStandardStarters = <String>[];

      data.forEach((charId, combosList) {
        if (combosList is List) {
          for (final item in combosList) {
            final starter = (item['starterType'] ?? '').toString().trim();
            if (!standardStarters.contains(starter)) {
              nonStandardStarters.add('$charId [id: ${item['id']}]: "$starter"');
            }
          }
        }
      });

      expect(
        nonStandardStarters,
        isEmpty,
        reason: 'REQ-CMB-002: All combo starterType must belong to 6 standard Chinese types (确反康/斗气迸发/绿冲起手/打断康/普通命中/版边崩防). Found non-standard entries: ${nonStandardStarters.take(10).toList()}',
      );
    });
  });

  // ===========================================================================
  // 4. REQ-GIF-001 ~ REQ-GIF-003: Media Helper Mapping and Progressive Preview
  // ===========================================================================
  group('REQ-GIF-001 ~ REQ-GIF-003: Media Helper Mapping and Progressive Loading', () {
    test('REQ-GIF-003: Sf6MoveMediaHelper supports case-insensitive commands, trimmed spaces and slug normalization', () {
      // Test slug normalization
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('ChunLi'), equals('chun-li'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('chunli'), equals('chun-li'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('ehonda'), equals('e-honda'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('deejay'), equals('dee-jay'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('dee-jay'), equals('dee-jay'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('mbison'), equals('m-bison'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('bison'), equals('m-bison'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('terry'), equals('terry'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('akuma'), equals('akuma'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('gouki'), equals('akuma'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('aki'), equals('aki'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('ed'), equals('ed'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('rashid'), equals('rashid'));

      // Test case-insensitivity and whitespace stripping for normals
      final normalMove1 = FrameMove(
        name: '站轻拳',
        command: ' 5lp ',
        type: MoveType.normal,
        startup: '4',
        active: '3',
        recovery: '7',
        onBlock: '-1',
        onHit: '+2',
        damage: 300,
      );
      final url1 = Sf6MoveMediaHelper.getHitboxGifUrl('ChunLi', normalMove1);
      expect(
        url1,
        equals('https://ultimateframedata.com/sf6/hitboxes/chun-li/chun-li-st-lp.gif'),
        reason: 'REQ-GIF-003: Must handle lowercase command and whitespace for Chun-Li 5LP',
      );

      final normalMove2 = FrameMove(
        name: '蹲中脚',
        command: '2mk',
        type: MoveType.normal,
        startup: '8',
        active: '3',
        recovery: '17',
        onBlock: '-5',
        onHit: '+1',
        damage: 500,
      );
      final url2 = Sf6MoveMediaHelper.getHitboxGifUrl('ryu', normalMove2);
      expect(
        url2,
        equals('https://ultimateframedata.com/sf6/hitboxes/ryu/ryu-cr-mk.gif'),
        reason: 'REQ-GIF-003: Must handle lowercase command for Ryu 2MK',
      );
    });

    test('REQ-GIF-003: Sf6MoveMediaHelper provides complete special moves mapping across characters (Terry, Ryu, Ken, Chun-Li, Guile, Cammy, Akuma, Zangief)', () {
      // Terry Power Wave & Burn Knuckle
      final terryBurnKnuckle = FrameMove(
        name: '燃烧指节',
        command: '214P',
        type: MoveType.special,
        damage: 1100,
        startup: '14',
        active: '8',
        recovery: '21',
        onBlock: '-7',
        onHit: '击倒',
      );
      expect(
        Sf6MoveMediaHelper.getHitboxGifUrl('terry', terryBurnKnuckle),
        equals('https://ultimateframedata.com/sf6/hitboxes/terry/terry-burnknuckle-hp.gif'),
        reason: 'REQ-GIF-003: Terry Burn Knuckle must resolve to terry-burnknuckle-hp.gif',
      );

      final terryPowerWave = FrameMove(
        name: '能量波',
        command: '236P',
        type: MoveType.special,
        damage: 600,
        startup: '13',
        active: '-',
        recovery: '33',
        onBlock: '-6',
        onHit: '+1',
      );
      expect(
        Sf6MoveMediaHelper.getHitboxGifUrl('terry', terryPowerWave),
        equals('https://ultimateframedata.com/sf6/hitboxes/terry/terry-powerwave-hp.gif'),
        reason: 'REQ-GIF-003: Terry Power Wave must resolve to terry-powerwave-hp.gif',
      );

      // Ken Jinraikyaku
      final kenJinraikyaku = FrameMove(
        name: '迅雷脚',
        command: '236K',
        type: MoveType.special,
        damage: 800,
        startup: '13',
        active: '3',
        recovery: '18',
        onBlock: '-5',
        onHit: '多择',
      );
      expect(
        Sf6MoveMediaHelper.getHitboxGifUrl('ken', kenJinraikyaku),
        equals('https://ultimateframedata.com/sf6/hitboxes/ken/ken-jinraikyaku-hk.gif'),
        reason: 'REQ-GIF-003: Ken Jinraikyaku must resolve to ken-jinraikyaku-hk.gif',
      );

      // Ryu Jodan Sokutogeri & Hashogeki
      final ryuJodan = FrameMove(
        name: '上段足刀蹴',
        command: '236K',
        type: MoveType.special,
        damage: 900,
        startup: '13',
        active: '3',
        recovery: '20',
        onBlock: '-8',
        onHit: '击倒',
      );
      expect(
        Sf6MoveMediaHelper.getHitboxGifUrl('ryu', ryuJodan),
        equals('https://ultimateframedata.com/sf6/hitboxes/ryu/ryu-jodan-hk.gif'),
        reason: 'REQ-GIF-003: Ryu Jodan must resolve to ryu-jodan-hk.gif',
      );

      final ryuHashogeki = FrameMove(
        name: '波掌击',
        command: '214P',
        type: MoveType.special,
        damage: 800,
        startup: '14',
        active: '3',
        recovery: '22',
        onBlock: '-4',
        onHit: '+2',
      );
      expect(
        Sf6MoveMediaHelper.getHitboxGifUrl('ryu', ryuHashogeki),
        equals('https://ultimateframedata.com/sf6/hitboxes/ryu/ryu-hashogeki-hp.gif'),
        reason: 'REQ-GIF-003: Ryu Hashogeki must resolve to ryu-hashogeki-hp.gif',
      );

      // Chun-Li Kikoken & Spinning Bird Kick
      final chunliKikoken = FrameMove(
        name: '气功拳',
        command: '4蓄6P',
        type: MoveType.special,
        damage: 600,
        startup: '10',
        active: '-',
        recovery: '30',
        onBlock: '-3',
        onHit: '+2',
      );
      expect(
        Sf6MoveMediaHelper.getHitboxGifUrl('chunli', chunliKikoken),
        equals('https://ultimateframedata.com/sf6/hitboxes/chun-li/chun-li-kikoken-hp.gif'),
        reason: 'REQ-GIF-003: Chun-Li Kikoken must resolve to chun-li-kikoken-hp.gif',
      );

      final chunliSBK = FrameMove(
        name: '旋转鹤脚蹴',
        command: '2蓄8K',
        type: MoveType.special,
        damage: 1000,
        startup: '8',
        active: '6',
        recovery: '24',
        onBlock: '-10',
        onHit: '击倒',
      );
      expect(
        Sf6MoveMediaHelper.getHitboxGifUrl('chunli', chunliSBK),
        equals('https://ultimateframedata.com/sf6/hitboxes/chun-li/chun-li-spinningbirdkick-hk.gif'),
        reason: 'REQ-GIF-003: Chun-Li SBK must resolve to chun-li-spinningbirdkick-hk.gif',
      );

      // Akuma Gohadoken
      final akumaGohadoken = FrameMove(
        name: '豪波动拳',
        command: '236P',
        type: MoveType.special,
        damage: 700,
        startup: '13',
        active: '-',
        recovery: '33',
        onBlock: '-6',
        onHit: '+1',
      );
      expect(
        Sf6MoveMediaHelper.getHitboxGifUrl('akuma', akumaGohadoken),
        equals('https://ultimateframedata.com/sf6/hitboxes/akuma/akuma-gohadoken-hp.gif'),
        reason: 'REQ-GIF-003: Akuma Gohadoken must resolve to akuma-gohadoken-hp.gif',
      );
    });

    test('REQ-GIF-003: Sf6MoveMediaHelper returns null for unknown moves and produces valid URLs without spaces', () {
      final unknownMove = FrameMove(
        name: '未知道场招式',
        command: '999XX',
        type: MoveType.unique,
        damage: 100,
        startup: '1',
        active: '1',
        recovery: '1',
        onBlock: '0',
        onHit: '0',
      );
      expect(
        Sf6MoveMediaHelper.getHitboxGifUrl('ryu', unknownMove),
        isNull,
        reason: 'REQ-GIF-003: Unknown move must strictly return null to prevent 404 storms',
      );

      final knownMove = FrameMove(
        name: '站重拳',
        command: '5HP',
        type: MoveType.normal,
        damage: 800,
        startup: '8',
        active: '3',
        recovery: '18',
        onBlock: '-3',
        onHit: '+2',
      );
      final knownUrl = Sf6MoveMediaHelper.getHitboxGifUrl('ryu', knownMove);
      expect(knownUrl, isNotNull);
      expect(knownUrl!.contains(' '), isFalse, reason: 'URL must not contain illegal space characters');
      expect(Uri.tryParse(knownUrl)?.hasAbsolutePath, isTrue, reason: 'URL must be a valid absolute URI');
    });

    test('REQ-GIF-001: MoveActionPreview source code does not contain hardcoded "isBanner && ... " thumbnail blocking', () {
      final source = File('lib/ui/widgets/move_action_preview.dart').readAsStringSync();
      expect(
        source.contains('isBanner && gifUrl != null'),
        isFalse,
        reason: 'REQ-GIF-001: Hardcoded "isBanner && gifUrl != null" condition must be removed to allow thumbnail mode to load GIFs',
      );
    });

    testWidgets('REQ-GIF-001: MoveActionPreview in thumbnail mode (isBanner: false) renders network image when gifUrl is present', (tester) async {
      final move5HP = FrameMove(
        name: '站重拳',
        command: '5HP',
        type: MoveType.normal,
        startup: '8',
        active: '3',
        recovery: '18',
        onBlock: '-3',
        onHit: '+2',
        damage: 800,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoveActionPreview(
              characterId: 'ryu',
              move: move5HP,
              width: 82,
              height: 56,
              isBanner: false,
            ),
          ),
        ),
      );

      // In v1.2.6.2 REQ-GIF-001, thumbnail mode MUST support network image loading alongside offline fallback
      final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
      final networkImages = imageWidgets.where((img) => img.image is NetworkImage).toList();

      expect(
        networkImages.isNotEmpty,
        isTrue,
        reason: 'REQ-GIF-001: MoveActionPreview in thumbnail mode must instantiate Image.network when gifUrl is present, not block it completely',
      );
    });
  });
}
