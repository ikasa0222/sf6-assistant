import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/data/frame_data_database.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/services/notes_service.dart';
import 'package:sf6_tracker/utils/sf6_move_media_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FrameDataDatabase Refactor Tests', () {
    test('Every character has complete moves including jump attacks, throws, and super arts', () {
      final characters = [
        'luke', 'jamie', 'manon', 'kimberly', 'marisa', 'lily', 'jp', 'juri',
        'deejay', 'cammy', 'ryu', 'ehonda', 'blanka', 'guile', 'ken', 'chunli',
        'zangief', 'dhalsim', 'rashid', 'aki', 'ed', 'akuma', 'mbison', 'terry',
        'mai', 'elena', 'sagat', 'cviper', 'alex', 'ingrid', 'yasmine'
      ];

      for (final charId in characters) {
        final moves = FrameDataDatabase.getCharacterMoves(charId);
        expect(moves.isNotEmpty, isTrue, reason: 'Character $charId should have moves');
        
        // Check for jump normals
        final hasJumpMove = moves.any((m) => m.command.contains('8') || m.command.contains('9') || m.name.contains('跳') || m.command.startsWith('j.'));
        expect(hasJumpMove, isTrue, reason: 'Character $charId should have jump attacks');

        // Check for throws
        final hasThrow = moves.any((m) => m.name.contains('投') || m.command.contains('LP+LK') || m.type == MoveType.throwTech);
        expect(hasThrow, isTrue, reason: 'Character $charId should have throw moves');

        // Check for Super Arts
        final hasSuper = moves.any((m) => m.type == MoveType.superArt || m.name.contains('SA') || m.name.contains('超必杀'));
        expect(hasSuper, isTrue, reason: 'Character $charId should have SA moves');
      }
    });

    test('Akuma and Ken have detailed moves and correct frame metrics', () {
      final akumaMoves = FrameDataDatabase.getCharacterMoves('akuma');
      expect(akumaMoves.length, greaterThanOrEqualTo(25));
      final gouHadoken = akumaMoves.firstWhere((m) => m.name.contains('豪波动拳'));
      expect(gouHadoken.startup, equals('12'));

      final kenMoves = FrameDataDatabase.getCharacterMoves('ken');
      expect(kenMoves.length, greaterThanOrEqualTo(25));
      final hadoken = kenMoves.firstWhere((m) => m.name.contains('波动拳'));
      expect(hadoken.startup, equals('14'));
    });
  });

  group('Sf6MoveMediaHelper Tests', () {
    test('Resolves character slugs accurately', () {
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('chunli'), equals('chun-li'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('mbison'), equals('m-bison'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('deejay'), equals('dee-jay'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('ehonda'), equals('e-honda'));
      expect(Sf6MoveMediaHelper.getUfdCharacterSlug('akuma'), equals('akuma'));
    });

    test('Generates valid UltimateFrameData hitbox GIF URLs', () {
      final akumaMoves = FrameDataDatabase.getCharacterMoves('akuma');
      final lp = akumaMoves.firstWhere((m) => m.command == '5LP' || m.name.contains('轻拳'));
      final gifUrl = Sf6MoveMediaHelper.getMoveGifUrl('akuma', lp);
      expect(gifUrl, isNotNull);
      expect(gifUrl, contains('ultimateframedata.com/sf6/hitboxes/akuma/'));
    });
  });

  group('NotesService Competitive Strategy Tests', () {
    test('Default strategy notes contain authentic match-up strategies and character-specific advice', () {
      final notes = NotesService.defaultStrategyNotes;
      expect(notes.length, greaterThanOrEqualTo(10));

      final akumaNotes = notes.where((n) => n.targetKey.toLowerCase() == 'akuma').toList();
      expect(akumaNotes.isNotEmpty, isTrue);
      expect(akumaNotes.any((n) => n.content.contains('9000') || n.content.contains('血量') || n.tags.contains('确反')), isTrue);

      final kenNotes = notes.where((n) => n.targetKey.toLowerCase() == 'ken').toList();
      expect(kenNotes.isNotEmpty, isTrue);
      expect(kenNotes.any((n) => n.content.contains('龙卷') || n.content.contains('迅雷') || n.content.contains('龙尾')), isTrue);

      final zangiefNotes = notes.where((n) => n.targetKey.toLowerCase() == 'zangief').toList();
      expect(zangiefNotes.isNotEmpty, isTrue);
      expect(zangiefNotes.any((n) => n.content.contains('SPD') || n.content.contains('头锤')), isTrue);
    });
  });
}
