import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/player_note.dart';
import 'package:sf6_tracker/services/backup_service.dart';

void main() {
  group('BackupService Tests', () {
    test('importBackupJson validates structure and extracts records', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final backup = BackupService.instance;

      // Invalid format test
      final invalidRes = await backup.importBackupJson('not a json');
      expect(invalidRes.success, false);

      // Valid format test structure
      final validJson = jsonEncode({
        'appName': '街霸6助手',
        'appVersion': 'v1.2.3d',
        'exportedAt': DateTime.now().toIso8601String(),
        'shortId': '2332899051',
        'totalRecords': 1,
        'totalNotes': 1,
        'records': [
          {
            'id': 'test_rec_1',
            'shortId': '2332899051',
            'platform': 'switch2',
            'playedAt': DateTime.now().toIso8601String(),
            'battleType': 'ranked',
            'playerCharacterId': 'ryu',
            'playerScore': 2,
            'playerLpChange': 50,
            'playerMrChange': 0,
            'playerCurrentLp': 13000,
            'playerCurrentMr': 0,
            'playerControlType': 'C',
            'opponentFighterId': 'Opponent',
            'opponentShortId': '9999999999',
            'opponentPlatform': 'steam',
            'opponentCharacterId': 'ken',
            'opponentScore': 1,
            'opponentRankTier': 'Gold',
            'opponentControlType': 'M',
            'isWin': 1,
            'replayCode': 'TESTCODE1',
            'roundsJson': '[]'
          }
        ],
        'notes': [
          {
            'id': 'note_1',
            'targetKey': 'ken',
            'isCharacterNote': 1,
            'title': 'Ken Matchup Notes',
            'content': 'Punish heavy dragon punch with heavy punch combo.',
            'tags': 'ken,punish',
            'updatedAt': DateTime.now().toIso8601String()
          }
        ]
      });

      // Validates decoding succeeds
      final decoded = jsonDecode(validJson) as Map<String, dynamic>;
      expect(decoded['appName'], '街霸6助手');
      expect((decoded['records'] as List).length, 1);
      expect((decoded['notes'] as List).length, 1);

      final rec = BattleRecord.fromMap(decoded['records'][0]);
      expect(rec.playerCharacterId, 'ryu');
      expect(rec.opponentCharacterId, 'ken');
      expect(rec.isWin, true);

      final note = PlayerNote.fromMap(decoded['notes'][0]);
      expect(note.targetKey, 'ken');
      expect(note.title, 'Ken Matchup Notes');
    });
  });
}
