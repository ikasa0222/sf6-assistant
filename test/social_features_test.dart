import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/network/next_data_parser.dart';
import 'package:sf6_tracker/models/club_model.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/account_profile.dart';

void main() {
  group('Social Features & Club Model Tests', () {
    test('NextDataParser cleans leading # from club tags', () {
      final mockData = {
        'props': {
          'pageProps': {
            'circle_list': [
              {
                'circle_id': 'circle_1001',
                'circle_name': 'Tiger Dojo',
                'circle_tag': '#TGR',
                'is_main_circle': true,
                'member_count': 25,
                'emblem_url': 'https://streetfighter.com/assets/emblem1.png',
              },
              {
                'circle_id': 'circle_1002',
                'circle_name': 'Dragon Claw',
                'circle_tag': 'DRG',
                'is_main_circle': false,
                'member_count': 10,
                'emblem_url': 'https://streetfighter.com/assets/emblem2.png',
              }
            ]
          }
        }
      };

      final clubs = NextDataParser.parseClubsList(mockData);
      expect(clubs.length, equals(2));
      expect(clubs[0].tag, equals('TGR')); // Stripped '#'
      expect(clubs[0].isMainClub, isTrue);
      expect(clubs[0].emblemUrl, equals('https://streetfighter.com/assets/emblem1.png'));

      expect(clubs[1].tag, equals('DRG'));
      expect(clubs[1].isMainClub, isFalse);
      expect(clubs[1].emblemUrl, equals('https://streetfighter.com/assets/emblem2.png'));
    });

    test('ClubModel copyWith preserves emblemUrl and mainClub attributes', () {
      final original = ClubModel(
        clubId: 'cid_123',
        clubName: 'Alpha Team',
        tag: 'ALP',
        emblemUrl: 'https://streetfighter.com/emblem.png',
        isMainClub: true,
        memberCount: 20,
        members: [
          ClubMember(
            fighterId: 'PlayerA',
            shortId: '111222333',
            platform: 'steam',
            isOnline: true,
            statusText: 'Ranked Match',
            mainCharacterId: 'ryu',
            lp: 15000,
            mr: 0,
            role: '会长',
          ),
        ],
      );

      final updated = original.copyWith(memberCount: 21);
      expect(updated.emblemUrl, equals('https://streetfighter.com/emblem.png'));
      expect(updated.isMainClub, isTrue);
      expect(updated.memberCount, equals(21));
      expect(updated.members.length, equals(1));
    });

    test('Head-to-head match filter accurately separates matches against specific player', () {
      final matches = [
        BattleRecord(
          id: 'rec_1',
          shortId: 'my_short_id',
          platform: 'steam',
          playedAt: DateTime.now(),
          battleType: BattleType.ranked,
          playerCharacterId: 'ryu',
          playerScore: 2,
          opponentFighterId: 'RivalX',
          opponentShortId: 'rival_123',
          opponentPlatform: 'steam',
          opponentCharacterId: 'ken',
          opponentScore: 1,
          isWin: true,
          replayCode: 'ABC123',
          rounds: [],
        ),
        BattleRecord(
          id: 'rec_2',
          shortId: 'my_short_id',
          platform: 'steam',
          playedAt: DateTime.now().subtract(const Duration(hours: 1)),
          battleType: BattleType.ranked,
          playerCharacterId: 'ryu',
          playerScore: 0,
          opponentFighterId: 'OtherPlayer',
          opponentShortId: 'other_456',
          opponentPlatform: 'ps5',
          opponentCharacterId: 'chunli',
          opponentScore: 2,
          isWin: false,
          replayCode: 'DEF456',
          rounds: [],
        ),
      ];

      final h2h = matches.where((r) => r.opponentShortId == 'rival_123').toList();
      expect(h2h.length, equals(1));
      expect(h2h.first.isWin, isTrue);
      expect(h2h.first.opponentFighterId, equals('RivalX'));
    });

    test('NextDataParser.parseCharacterUsagesFromPlay parses LP/MR and win rates and sorts by rank', () {
      final mockPlayData = {
        'props': {
          'pageProps': {
            'play': {
              'character_league_infos': [
                {
                  'character_id': 2, // Luke
                  'league_info': {'league_point': 12000, 'master_rating': 0},
                  'play_count': 50,
                  'win_count': 30,
                  'win_rate': 60.0,
                },
                {
                  'character_id': 21, // Jamie
                  'league_info': {'league_point': 25000, 'master_rating': 1650},
                  'play_count': 120,
                  'win_count': 75,
                  'win_rate': 62.5,
                },
                {
                  'character_id': 5, // Manon
                  'league_info': {'league_point': 18000, 'master_rating': 0},
                  'play_count': 80,
                  'win_count': 44,
                  'win_rate': 55.0,
                },
              ],
              'character_win_rates': [
                {
                  'character_id': 21,
                  'play_count': 120,
                  'win_count': 75,
                  'win_rate': 62.5,
                },
              ],
            }
          }
        }
      };

      final usages = NextDataParser.parseCharacterUsagesFromPlay(mockPlayData);
      expect(usages.length, equals(3));
      // First should be Master Rating (Jamie MR 1650)
      expect(usages[0].mr, equals(1650));
      expect(usages[0].characterId, equals('jamie'));
      expect(usages[0].matches, equals(120));
      expect(usages[0].winRate, equals(62.5));

      // Second should be higher LP (Manon LP 18000)
      expect(usages[1].mr, equals(0));
      expect(usages[1].lp, equals(18000));
      expect(usages[1].characterId, equals('manon'));

      // Third should be Luke LP 12000
      expect(usages[2].mr, equals(0));
      expect(usages[2].lp, equals(12000));
      expect(usages[2].characterId, equals('luke'));
    });

    test('PlatformType.formatPlatformBadge unifies Nintendo platform to NS2', () {
      expect(PlatformType.formatPlatformBadge('nsw2'), equals('NS2'));
      expect(PlatformType.formatPlatformBadge('NSW2'), equals('NS2'));
      expect(PlatformType.formatPlatformBadge('switch'), equals('NS2'));
      expect(PlatformType.formatPlatformBadge('Switch'), equals('NS2'));
      expect(PlatformType.formatPlatformBadge('switch2'), equals('NS2'));
      expect(PlatformType.formatPlatformBadge('ns'), equals('NS2'));
      expect(PlatformType.formatPlatformBadge('steam'), equals('Steam'));
      expect(PlatformType.formatPlatformBadge('ps5'), equals('PS5'));
      expect(PlatformType.formatPlatformBadge('ps4'), equals('PS4'));
      expect(PlatformType.formatPlatformBadge('xbox'), equals('Xbox'));
    });
  });
}
