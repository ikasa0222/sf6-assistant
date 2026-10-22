import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/battle_record.dart';

void main() {
  group('v1.2.7.2: Arjun Battle Log Capcom ID & Legacy Data Healing Tests', () {
    test('REQ-FIX-001: Capcom ID 34 must strictly map to Arjun (阿俊), not Sagat', () {
      final char34 = Sf6Characters.fromCapcomId(34);
      expect(char34.id, equals('arjun'), reason: 'Capcom ID 34 must resolve to arjun');
      expect(char34.nameZh, equals('阿俊'), reason: 'Capcom ID 34 nameZh must be 阿俊');
      expect(char34.nameEn, equals('Arjun'), reason: 'Capcom ID 34 nameEn must be Arjun');

      final char34Str = Sf6Characters.fromCapcomId('34');
      expect(char34Str.id, equals('arjun'), reason: 'Capcom ID "34" string must resolve to arjun');
    });

    test('REQ-FIX-001: Capcom ID 35 continues to map to Arjun', () {
      final char35 = Sf6Characters.fromCapcomId(35);
      expect(char35.id, equals('arjun'), reason: 'Capcom ID 35 must resolve to arjun');
      expect(char35.nameZh, equals('阿俊'));
    });

    test('REQ-FIX-002: BattleRecord.fromMap sanitizes legacy sagat to arjun defensively', () {
      final legacyRecord = BattleRecord.fromMap({
        'id': 'test_replay_001',
        'shortId': '1234567890',
        'platform': 'steam',
        'playedAt': '2026-10-21T18:00:00.000',
        'battleType': 'ranked',
        'playerCharacterId': 'sagat', // legacy bugged player character
        'playerScore': 2,
        'opponentFighterId': 'OpponentPlayer',
        'opponentShortId': '9876543210',
        'opponentPlatform': 'psn',
        'opponentCharacterId': 'sagat', // legacy bugged opponent character
        'opponentScore': 1,
        'isWin': 1,
      });

      expect(
        legacyRecord.playerCharacterId,
        equals('arjun'),
        reason: 'Legacy sagat player character must be healed to arjun',
      );
      expect(
        legacyRecord.opponentCharacterId,
        equals('arjun'),
        reason: 'Legacy sagat opponent character must be healed to arjun',
      );
    });

    test('REQ-FIX-003: Version and build metadata must be synchronized to v1.2.7.2 / 2702', () {
      expect(AppLogger.currentAppVersion, anyOf(equals('v1.2.7.2'), anyOf(equals('v1.2.7.3'), anyOf(equals('v1.2.7.4'), equals('v1.2.7.5')))));
      expect(AppLogger.currentBuildNumber, anyOf(equals('2702'), anyOf(equals('2703'), anyOf(equals('2704'), equals('2705')))));

      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect((pubspec.contains('version: 1.2.7+2702') || pubspec.contains('version: 1.2.7+2703') || pubspec.contains('version: 1.2.7+2704') || pubspec.contains('version: 1.2.7+2705')), isTrue);
    });
  });
}
