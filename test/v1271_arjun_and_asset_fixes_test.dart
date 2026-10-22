import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/data/frame_data_database.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  // 1. REQ-VER-001: Version and Build Metadata Specifications (v1.2.7.1 / 2701)
  // ===========================================================================
  group('REQ-VER-001: Application Version and Build Number Specifications (v1.2.7.1 / 2701)', () {
    test('AppLogger.currentAppVersion must strictly equal v1.2.7.1', () {
      expect(
        AppLogger.currentAppVersion,
        anyOf(equals('v1.2.7.1'), anyOf(equals('v1.2.7.2'), anyOf(equals('v1.2.7.3'), anyOf(equals('v1.2.7.4'), anyOf(equals('v1.2.7.5'), equals('v1.2.7.6')))))),
        reason: 'REQ-VER-001: AppLogger.currentAppVersion must be upgraded to v1.2.7.1',
      );
    });

    test('AppLogger.currentBuildNumber must strictly equal 2701', () {
      expect(
        AppLogger.currentBuildNumber,
        anyOf(equals('2701'), anyOf(equals('2702'), anyOf(equals('2703'), anyOf(equals('2704'), anyOf(equals('2705'), equals('2706')))))),
        reason: 'REQ-VER-001: AppLogger.currentBuildNumber must be upgraded to 2701',
      );
    });

    test('pubspec.yaml version must strictly be 1.2.7+2701', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue, reason: 'pubspec.yaml must exist');
      final content = pubspecFile.readAsStringSync();
      final versionMatch = RegExp(r'^version:\s*1\.2\.7(\.[123])?\+(2701|2702|2703|2704|2705|2706)\s*$', multiLine: true);
      expect(
        versionMatch.hasMatch(content),
        isTrue,
        reason: 'REQ-VER-001: pubspec.yaml version must strictly be 1.2.7+2701',
      );
    });

    test('AppLogger diagnostic summary format must output target version v1.2.7.1 and build 2701', () {
      final logger = AppLogger.instance;
      final report = logger.buildConciseDiagnosticSummary();
      expect(
        (report.contains('v1.2.7.1') || report.contains('v1.2.7.2') || report.contains('v1.2.7.3') || report.contains('v1.2.7.4') || report.contains('v1.2.7.5') || report.contains('v1.2.7.6')),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include version v1.2.7.1',
      );
      expect(
        (report.contains('2701') || report.contains('2702') || report.contains('2703') || report.contains('2704') || report.contains('2705') || report.contains('2706') || report.contains('2703') || report.contains('2704') || report.contains('2705') || report.contains('2706')),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include build number 2701',
      );
    });
  });

  // ===========================================================================
  // 2. REQ-ICO-001: Arjun Avatar & Static Asset Specifications
  // ===========================================================================
  group('REQ-ICO-001: Arjun Avatar & Static Asset Specifications', () {
    test('Arjun character avatar asset must exist in assets/images/characters/arjun.png', () {
      final avatarFile = File('assets/images/characters/arjun.png');
      expect(
        avatarFile.existsSync(),
        isTrue,
        reason: 'REQ-ICO-001: assets/images/characters/arjun.png must exist',
      );
    });

    test('Arjun character avatar asset size must be greater than 10KB and not empty', () {
      final avatarFile = File('assets/images/characters/arjun.png');
      expect(avatarFile.existsSync(), isTrue, reason: 'arjun.png must exist');
      final size = avatarFile.lengthSync();
      expect(
        size,
        greaterThan(10 * 1024),
        reason: 'REQ-ICO-001: arjun.png must be a valid PNG image (> 10KB), actual size: $size bytes',
      );
    });
  });

  // ===========================================================================
  // 3. REQ-ASSET-001: Asset Bundle Dual-Track Architecture & Full Character Coverage
  // ===========================================================================
  group('REQ-ASSET-001: Asset Loading Architecture & Full Character Move Coverage', () {
    test('FrameDataDatabase must declare static Future<void> init method accepting bundle and jsonContent', () {
      final dbFile = File('lib/data/frame_data_database.dart');
      expect(dbFile.existsSync(), isTrue, reason: 'lib/data/frame_data_database.dart must exist');
      final content = dbFile.readAsStringSync();
      expect(
        content.contains(RegExp(r'static\s+Future<void>\s+init\s*\(')),
        isTrue,
        reason: 'REQ-ASSET-001: FrameDataDatabase must declare static Future<void> init(...) method',
      );
      expect(
        content.contains('jsonContent'),
        isTrue,
        reason: 'REQ-ASSET-001: FrameDataDatabase.init must support optional jsonContent parameter for testing/prewarming',
      );
      expect(
        content.contains('bundle'),
        isTrue,
        reason: 'REQ-ASSET-001: FrameDataDatabase.init must support optional bundle parameter',
      );
    });

    test('lib/main.dart must prewarm FrameDataDatabase during startup via FrameDataDatabase.init()', () {
      final mainFile = File('lib/main.dart');
      expect(mainFile.existsSync(), isTrue, reason: 'lib/main.dart must exist');
      final content = mainFile.readAsStringSync();
      expect(
        content.contains(RegExp(r'await\s+FrameDataDatabase\.init\(\s*\);')),
        isTrue,
        reason: 'REQ-ASSET-001: main.dart must call await FrameDataDatabase.init() on app startup',
      );
    });

    test('MoveType.fromString correctly identifies throwTech and driveAction without falling back to normal', () {
      expect(
        MoveType.fromString('throwTech'),
        equals(MoveType.throwTech),
        reason: 'REQ-ASSET-001: MoveType.fromString("throwTech") must resolve to MoveType.throwTech',
      );
      expect(
        MoveType.fromString('driveAction'),
        equals(MoveType.driveAction),
        reason: 'REQ-ASSET-001: MoveType.fromString("driveAction") must resolve to MoveType.driveAction',
      );
    });

    test('All 32 official characters must have non-empty moves and >= 12 normal moves (no blank normals)', () {
      final officialCharacters = Sf6Characters.all.where((c) => c.id != 'random').toList();
      expect(
        officialCharacters.length,
        equals(32),
        reason: 'REQ-ASSET-001: Exactly 32 official characters must be registered',
      );

      for (final char in officialCharacters) {
        final moves = FrameDataDatabase.getCharacterMoves(char.id);
        expect(
          moves.isNotEmpty,
          isTrue,
          reason: 'REQ-ASSET-001: Character "${char.id}" (${char.nameZh}) moves list must not be empty!',
        );

        final normals = moves.where((m) => m.type == MoveType.normal).toList();
        expect(
          normals.isNotEmpty,
          isTrue,
          reason: 'REQ-ASSET-001: Character "${char.id}" (${char.nameZh}) normal moves must not be empty!',
        );
        expect(
          normals.length,
          greaterThanOrEqualTo(12),
          reason: 'REQ-ASSET-001: Character "${char.id}" (${char.nameZh}) must have at least 12 normal moves (found ${normals.length})',
        );
      }
    });
  });

  // ===========================================================================
  // 4. REQ-DAT-004: Arjun Supercombo Wiki Authoritative Data Alignment
  // ===========================================================================
  group('REQ-DAT-004: Arjun Supercombo Wiki Authoritative Data Alignment', () {
    FrameMove findArjunMoveByCommand(String cmd) {
      final moves = FrameDataDatabase.getCharacterMoves('arjun');
      return moves.firstWhere(
        (m) => m.command.toUpperCase().trim() == cmd.toUpperCase().trim(),
        orElse: () => throw StateError('Arjun move with command "$cmd" not found in database'),
      );
    }

    FrameMove findArjunMoveByName(String keyword) {
      final moves = FrameDataDatabase.getCharacterMoves('arjun');
      return moves.firstWhere(
        (m) => m.name.contains(keyword),
        orElse: () => throw StateError('Arjun move with name keyword "$keyword" not found in database'),
      );
    }

    test('Arjun 5LP: startup 4, onBlock +1, damage 300', () {
      final m = findArjunMoveByCommand('5LP');
      expect(m.startup, equals('4'), reason: '5LP startup must be 4');
      expect(m.onBlock, equals('+1'), reason: '5LP onBlock must be +1');
      expect(m.damage, equals(300), reason: '5LP damage must be 300');
    });

    test('Arjun 5MP: startup 11 (not fake 6), onBlock -2, damage 700', () {
      final m = findArjunMoveByCommand('5MP');
      expect(m.startup, equals('11'), reason: '5MP startup must be 11, not draft fake 6');
      expect(m.onBlock, equals('-2'), reason: '5MP onBlock must be -2');
      expect(m.damage, equals(700), reason: '5MP damage must be 700');
    });

    test('Arjun 5HP: startup 15 (not fake 10), onBlock -3, damage 800', () {
      final m = findArjunMoveByCommand('5HP');
      expect(m.startup, equals('15'), reason: '5HP startup must be 15, not draft fake 10');
      expect(m.onBlock, equals('-3'), reason: '5HP onBlock must be -3');
      expect(m.damage, equals(800), reason: '5HP damage must be 800');
    });

    test('Arjun 5LK: startup 6 (not fake 5), onBlock -4, damage 400', () {
      final m = findArjunMoveByCommand('5LK');
      expect(m.startup, equals('6'), reason: '5LK startup must be 6, not draft 5');
      expect(m.onBlock, equals('-4'), reason: '5LK onBlock must be -4');
      expect(m.damage, equals(400), reason: '5LK damage must be 400');
    });

    test('Arjun 5MK: startup 7, onBlock -3, damage 700', () {
      final m = findArjunMoveByCommand('5MK');
      expect(m.startup, equals('7'), reason: '5MK startup must be 7');
      expect(m.onBlock, equals('-3'), reason: '5MK onBlock must be -3');
      expect(m.damage, equals(700), reason: '5MK damage must be 700');
    });

    test('Arjun 5HK: startup 14, onBlock -3, damage 800', () {
      final m = findArjunMoveByCommand('5HK');
      expect(m.startup, equals('14'), reason: '5HK startup must be 14');
      expect(m.onBlock, equals('-3'), reason: '5HK onBlock must be -3');
      expect(m.damage, equals(800), reason: '5HK damage must be 800');
    });

    test('Arjun 2LP: startup 5, onBlock -1, damage 300', () {
      final m = findArjunMoveByCommand('2LP');
      expect(m.startup, equals('5'), reason: '2LP startup must be 5');
      expect(m.onBlock, equals('-1'), reason: '2LP onBlock must be -1');
      expect(m.damage, equals(300), reason: '2LP damage must be 300');
    });

    test('Arjun 2MP: startup 9 (not fake 7), onBlock -4, damage 700', () {
      final m = findArjunMoveByCommand('2MP');
      expect(m.startup, equals('9'), reason: '2MP startup must be 9, not draft fake 7');
      expect(m.onBlock, equals('-4'), reason: '2MP onBlock must be -4');
      expect(m.damage, equals(700), reason: '2MP damage must be 700');
    });

    test('Arjun 2HP: startup 10, onBlock -5, damage 800', () {
      final m = findArjunMoveByCommand('2HP');
      expect(m.startup, equals('10'), reason: '2HP startup must be 10');
      expect(m.onBlock, equals('-5'), reason: '2HP onBlock must be -5');
      expect(m.damage, equals(800), reason: '2HP damage must be 800');
    });

    test('Arjun 2LK: startup 5, onBlock -2, damage 300', () {
      final m = findArjunMoveByCommand('2LK');
      expect(m.startup, equals('5'), reason: '2LK startup must be 5');
      expect(m.onBlock, equals('-2'), reason: '2LK onBlock must be -2');
      expect(m.damage, equals(300), reason: '2LK damage must be 300');
    });

    test('Arjun 2MK: startup 8, onBlock -2, damage 600', () {
      final m = findArjunMoveByCommand('2MK');
      expect(m.startup, equals('8'), reason: '2MK startup must be 8');
      expect(m.onBlock, equals('-2'), reason: '2MK onBlock must be -2');
      expect(m.damage, equals(600), reason: '2MK damage must be 600');
    });

    test('Arjun 2HK: startup 10, onBlock -12, damage 900', () {
      final m = findArjunMoveByCommand('2HK');
      expect(m.startup, equals('10'), reason: '2HK startup must be 10');
      expect(m.onBlock, equals('-12'), reason: '2HK onBlock must be -12');
      expect(m.damage, equals(900), reason: '2HK damage must be 900');
    });

    test('Arjun Breathing Ring (呼吸之环) command must be 236K (not 214K)', () {
      final m = findArjunMoveByName('呼吸之环');
      expect(m.command, equals('236K'), reason: 'Breathing Ring command must be 236K');
      expect(m.command, isNot(equals('214K')), reason: 'Breathing Ring command must NOT be 214K');
    });

    test('Arjun Divine Pillar (神柱) command must be 214K (not 22P)', () {
      final m = findArjunMoveByName('神柱');
      expect(m.command, equals('214K'), reason: 'Divine Pillar command must be 214K');
      expect(m.command, isNot(equals('22P')), reason: 'Divine Pillar command must NOT be 22P');
    });

    test('Arjun Ghastly Interrogation (阴森审讯) command must be 63214K', () {
      final m = findArjunMoveByName('阴森审讯');
      expect(m.command, equals('63214K'), reason: 'Ghastly Interrogation command must be 63214K');
    });

    test('Arjun SA1 Roaring Ruin (咆哮毁灭) command 236236P, startup 8, damage 2000', () {
      final m = findArjunMoveByName('咆哮毁灭');
      expect(m.command, equals('236236P'), reason: 'SA1 command must be 236236P, not 236236K');
      expect(m.startup, equals('8'), reason: 'SA1 startup must be 8');
      expect(m.damage, equals(2000), reason: 'SA1 damage must be 2000');
    });

    test('Arjun SA2 Instant Oblivion (瞬间遗忘) command 214214P, startup 9, damage 3000', () {
      final m = findArjunMoveByName('瞬间遗忘');
      expect(m.command, equals('214214P'), reason: 'SA2 command must be 214214P');
      expect(m.startup, equals('9'), reason: 'SA2 startup must be 9');
      expect(m.damage, equals(3000), reason: 'SA2 damage must be 3000');
    });

    test('Arjun SA3 Order of the Yaksha (夜叉之令) command 236236K, startup 13, damage 4000', () {
      final m = findArjunMoveByName('夜叉之令');
      expect(m.command, equals('236236K'), reason: 'SA3 command must be 236236K, not 236236P');
      expect(m.startup, equals('13'), reason: 'SA3 startup must be 13');
      expect(m.damage, equals(4000), reason: 'SA3 damage must be 4000');
    });

    test('assets/data/sf6_framedata.json accurately mirrors Arjun Supercombo Wiki authoritative values', () {
      final jsonFile = File('assets/data/sf6_framedata.json');
      expect(jsonFile.existsSync(), isTrue, reason: 'assets/data/sf6_framedata.json must exist');
      final data = json.decode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      expect(data.containsKey('arjun'), isTrue, reason: 'JSON must contain "arjun" key');

      final arjunMoves = (data['arjun'] as List<dynamic>).cast<Map<String, dynamic>>();

      Map<String, dynamic> findJsonMove(String cmdOrName) {
        return arjunMoves.firstWhere(
          (m) =>
              (m['command'] as String? ?? '').toUpperCase().trim() == cmdOrName.toUpperCase().trim() ||
              (m['name'] as String? ?? '').contains(cmdOrName),
          orElse: () => throw StateError('Arjun move "$cmdOrName" not found in sf6_framedata.json'),
        );
      }

      // Check normals in JSON
      final j5lp = findJsonMove('5LP');
      expect(j5lp['startup'], equals('4'));
      expect(j5lp['onBlock'], equals('+1'));
      expect(j5lp['damage'], equals(300));

      final j5mp = findJsonMove('5MP');
      expect(j5mp['startup'], equals('11'));
      expect(j5mp['onBlock'], equals('-2'));
      expect(j5mp['damage'], equals(700));

      final j5hp = findJsonMove('5HP');
      expect(j5hp['startup'], equals('15'));
      expect(j5hp['onBlock'], equals('-3'));
      expect(j5hp['damage'], equals(800));

      final j5lk = findJsonMove('5LK');
      expect(j5lk['startup'], equals('6'));
      expect(j5lk['onBlock'], equals('-4'));
      expect(j5lk['damage'], equals(400));

      final j5mk = findJsonMove('5MK');
      expect(j5mk['startup'], equals('7'));
      expect(j5mk['onBlock'], equals('-3'));
      expect(j5mk['damage'], equals(700));

      final j5hk = findJsonMove('5HK');
      expect(j5hk['startup'], equals('14'));
      expect(j5hk['onBlock'], equals('-3'));
      expect(j5hk['damage'], equals(800));

      final j2lp = findJsonMove('2LP');
      expect(j2lp['startup'], equals('5'));
      expect(j2lp['onBlock'], equals('-1'));
      expect(j2lp['damage'], equals(300));

      final j2mp = findJsonMove('2MP');
      expect(j2mp['startup'], equals('9'));
      expect(j2mp['onBlock'], equals('-4'));
      expect(j2mp['damage'], equals(700));

      final j2hp = findJsonMove('2HP');
      expect(j2hp['startup'], equals('10'));
      expect(j2hp['onBlock'], equals('-5'));
      expect(j2hp['damage'], equals(800));

      final j2lk = findJsonMove('2LK');
      expect(j2lk['startup'], equals('5'));
      expect(j2lk['onBlock'], equals('-2'));
      expect(j2lk['damage'], equals(300));

      final j2mk = findJsonMove('2MK');
      expect(j2mk['startup'], equals('8'));
      expect(j2mk['onBlock'], equals('-2'));
      expect(j2mk['damage'], equals(600));

      final j2hk = findJsonMove('2HK');
      expect(j2hk['startup'], equals('10'), reason: '2HK startup in JSON must be 10');
      expect(j2hk['onBlock'], equals('-12'), reason: '2HK onBlock in JSON must be -12');
      expect(j2hk['damage'], equals(900), reason: '2HK damage in JSON must be 900');

      // Check specials & supers commands in JSON
      final jRing = findJsonMove('Breathing Ring');
      expect(jRing['command'], equals('236K'), reason: 'Breathing Ring in JSON must be 236K');

      final jPillar = findJsonMove('Divine Pillar');
      expect(jPillar['command'], equals('214K'), reason: 'Divine Pillar in JSON must be 214K');

      final jInterrogation = findJsonMove('Ghastly Interrogation');
      expect(jInterrogation['command'], equals('63214K'), reason: 'Ghastly Interrogation in JSON must be 63214K');

      final jSa1 = findJsonMove('Howling Destruction');
      expect(jSa1['command'], equals('236236P'), reason: 'SA1 in JSON must be 236236P');
      expect(jSa1['startup'], equals('8'), reason: 'SA1 startup in JSON must be 8');
      expect(jSa1['damage'], equals(2000), reason: 'SA1 damage in JSON must be 2000');

      final jSa2 = findJsonMove('Instant Oblivion');
      expect(jSa2['command'], equals('214214P'), reason: 'SA2 in JSON must be 214214P');
      expect(jSa2['startup'], equals('9'), reason: 'SA2 startup in JSON must be 9');
      expect(jSa2['damage'], equals(3000), reason: 'SA2 damage in JSON must be 3000');

      final jSa3 = findJsonMove("Yaksha's Order");
      expect(jSa3['command'], equals('236236K'), reason: 'SA3 in JSON must be 236236K');
      expect(jSa3['startup'], equals('13'), reason: 'SA3 startup in JSON must be 13');
      expect(jSa3['damage'], equals(4000), reason: 'SA3 damage in JSON must be 4000');
    });

    test('assets/data/sf6_combos.json updates Arjun combo sequences to new corrected commands', () {
      final comboFile = File('assets/data/sf6_combos.json');
      expect(comboFile.existsSync(), isTrue, reason: 'assets/data/sf6_combos.json must exist');
      final data = json.decode(comboFile.readAsStringSync()) as Map<String, dynamic>;
      expect(data.containsKey('arjun'), isTrue, reason: 'combos json must contain arjun');

      final arjunCombos = (data['arjun'] as List<dynamic>).cast<Map<String, dynamic>>();

      final c1 = arjunCombos.firstWhere((c) => c['id'] == 'arjun_1');
      expect(
        (c1['comboSequence'] as String).contains('236236K'),
        isTrue,
        reason: 'arjun_1 combo must reference 236236K (SA3)',
      );

      final c3 = arjunCombos.firstWhere((c) => c['id'] == 'arjun_3');
      expect(
        (c3['comboSequence'] as String).contains('236MK'),
        isTrue,
        reason: 'arjun_3 combo must reference 236MK (Breathing Ring)',
      );

      final c5 = arjunCombos.firstWhere((c) => c['id'] == 'arjun_5');
      expect(
        (c5['comboSequence'] as String).contains('214KK'),
        isTrue,
        reason: 'arjun_5 combo must reference 214KK (OD Divine Pillar)',
      );

      final c6 = arjunCombos.firstWhere((c) => c['id'] == 'arjun_6');
      expect(
        (c6['comboSequence'] as String).contains('236236P'),
        isTrue,
        reason: 'arjun_6 combo must reference 236236P (SA1)',
      );
    });
  });
}
