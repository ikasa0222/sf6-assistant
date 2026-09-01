import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/network/next_data_parser.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/models/battle_record.dart';

void main() {
  group('NextDataParser Tests', () {
    test('extractNextData extracts JSON from script tag', () {
      const mockHtml = '''
      <!DOCTYPE html>
      <html>
        <head>
          <script id="__NEXT_DATA__" type="application/json">
            {"props":{"pageProps":{"fighter_id":"Daigo_TheBeast","league_point":38500,"master_rating":1885}}}
          </script>
        </head>
        <body><div>SF6 Buckler</div></body>
      </html>
      ''';

      final json = NextDataParser.extractNextData(mockHtml);
      expect(json, isNotNull);
      expect(json!['props']['pageProps']['fighter_id'], equals('Daigo_TheBeast'));
      expect(json['props']['pageProps']['master_rating'], equals(1885));
    });

    test('parseUserProfile converts Next.js pageProps correctly', () {
      final mockData = {
        'props': {
          'pageProps': {
            'fighter_id': 'Tokido_Flame',
            'short_id': '192837465',
            'title_name': 'Murderous Intent',
            'club_name': 'ROHTO',
            'league_point': 39200,
            'master_rating': 1890,
            'favorite_character_id': 'ken',
            'total_matches': 1200,
            'total_wins': 780,
          }
        }
      };

      final profile = NextDataParser.parseUserProfile(mockData, platform: 'steam');
      expect(profile, isNotNull);
      expect(profile!.fighterId, equals('Tokido_Flame'));
      expect(profile.mr, equals(1890));
      expect(profile.mainCharacterId, equals('ken'));
      expect(profile.winRate, closeTo(65.0, 0.1));
    });

    test('Sf6Rank correctly assigns Master and Legend tiers', () {
      final masterRank = Sf6Rank.fromLpOrMr(28000, mr: 1750);
      expect(masterRank.tier, equals(RankTier.master));

      final legendRank = Sf6Rank.fromLpOrMr(45000, mr: 2150, rankPosition: 42);
      expect(legendRank.tier, equals(RankTier.legend));

      final diamondRank = Sf6Rank.fromLpOrMr(22000);
      expect(diamondRank.tier, equals(RankTier.diamond));
    });

    test('parseBattleLog parses Capcom buckler replay list accurately', () {
      final mockBattleData = {
        'props': {
          'pageProps': {
            'replay_list': [
              {
                'replay_id': 'RPL_998877',
                'uploaded_at': 1788091493,
                'battle_type': 1,
                'winner_side': 1,
                'player1_info': {
                  'short_id': 2332899051,
                  'fighter_id': 'Nerv的绫波丽本人',
                  'character_id': 29,
                  'league_point': 11869,
                  'round_results': [8, 1, 0],
                },
                'player2_info': {
                  'short_id': 1092834711,
                  'fighter_id': 'Opponent_Ryu',
                  'character_id': 1,
                  'league_point': 12000,
                  'round_results': [0, 0, 1],
                },
              }
            ]
          }
        }
      };

      final records = NextDataParser.parseBattleLog(
        mockBattleData,
        userShortId: '2332899051',
        platform: 'nintendoSwitch2',
      );

      expect(records.length, equals(1));
      final rec = records.first;
      expect(rec.id, equals('RPL_998877'));
      expect(rec.isWin, isTrue);
      expect(rec.playerCharacterId, equals('elena'));
      expect(rec.opponentCharacterId, equals('ryu'));
      expect(rec.playerScore, equals(2));
      expect(rec.opponentScore, equals(1));
      expect(rec.opponentFighterId, equals('Opponent_Ryu'));
    });

    test('parseClub correctly parses /club/[clubid] page with members and online status', () {
      final mockClubData = {
        'props': {
          'pageProps': {
            'circle_base_info': {
              'circle_id': 'e6aec2ca7b6c446ba35e8f3f92df36d3',
              'name': 'Rooookies',
              'total_member_count': 87,
            },
            'circle_member_list': [
              {
                'fighter_banner_info': {
                  'personal_info': {
                    'short_id': '3272837153',
                    'fighter_id': 'ByTsuya',
                    'platform_name': 'CrossPlatform',
                  },
                  'favorite_character_id': 22,
                  'favorite_character_league_info': {
                    'league_point': 3215,
                    'master_rating': 0,
                  },
                  'online_status_info': {
                    'online_status': 11,
                    'online_status_data': {
                      'online_status_name': '排位赛',
                    }
                  }
                },
                'position': 3,
              },
              {
                'fighter_banner_info': {
                  'personal_info': {
                    'short_id': '3567337749',
                    'fighter_id': '积跬步至千里',
                    'platform_name': 'CrossPlatform',
                  },
                  'favorite_character_id': 1,
                  'favorite_character_league_info': {
                    'league_point': -1,
                    'master_rating': 0,
                  },
                  'online_status_info': {
                    'online_status': 8,
                    'online_status_data': {
                      'online_status_name': '练习',
                    }
                  }
                },
                'position': 3,
              },
              {
                'fighter_banner_info': {
                  'personal_info': {
                    'short_id': '2332899051',
                    'fighter_id': 'Nerv的绫波丽本人',
                    'platform_name': 'NintendoSwitch',
                  },
                  'favorite_character_id': 29,
                  'favorite_character_league_info': {
                    'league_point': 11869,
                    'master_rating': 0,
                  },
                  'online_status_info': {
                    'online_status': 1,
                    'online_status_data': {
                      'online_status_name': '离线状态',
                    }
                  }
                },
                'position': 3,
              }
            ]
          }
        },
        'query': {
          'clubid': 'e6aec2ca7b6c446ba35e8f3f92df36d3'
        }
      };

      final club = NextDataParser.parseClub(mockClubData);
      expect(club, isNotNull);
      expect(club!.clubId, equals('e6aec2ca7b6c446ba35e8f3f92df36d3'));
      expect(club.clubName, equals('Rooookies'));
      expect(club.members.length, equals(3));
      // ByTsuya is online and in ranked
      expect(club.members.first.isOnline, isTrue);
      expect(club.members.first.statusText, equals('排位赛中'));
      // 积跬步至千里 is online and in training
      expect(club.members[1].isOnline, isTrue);
      expect(club.members[1].statusText, equals('训练模式'));
      // Nerv的绫波丽本人 is offline
      expect(club.members[2].isOnline, isFalse);
      expect(club.members[2].statusText, equals('离线'));
    });
  });
}
