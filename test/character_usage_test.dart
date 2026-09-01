import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/models/user_profile.dart';

void main() {
  group('Character Usage & Rank Tests', () {
    test('fromCapcomId correctly resolves numerical IDs without fallback to Ryu', () {
      expect(Sf6Characters.fromCapcomId(1).id, equals('ryu'));
      expect(Sf6Characters.fromCapcomId(2).id, equals('luke'));
      expect(Sf6Characters.fromCapcomId(9).id, equals('cammy'));
      expect(Sf6Characters.fromCapcomId(10).id, equals('ken'));
      expect(Sf6Characters.fromCapcomId(21).id, equals('jamie'));
      expect(Sf6Characters.fromCapcomId(22).id, equals('akuma'));
      expect(Sf6Characters.fromCapcomId(26).id, equals('bison'));
      expect(Sf6Characters.fromCapcomId(27).id, equals('terry'));
      expect(Sf6Characters.fromCapcomId(28).id, equals('mai'));
      expect(Sf6Characters.fromCapcomId(29).id, equals('elena'));
      expect(Sf6Characters.fromCapcomId(30).id, equals('cviper'));
      expect(Sf6Characters.fromCapcomId(31).id, equals('alex'));
      expect(Sf6Characters.fromCapcomId(32).id, equals('ingrid'));
      expect(Sf6Characters.fromCapcomId(33).id, equals('yasmine'));
      expect(Sf6Characters.fromCapcomId(34).id, equals('sagat'));
    });

    test('Unranked characters with -1 LP or 0 LP/MR are filtered', () {
      final rawList = [
        {'character_id': 1, 'league_point': -1, 'master_rating': 0, 'play_count': 0},
        {'character_id': 29, 'league_point': 11869, 'master_rating': 0, 'play_count': 50},
        {'character_id': 10, 'league_point': 0, 'master_rating': 0, 'play_count': 0},
        {'character_id': 2, 'league_point': 28500, 'master_rating': 1650, 'play_count': 120},
      ];

      final filteredUsages = <CharacterUsage>[];
      for (final c in rawList) {
        final rawLp = c['league_point'] as int;
        final rawMr = c['master_rating'] as int;
        if (rawLp <= 0 && rawMr <= 0) continue;

        final charObj = Sf6Characters.fromCapcomId(c['character_id']);
        filteredUsages.add(CharacterUsage(
          characterId: charObj.id,
          matches: c['play_count'] as int,
          wins: 0,
          winRate: 0.0,
          lp: rawLp > 0 ? rawLp : 0,
          mr: rawMr > 0 ? rawMr : 0,
        ));
      }

      expect(filteredUsages.length, equals(2));
      expect(filteredUsages.any((u) => u.characterId == 'ryu'), isFalse);
      expect(filteredUsages.any((u) => u.characterId == 'elena'), isTrue);
      expect(filteredUsages.any((u) => u.characterId == 'luke'), isTrue);
      expect(filteredUsages.firstWhere((u) => u.characterId == 'elena').lp, equals(11869));
    });
    test('fromCapcomId resolves random character IDs to random', () {
      expect(Sf6Characters.fromCapcomId(0).id, equals('random'));
      expect(Sf6Characters.fromCapcomId('cha').id, equals('random'));
      expect(Sf6Characters.fromCapcomId('0').id, equals('random'));
      expect(Sf6Characters.fromCapcomId(254).id, equals('random'));
      expect(Sf6Characters.getById('random').shortCode, equals('?'));
    });

    test('Rank computation for 11864 LP accurately resolves to Gold 4', () {
      final rank = Sf6Rank.fromLpOrMr(11864);
      expect(rank.tier, equals(RankTier.gold));
      expect(rank.star, equals(4));
      expect(rank.nameZh, equals('黄金'));
      expect(rank.displayName, equals('黄金 4星'));
      expect(rank.lpNeeded(11864), equals(12200 - 11864));
    });
  });
}
