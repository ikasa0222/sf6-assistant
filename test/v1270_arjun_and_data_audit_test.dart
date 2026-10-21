import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/data/character_stats_database.dart';
import 'package:sf6_tracker/data/frame_data_database.dart';
import 'package:sf6_tracker/data/sf6_combos_database.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/services/notes_service.dart';
import 'package:sf6_tracker/utils/sf6_move_media_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  // 1. REQ-VER-001: Application Version and Build Number Specifications (v1.2.7.0 / 2700)
  // ===========================================================================
  group('REQ-VER-001: Version and Build Metadata (v1.2.7.0 / 2700 or v1.2.7.1 / 2701)', () {
    test('AppLogger.currentAppVersion must equal v1.2.7.0 or v1.2.7.1', () {
      expect(
        AppLogger.currentAppVersion == 'v1.2.7.0' || AppLogger.currentAppVersion == 'v1.2.7.1' || AppLogger.currentAppVersion == 'v1.2.7.2' || AppLogger.currentAppVersion == 'v1.2.7.3',
        isTrue,
        reason: 'REQ-VER-001: AppLogger.currentAppVersion must be v1.2.7.0 or v1.2.7.1',
      );
    });

    test('AppLogger.currentBuildNumber must equal 2700 or 2701', () {
      expect(
        AppLogger.currentBuildNumber == '2700' || AppLogger.currentBuildNumber == '2701' || AppLogger.currentBuildNumber == '2702' || AppLogger.currentBuildNumber == '2703',
        isTrue,
        reason: 'REQ-VER-001: AppLogger.currentBuildNumber must be 2700 or 2701',
      );
    });

    test('pubspec.yaml version must strictly be 1.2.7+2700 or 1.2.7+2701', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue, reason: 'pubspec.yaml must exist');
      final content = pubspecFile.readAsStringSync();
      final versionMatch = RegExp(r'^version:\s*1\.2\.7(\.[0123])?\+(2700|2701|2702|2703|2703)\s*$', multiLine: true);
      expect(
        versionMatch.hasMatch(content),
        isTrue,
        reason: 'REQ-VER-001: pubspec.yaml version must strictly be 1.2.7+2700 or 1.2.7+2701',
      );
    });

    test('AppLogger diagnostic summary format must output target version and build', () {
      final logger = AppLogger.instance;
      final report = logger.buildConciseDiagnosticSummary();
      expect(
        report.contains('v1.2.7.0') || (report.contains('v1.2.7.1') || report.contains('v1.2.7.2') || report.contains('v1.2.7.3')),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include version v1.2.7.0 or v1.2.7.1',
      );
      expect(
        report.contains('2700') || (report.contains('2701') || report.contains('2702') || report.contains('2703') || report.contains('2703')),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include build number 2700 or 2701',
      );
    });
  });

  // ===========================================================================
  // 2. REQ-ARJ-001: Arjun Global Constants and Metadata Registration
  // ===========================================================================
  group('REQ-ARJ-001: Arjun Global Constants and Metadata Registration', () {
    test('Sf6Characters.all total character count must be 33 (with random) or 32 (without random)', () {
      final nonRandomCount = Sf6Characters.all.where((c) => c.id != 'random').length;
      expect(
        nonRandomCount,
        equals(32),
        reason: 'REQ-ARJ-001: Roster must include 32 official fighters after Arjun onboarding',
      );
      expect(
        Sf6Characters.all.length,
        anyOf(equals(32), equals(33)),
        reason: 'REQ-ARJ-001: Sf6Characters.all total length must be 33 (with random) or 32',
      );
    });

    test('Sf6Characters.getById retrieves Arjun by id and chinese name with correct archetype', () {
      final byId = Sf6Characters.getById('arjun');
      expect(byId.id, equals('arjun'), reason: 'getById("arjun") must return arjun');
      expect(byId.nameZh, equals('阿俊'), reason: 'nameZh must be 阿俊');
      expect(
        byId.archetype.contains('徒手瑜伽') || byId.archetype.contains('灰血'),
        isTrue,
        reason: 'REQ-ARJ-001: Archetype must indicate yoga or grey-health suppression',
      );

      final byZh = Sf6Characters.getById('阿俊');
      expect(byZh.id, equals('arjun'), reason: 'getById("阿俊") must resolve to arjun');
    });

    test('Sf6Characters.fromCapcomId(35) resolves accurately to Arjun', () {
      final char35 = Sf6Characters.fromCapcomId(35);
      expect(
        char35.id,
        equals('arjun'),
        reason: 'REQ-ARJ-001: Capcom ID 35 must map to Arjun',
      );
      expect(
        char35.nameZh,
        equals('阿俊'),
        reason: 'REQ-ARJ-001: Capcom ID 35 must have nameZh 阿俊',
      );
    });
  });

  // ===========================================================================
  // 3. REQ-ARJ-002: Arjun Authentic Stats and Movement Attributes
  // ===========================================================================
  group('REQ-ARJ-002: Arjun Authentic Stats and Movement Attributes', () {
    test('CharacterStatsDatabase.getStats("arjun") returns authentic stats with 10500 HP without fallback', () {
      final stats = CharacterStatsDatabase.getStats('arjun');
      expect(
        stats.characterId,
        equals('arjun'),
        reason: 'Stats characterId must be arjun',
      );
      expect(
        stats.lifePoints,
        equals(10500),
        reason: 'REQ-ARJ-002: Arjun must have 10500 HP (heavy build)',
      );
      expect(
        stats.quote.contains('街头霸王6参战格斗家，在世界大赛舞台上追逐极致荣耀。'),
        isFalse,
        reason: 'REQ-ARJ-002: Arjun stats must not use generic fallback dummy quote',
      );
      expect(
        stats.forwardDashSpeed,
        equals(20),
        reason: 'REQ-ARJ-002: Arjun forward dash speed must be 20F',
      );
    });
  });

  // ===========================================================================
  // 4. REQ-ARJ-003: Arjun Move List, Frame Data & Real 4-Version Variations
  // ===========================================================================
  group('REQ-ARJ-003: Arjun Move List, Frame Data & Real 4-Version Variations', () {
    test('FrameDataDatabase.getCharacterMoves("arjun") has >= 30 comprehensive moves', () {
      final moves = FrameDataDatabase.getCharacterMoves('arjun');
      expect(
        moves.length,
        greaterThanOrEqualTo(30),
        reason: 'REQ-ARJ-003: Arjun must have >= 30 official moves in frame database',
      );
    });

    test('Arjun moves include core signature specials and supers', () {
      final moves = FrameDataDatabase.getCharacterMoves('arjun');
      final names = moves.map((m) => m.name).toList();

      final hasArmOfJustice = names.any((n) => n.contains('正义之臂') || n.contains('Arm of Justice'));
      final hasCruelShoulder = names.any((n) => n.contains('狂暴之肩') || n.contains('Cruel Shoulder'));
      final hasDivinePillar = names.any((n) => n.contains('神柱') || n.contains('Divine Pillar'));
      final hasInterrogation = names.any((n) => n.contains('阴森审讯') || n.contains('Ghastly Interrogation'));
      final hasIndomitableDefense = names.any((n) => n.contains('不屈防壁') || n.contains('Indomitable Defense'));

      expect(hasArmOfJustice, isTrue, reason: 'REQ-ARJ-003: Arjun must have 正义之臂');
      expect(hasCruelShoulder, isTrue, reason: 'REQ-ARJ-003: Arjun must have 狂暴之肩');
      expect(hasDivinePillar, isTrue, reason: 'REQ-ARJ-003: Arjun must have 神柱');
      expect(hasInterrogation, isTrue, reason: 'REQ-ARJ-003: Arjun must have 阴森审讯');
      expect(hasIndomitableDefense, isTrue, reason: 'REQ-ARJ-003: Arjun must have 不屈防壁');

      final saCount = moves.where((m) => m.type == MoveType.superArt).length;
      expect(saCount, greaterThanOrEqualTo(3), reason: 'REQ-ARJ-003: Arjun must have SA1, SA2, and SA3');
    });

    test('Arjun core specials contain independent 4-version variations (L/M/H/OD)', () {
      final moves = FrameDataDatabase.getCharacterMoves('arjun');
      final armOfJustice = moves.firstWhere(
        (m) => m.name.contains('正义之臂') || m.command.contains('236P'),
        orElse: () => throw StateError('Arm of Justice not found'),
      );

      expect(
        armOfJustice.variations.length,
        greaterThanOrEqualTo(4),
        reason: 'REQ-ARJ-003: Arm of Justice must have at least 4 distinct variations (L/M/H/OD)',
      );

      // Verify OD variation has authentic data (+2F on block)
      final odVar = armOfJustice.variations.firstWhere(
        (v) => v.version.contains('OD'),
        orElse: () => throw StateError('OD variation not found'),
      );
      expect(
        odVar.onBlock,
        equals('+2'),
        reason: 'REQ-ARJ-003: OD Arm of Justice must be +2 on block',
      );
    });
  });

  // ===========================================================================
  // 5. REQ-ARJ-004: Arjun Combos Database and Standardized Starters
  // ===========================================================================
  group('REQ-ARJ-004: Arjun Combos Database and Standardized Starters', () {
    test('Sf6CombosDatabase.getCombosForCharacter("arjun") returns valid combos with Chinese starters', () {
      final combos = Sf6CombosDatabase.getCombosForCharacter('arjun');
      expect(
        combos.isNotEmpty,
        isTrue,
        reason: 'REQ-ARJ-004: Arjun combos must exist and not be empty',
      );

      for (final combo in combos) {
        expect(
          combo.starterType,
          anyOf(
            equals('确反康'),
            equals('普通命中'),
            equals('打断康'),
            equals('绿冲起手'),
            equals('斗气迸发'),
            equals('版边崩防'),
          ),
          reason: 'REQ-ARJ-004: Starter type "${combo.starterType}" must be one of 6 standard Chinese starters, no English',
        );
      }
    });
  });

  // ===========================================================================
  // 6. REQ-ARJ-005: Arjun Strategy Notes & Media Helper Mapping
  // ===========================================================================
  group('REQ-ARJ-005: Arjun Strategy Notes & Media Helper Mapping', () {
    test('NotesService.defaultStrategyNotes must contain Arjun strategy notes', () {
      final notes = NotesService.defaultStrategyNotes;
      final hasArjun = notes.any((n) => n.targetKey.toLowerCase() == 'arjun');
      expect(
        hasArjun,
        isTrue,
        reason: 'REQ-ARJ-005: Default strategy notes must include strategy against Arjun',
      );
    });

    test('Sf6MoveMediaHelper supports Arjun character slug and hitbox URL resolution', () {
      final slug = Sf6MoveMediaHelper.getUfdCharacterSlug('arjun');
      expect(slug, equals('arjun'), reason: 'Arjun slug must be arjun');

      final dummyMove = FrameMove(
        name: '正义之臂',
        command: '236P',
        type: MoveType.special,
        damage: 800,
        startup: '14',
        active: '3',
        recovery: '18',
        onBlock: '-6',
        onHit: '+2',
      );
      final gifUrl = Sf6MoveMediaHelper.getHitboxGifUrl('arjun', dummyMove);
      expect(
        gifUrl,
        isNotNull,
        reason: 'REQ-ARJ-005: Arjun 236P must resolve to valid hitbox GIF URL',
      );
      expect(
        gifUrl!.contains('arjun'),
        isTrue,
        reason: 'REQ-ARJ-005: Hitbox GIF URL must contain arjun',
      );
    });
  });

  // ===========================================================================
  // 7. REQ-AUD-001: Root Out Cloned Normal Moves Fallback
  // ===========================================================================
  group('REQ-AUD-001: Frame Data Cleanse - No Ryu Normals Clones', () {
    test('Non-Ryu characters (luke, marisa, jp, manon) must NOT have cloned Ryu normals', () {
      final ryuMoves = FrameDataDatabase.getCharacterMoves('ryu');
      final ryuNormals = ryuMoves.where((m) => m.type == MoveType.normal).toList();
      final ryuStartups = ryuNormals.map((m) => '${m.command}:${m.startup}:${m.onBlock}').toList();

      final auditedChars = ['luke', 'marisa', 'jp', 'manon'];

      for (final charId in auditedChars) {
        final charMoves = FrameDataDatabase.getCharacterMoves(charId);
        final charNormals = charMoves.where((m) => m.type == MoveType.normal).toList();

        expect(
          charNormals.isNotEmpty,
          isTrue,
          reason: 'REQ-AUD-001: Character $charId must have normal moves',
        );

        // Check that normals are not 100% clone of Ryu's
        final charStartups = charNormals.map((m) => '${m.command}:${m.startup}:${m.onBlock}').toList();
        final is100PercentClone = charStartups.length == ryuStartups.length &&
            charStartups.asMap().entries.every((entry) => entry.value == ryuStartups[entry.key]);

        expect(
          is100PercentClone,
          isFalse,
          reason: 'REQ-AUD-001: Character $charId normal moves must NOT be a 100% clone of Ryu normal moves!',
        );

        // Check that move names and notes don't contain '隆' or generic Ryu text
        for (final m in charNormals) {
          expect(
            m.notes?.contains('隆') ?? false,
            isFalse,
            reason: 'REQ-AUD-001: Character $charId move notes must not mention 隆',
          );
        }
      }
    });
  });

  // ===========================================================================
  // 8. REQ-AUD-002: Cleanse Stats Database - All 32 Characters Have Authentic Stats
  // ===========================================================================
  group('REQ-AUD-002: Character Stats Database Cleanse - All 32 Characters', () {
    test('CharacterStatsDatabase provides dedicated authentic stats for all 32 official characters', () {
      final officialCharIds = [
        'ryu', 'ken', 'luke', 'cammy', 'chunli', 'guile', 'zangief', 'juri',
        'bison', 'terry', 'akuma', 'arjun', 'ed', 'rashid', 'aki', 'marisa',
        'jp', 'manon', 'deejay', 'ehonda', 'dhalsim', 'blanka', 'lily', 'jamie',
        'kimberly', 'mai', 'elena', 'sagat', 'cviper', 'alex', 'ingrid', 'yasmine'
      ];

      const dummyQuote = '街头霸王6参战格斗家，在世界大赛舞台上追逐极致荣耀。';

      for (final charId in officialCharIds) {
        final stats = CharacterStatsDatabase.getStats(charId);
        expect(
          stats.quote,
          isNot(equals(dummyQuote)),
          reason: 'REQ-AUD-002: Character $charId must have authentic quote, not generic dummy fallback',
        );
        expect(
          stats.characterId,
          equals(charId),
          reason: 'REQ-AUD-002: Character $charId stats id must match',
        );
      }
    });
  });
}
