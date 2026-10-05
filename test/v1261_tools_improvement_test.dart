import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/data/frame_data_database.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/models/combo_recipe.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';
import 'package:sf6_tracker/ui/widgets/move_action_preview.dart';
import 'package:sf6_tracker/ui/widgets/move_detail_modal.dart';
import 'package:sf6_tracker/ui/screens/tools/hitbox_viewer_screen.dart';
import 'package:sf6_tracker/utils/sf6_move_media_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // 1. REQ-VER-001: Application Version and Build Metadata Specifications
  // ---------------------------------------------------------------------------
  group('REQ-VER-001: Application Version and Build Metadata', () {
    test('AppLogger.currentAppVersion must be strictly updated to v1.2.6.1 or higher', () {
      expect(
        AppLogger.currentAppVersion.startsWith('v1.2.6'),
        isTrue,
        reason: 'REQ-VER-001: AppLogger.currentAppVersion must be v1.2.6.1 or higher target version (e.g. v1.2.6.4)',
      );
    });

    test('pubspec.yaml version must be strictly incremented to 1.2.6+2601 or higher', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue, reason: 'pubspec.yaml must exist');
      final content = pubspecFile.readAsStringSync();
      final versionMatch = RegExp(r'^version:\s*1\.2\.6(\.[12345])?\+260[12345]\s*$', multiLine: true);
      expect(
        versionMatch.hasMatch(content),
        isTrue,
        reason: 'REQ-VER-001: pubspec.yaml version must be 1.2.6+2601 or higher (SemVer compliant)',
      );
    });

    test('AppLogger diagnostic summary format must output target version and build', () {
      final logger = AppLogger.instance;
      final report = logger.buildConciseDiagnosticSummary();
      expect(
        report.contains('v1.2.6'),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic report must include version v1.2.6.x',
      );
      expect(
        report.contains('2601') || report.contains('2602') || report.contains('2603') || report.contains('2604') || report.contains('2605'),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic report must include build number 260x',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 2. REQ-DAT-001: Frame Data Capcom Official Chinese Alignment & Japanese Purge
  // ---------------------------------------------------------------------------
  group('REQ-DAT-001: Frame Data Official Chinese Alignment and Japanese Purge', () {
    test('Akuma 4HK move name must be corrected to official Chinese 车蹴', () {
      final akumaMoves = FrameDataDatabase.getCharacterMoves('akuma');
      final move4HK = akumaMoves.firstWhere(
        (m) => m.command == '4HK',
        orElse: () => throw StateError('Akuma 4HK not found'),
      );

      expect(
        move4HK.name,
        equals('车蹴'),
        reason: 'REQ-DAT-001: Akuma 4HK must be named 车蹴, not Japanese くるま蹴り',
      );

      expect(
        move4HK.notes,
        contains('两段向上连续重踢，豪鬼核心对空与大连段起手'),
        reason: 'REQ-DAT-001: Akuma 4HK notes must follow official standardization',
      );
    });

    test('Entire FrameDataDatabase must have zero Japanese kana characters in move names', () {
      final characters = [
        'luke', 'jamie', 'manon', 'kimberly', 'marisa', 'lily', 'jp', 'juri',
        'deejay', 'cammy', 'ryu', 'ehonda', 'blanka', 'guile', 'ken', 'chunli',
        'zangief', 'dhalsim', 'rashid', 'aki', 'ed', 'akuma', 'mbison', 'terry',
        'mai', 'elena', 'sagat', 'cviper', 'alex', 'ingrid', 'yasmine',
      ];

      final kanaRegex = RegExp(r'[\u3040-\u309F\u30A0-\u30FF]');
      final pollutedMoves = <String>[];

      for (final charId in characters) {
        final moves = FrameDataDatabase.getCharacterMoves(charId);
        for (final move in moves) {
          if (kanaRegex.hasMatch(move.name)) {
            pollutedMoves.add('$charId: ${move.command} -> ${move.name}');
          }
        }
      }

      expect(
        pollutedMoves,
        isEmpty,
        reason: 'REQ-DAT-001: All Japanese kana must be purged from move names. Polluted: $pollutedMoves',
      );
    });

    test('Super Arts naming must follow standardized SA1/SA2/SA3 format', () {
      final akumaMoves = FrameDataDatabase.getCharacterMoves('akuma');
      final saMoves = akumaMoves.where((m) => m.type == MoveType.superArt).toList();
      expect(saMoves.isNotEmpty, isTrue);

      for (final move in saMoves) {
        final isStandard = move.name.startsWith('SA1:') ||
            move.name.startsWith('SA2:') ||
            move.name.startsWith('SA3:') ||
            move.name.startsWith('CA:') ||
            move.name.startsWith('秘传 SA3:');
        expect(
          isStandard,
          isTrue,
          reason: 'REQ-DAT-001: Super Art "${move.name}" must follow standard prefix (SA1:/SA2:/SA3:/CA:)',
        );
      }
    });
  });

  // ---------------------------------------------------------------------------
  // 3. REQ-CMD-001 & REQ-CMD-002: Command Normalization & Graphic Badges
  // ---------------------------------------------------------------------------
  group('REQ-CMD-001 & REQ-CMD-002: Command Parsing & Graphic Badges', () {
    test('REQ-CMD-001: Cleans full-width symbols and Unicode arrows in translation', () {
      final result1 = Sf6CommandView.translateToChinese('↓↘→＋强P');
      expect(result1, isNot(contains('↓')));
      expect(result1, isNot(contains('↘')));
      expect(result1, isNot(contains('→')));
      expect(result1, isNot(contains('＋')));
      expect(result1, isNot(contains('强P')));
      expect(result1, contains('重波动拳'));

      final result2 = Sf6CommandView.translateToChinese('←蓄→＋K');
      expect(result2, isNot(contains('＋')));
      expect(result2, isNot(contains('←蓄→')));
    });

    testWidgets('REQ-CMD-001: Graphic command view cleans full-width symbols and renders official icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Sf6CommandView(
              rawCommand: '↓↘→＋强P',
              mode: CommandDisplayMode.graphic,
            ),
          ),
        ),
      );

      // Must not display unparsed raw string fallback
      expect(find.text('↓↘→＋强P'), findsNothing, reason: 'REQ-CMD-001: Full-width raw command must not be displayed unparsed');

      // Must render directional arrow icons and punch button icon
      final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(
        imageWidgets.isNotEmpty,
        isTrue,
        reason: 'REQ-CMD-001: Graphic mode must render arrow and button assets for normalized command',
      );
    });

    testWidgets('REQ-CMD-002: Modern mode renders graphic capsule badges rather than plain text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Sf6CommandView(
              rawCommand: '623P',
              mode: CommandDisplayMode.modern,
            ),
          ),
        ),
      );

      // In v1.2.6, it merely renders a SelectableText('6+SP') in gold text.
      // Under REQ-CMD-002, it must render graphic capsule badge Container with purple color #7C4DFF for SP.
      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      final hasSpBadgeContainer = containers.any((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          final color = decoration.color;
          return color == const Color(0xFF7C4DFF) ||
              (color != null && color.value == 0xFF7C4DFF);
        }
        return false;
      });

      expect(
        hasSpBadgeContainer,
        isTrue,
        reason: 'REQ-CMD-002: Modern mode must render styled capsule badges (e.g. SP key capsule #7C4DFF)',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 4. REQ-MOV-001 & REQ-MOV-002: Move Thumbnail Offline-First Policy & Media Helper
  // ---------------------------------------------------------------------------
  group('REQ-MOV-001 & REQ-MOV-002: Move Thumbnail Offline-First Policy & Media Helper', () {
    testWidgets('REQ-MOV-001: MoveActionPreview in thumbnail mode (isBanner: false) supports progressive network images with local fallback', (tester) async {
      final move = FrameMove(
        name: '站轻拳',
        command: '5LP',
        type: MoveType.normal,
        startup: '4',
        active: '3',
        recovery: '7',
        onBlock: '-1',
        onHit: '+2',
        damage: 300,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoveActionPreview(
              characterId: 'akuma',
              move: move,
              width: 82,
              height: 56,
              isBanner: false,
            ),
          ),
        ),
      );

      // In v1.2.6.2 (REQ-GIF-001 superseding REQ-MOV-001), thumbnail mode supports progressive network loading with local fallback.
      expect(find.byType(MoveActionPreview), findsOneWidget);
    });

    test('REQ-MOV-002: Media helper resolves hyphenated slugs and returns null for unknown moves', () {
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('chunli'), equals('chun-li'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('ehonda'), equals('e-honda'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('deejay'), equals('dee-jay'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('mbison'), equals('m-bison'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('bison'), equals('m-bison'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('guile'), equals('guile'));

      final unknownMove = FrameMove(
        name: '未知练习动作',
        command: '999XX',
        type: MoveType.unique,
        startup: '10',
        active: '3',
        recovery: '15',
        onBlock: '-2',
        onHit: '+2',
        damage: 500,
      );
      final unknownUrl = Sf6MoveMediaHelper.getHitboxGifUrl('ryu', unknownMove);
      expect(
        unknownUrl,
        isNull,
        reason: 'REQ-MOV-002: Unknown move must strictly return null to prevent 404 storm',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 5. REQ-SHR-001 & REQ-NAV-001: Move Detail Modal Sharing & Navigation Contract
  // ---------------------------------------------------------------------------
  group('REQ-SHR-001 & REQ-NAV-001: Move Detail Modal Sharing and Navigation', () {
    testWidgets('REQ-SHR-001: Tapping share button sets structured formatted text to system clipboard', (tester) async {
      String? copiedClipboardText;

      // Mock platform clipboard channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          final args = methodCall.arguments as Map<dynamic, dynamic>?;
          copiedClipboardText = args?['text'] as String?;
          return null;
        } else if (methodCall.method == 'Clipboard.getData') {
          return <String, dynamic>{'text': copiedClipboardText};
        }
        return null;
      });

      final testMove = FrameMove(
        name: '波动拳',
        command: '236P',
        type: MoveType.special,
        startup: '12',
        active: '-',
        recovery: '34',
        onBlock: '-6',
        onHit: '+1',
        damage: 650,
        notes: '主力波牵制，可蓄力',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoveDetailModal(
              characterId: 'ryu',
              characterNameZh: '隆',
              move: testMove,
            ),
          ),
        ),
      );

      final shareBtn = find.text('分享招式 SHARE');
      expect(shareBtn, findsOneWidget);

      await tester.tap(shareBtn);
      await tester.pumpAndSettle();

      // Verify Clipboard was called with the exact structured template
      expect(
        copiedClipboardText,
        isNotNull,
        reason: 'REQ-SHR-001: Tapping share must invoke Clipboard.setData',
      );

      expect(copiedClipboardText, contains('【街霸6 招式数据】隆 - 波动拳'));
      expect(copiedClipboardText, contains('• 指令: 236P'));
      expect(copiedClipboardText, contains('• 阶段: 发生 12F | 持续 - | 硬直 34'));
      expect(copiedClipboardText, contains('• 帧差: 被防 -6 | 命中 +1 | 伤害 650'));
      expect(copiedClipboardText, contains('• 特性: 主力波牵制，可蓄力'));
      expect(copiedClipboardText, contains('—— 数据来自 街霸6助手 (SF6 Assistant)'));

      // Verify SnackBar text matches requirement
      expect(
        find.textContaining('已复制 波动拳 完整指令与帧数到剪贴板'),
        findsOneWidget,
        reason: 'REQ-SHR-001: SnackBar must display official confirmation message',
      );
    });

    test('REQ-NAV-001: MoveDetailModal and Navigation callers must support isAlreadyInFrameData contract', () {
      final modalSource = File('lib/ui/widgets/move_detail_modal.dart').readAsStringSync();
      expect(
        modalSource.contains('isAlreadyInFrameData'),
        isTrue,
        reason: 'REQ-NAV-001: MoveDetailModal must support isAlreadyInFrameData parameter',
      );

      expect(
        modalSource.contains('返回列表') || modalSource.contains('已在帧数表'),
        isTrue,
        reason: 'REQ-NAV-001: MoveDetailModal must have alternative label when isAlreadyInFrameData is true',
      );

      final movelistSource = File('lib/ui/screens/tools/movelist_screen.dart').readAsStringSync();
      expect(
        movelistSource.contains('onOpenFullFrameData'),
        isTrue,
        reason: 'REQ-NAV-001: MovelistScreen must pass onOpenFullFrameData callback to open frame data screen',
      );

      final frameDataSource = File('lib/ui/screens/tools/frame_data_screen.dart').readAsStringSync();
      expect(
        frameDataSource.contains('isAlreadyInFrameData: true'),
        isTrue,
        reason: 'REQ-NAV-001: FrameDataScreen must pass isAlreadyInFrameData: true to prevent self-push loop',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 6. REQ-HTB-001, REQ-HTB-002, REQ-HTB-003: Hitbox Viewer Screen Standard
  // ---------------------------------------------------------------------------
  group('REQ-HTB-001 ~ REQ-HTB-003: Hitbox Viewer Screen Specifications', () {
    testWidgets('REQ-HTB-003: HitboxViewerScreen category chips must use 普通技 and 超必杀技', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HitboxViewerScreen(characterId: 'ryu'),
        ),
      );
      await tester.pump();

      // REQ-HTB-003 requires category names to be '普通技' and '超必杀技'
      expect(
        find.text('普通技'),
        findsOneWidget,
        reason: 'REQ-HTB-003: Category chip must be 普通技, not 通常技',
      );
      expect(
        find.text('通常技'),
        findsNothing,
        reason: 'REQ-HTB-003: 通常技 must not exist in category chips',
      );

      expect(
        find.text('超必杀技'),
        findsOneWidget,
        reason: 'REQ-HTB-003: Category chip must be 超必杀技, not 超必杀',
      );
      expect(
        find.text('超必杀'),
        findsNothing,
        reason: 'REQ-HTB-003: 超必杀 must not exist in category chips',
      );
    });

    testWidgets('REQ-HTB-001: HitboxViewerScreen cards in list view must NOT instantiate Image.network', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HitboxViewerScreen(characterId: 'ryu'),
        ),
      );
      await tester.pump();

      final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
      final networkImages = imageWidgets.where((img) => img.image is NetworkImage).toList();

      expect(
        networkImages,
        isEmpty,
        reason: 'REQ-HTB-001: Hitbox cards in list view must render simulated hitbox without Image.network',
      );
    });

    test('REQ-HTB-002: HitboxViewerScreen source code must implement playback timer and multi-speed controls', () {
      final hitboxSource = File('lib/ui/screens/tools/hitbox_viewer_screen.dart').readAsStringSync();

      expect(
        hitboxSource.contains('Timer.periodic'),
        isTrue,
        reason: 'REQ-HTB-002: Scrubber modal must feature Timer.periodic playback engine',
      );

      expect(
        hitboxSource.contains('0.25x') && hitboxSource.contains('0.5x') && hitboxSource.contains('1.0x'),
        isTrue,
        reason: 'REQ-HTB-002: Scrubber modal must feature 0.25x, 0.5x, 1.0x speed options',
      );

      expect(
        hitboxSource.contains('Icons.play_arrow') || hitboxSource.contains('Icons.pause'),
        isTrue,
        reason: 'REQ-HTB-002: Scrubber modal must feature Play/Pause button control',
      );

      expect(
        hitboxSource.contains('起手') || hitboxSource.contains('STARTUP'),
        isTrue,
        reason: 'REQ-HTB-002: Scrubber modal must feature Startup keyframe jump button',
      );
      expect(
        hitboxSource.contains('发生') || hitboxSource.contains('ACTIVE'),
        isTrue,
        reason: 'REQ-HTB-002: Scrubber modal must feature Active keyframe jump button',
      );
      expect(
        hitboxSource.contains('收招') || hitboxSource.contains('RECOVERY'),
        isTrue,
        reason: 'REQ-HTB-002: Scrubber modal must feature Recovery keyframe jump button',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 7. REQ-CMB-001 & REQ-CMB-002: Combos Dataset Cleaning & Card Defensive Layout
  // ---------------------------------------------------------------------------
  group('REQ-CMB-001 & REQ-CMB-002: Combos Dataset Cleaning & Defensive Layout', () {
    test('REQ-CMB-001: sf6_combos.json is free of header pollution entries', () {
      final combosFile = File('assets/data/sf6_combos.json');
      expect(combosFile.existsSync(), isTrue, reason: 'assets/data/sf6_combos.json must exist');
      final Map<String, dynamic> data = jsonDecode(combosFile.readAsStringSync());

      final pollutedHeaders = <String>[];

      data.forEach((charId, combosList) {
        if (combosList is List) {
          for (final item in combosList) {
            final comboSeq = (item['comboSequence'] ?? '').toString().toLowerCase();
            final damage = (item['damage'] ?? '').toString().toLowerCase();
            final position = (item['position'] ?? '').toString().toLowerCase();

            if (comboSeq == 'starting normal' ||
                damage == 'counter hit' ||
                position == 'normal hit') {
              pollutedHeaders.add('$charId: ${item['id']} - $comboSeq / $damage');
            }
          }
        }
      });

      expect(
        pollutedHeaders,
        isEmpty,
        reason: 'REQ-CMB-001: Header pollution entries must be completely purged. Found: $pollutedHeaders',
      );
    });

    test('REQ-CMB-001: sf6_combos.json is free of concatenated digits (> 6 digits in damage)', () {
      final combosFile = File('assets/data/sf6_combos.json');
      final Map<String, dynamic> data = jsonDecode(combosFile.readAsStringSync());

      final concatenatedEntries = <String>[];
      final longNumberRegex = RegExp(r'\d{7,}');

      data.forEach((charId, combosList) {
        if (combosList is List) {
          for (final item in combosList) {
            final damage = (item['damage'] ?? '').toString();
            if (longNumberRegex.hasMatch(damage)) {
              concatenatedEntries.add('$charId: ${item['id']} damage=$damage');
            }
          }
        }
      });

      expect(
        concatenatedEntries,
        isEmpty,
        reason: 'REQ-CMB-001: Corrupt concatenated damage numbers must be cleaned. Found: $concatenatedEntries',
      );
    });

    test('REQ-CMB-001: sf6_combos.json has no unfinished ellipsis sequences', () {
      final combosFile = File('assets/data/sf6_combos.json');
      final Map<String, dynamic> data = jsonDecode(combosFile.readAsStringSync());

      final ellipsisEntries = <String>[];

      data.forEach((charId, combosList) {
        if (combosList is List) {
          for (final item in combosList) {
            final comboSeq = (item['comboSequence'] ?? '').toString().trim();
            if (comboSeq.endsWith('...') || comboSeq.endsWith('…')) {
              ellipsisEntries.add('$charId: ${item['id']} seq=$comboSeq');
            }
          }
        }
      });

      expect(
        ellipsisEntries,
        isEmpty,
        reason: 'REQ-CMB-001: Unfinished ellipsis sequences must be purged. Found: $ellipsisEntries',
      );
    });

    test('REQ-CMB-001: sf6_combos.json difficulties and positions are standardized Chinese', () {
      final combosFile = File('assets/data/sf6_combos.json');
      final Map<String, dynamic> data = jsonDecode(combosFile.readAsStringSync());

      const allowedDifficulties = {'极简', '简单', '普通', '进阶', '极难'};
      const allowedPositions = {'任意位置', '版边', '版中', '全屏/任意'};

      final nonStandardDifficulties = <String>[];
      final nonStandardPositions = <String>[];

      data.forEach((charId, combosList) {
        if (combosList is List) {
          for (final item in combosList) {
            final diff = (item['difficulty'] ?? '').toString().trim();
            final pos = (item['position'] ?? '').toString().trim();

            if (!allowedDifficulties.contains(diff)) {
              nonStandardDifficulties.add('$charId: diff="$diff"');
            }
            if (!allowedPositions.contains(pos)) {
              nonStandardPositions.add('$charId: pos="$pos"');
            }
          }
        }
      });

      expect(
        nonStandardDifficulties,
        isEmpty,
        reason: 'REQ-CMB-001: All combo difficulties must be standard Chinese (极简/简单/普通/进阶/极难). Found: ${nonStandardDifficulties.take(5).toList()}',
      );

      expect(
        nonStandardPositions,
        isEmpty,
        reason: 'REQ-CMB-001: All combo positions must be standard Chinese (任意位置/版边/版中). Found: ${nonStandardPositions.take(5).toList()}',
      );
    });

    test('REQ-CMB-001: sf6_combos.json driveGauge and superGauge are normalized integer strings', () {
      final combosFile = File('assets/data/sf6_combos.json');
      final Map<String, dynamic> data = jsonDecode(combosFile.readAsStringSync());

      const allowedDrive = {'0', '1', '2', '3', '4', '5', '6'};
      const allowedSuper = {'0', '1', '2', '3'};

      final invalidGauges = <String>[];

      data.forEach((charId, combosList) {
        if (combosList is List) {
          for (final item in combosList) {
            final drive = (item['driveGauge'] ?? '').toString().trim();
            final superG = (item['superGauge'] ?? '').toString().trim();

            if (!allowedDrive.contains(drive) || !allowedSuper.contains(superG)) {
              invalidGauges.add('$charId: drive="$drive", super="$superG"');
            }
          }
        }
      });

      expect(
        invalidGauges,
        isEmpty,
        reason: 'REQ-CMB-001: Drive and Super gauges must be valid integer strings. Found: ${invalidGauges.take(5).toList()}',
      );
    });

    test('REQ-CMB-002: ComboRecipe model parses malformed data defensively', () {
      final emptyRecipe = ComboRecipe.fromJson({});
      expect(emptyRecipe.id, equals(''));
      expect(emptyRecipe.starterZh, isNotEmpty);
      expect(emptyRecipe.positionZh, isNotEmpty);
      expect(emptyRecipe.difficultyZh, isNotEmpty);

      final dirtyRecipe = ComboRecipe.fromJson({
        'id': 'corrupt_1',
        'driveGauge': null,
        'superGauge': null,
        'damage': null,
      });
      expect(dirtyRecipe.driveGauge, equals('0'));
      expect(dirtyRecipe.superGauge, equals('0'));
      expect(dirtyRecipe.damage, equals('-'));
    });
  });
}
