import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/models/user_profile.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/friend_model.dart';
import 'package:sf6_tracker/models/club_model.dart';
import 'package:sf6_tracker/models/matchup_stat.dart';

class NextDataParser {
  static int _toInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static double _toDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static Map<String, dynamic>? extractNextData(String htmlContent) {
    try {
      final document = html_parser.parse(htmlContent);
      final scriptTag = document.querySelector('script#__NEXT_DATA__');
      if (scriptTag == null || scriptTag.text.isEmpty) {
        return null;
      }
      return jsonDecode(scriptTag.text) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing __NEXT_DATA__: $e');
      return null;
    }
  }

  static UserProfile? parseUserProfile(Map<String, dynamic> nextData, {String platform = 'steam'}) {
    try {
      final pageProps = nextData['props']?['pageProps'];
      if (pageProps == null) return null;

      final fighterProfile = pageProps['fighter_banner_info'] ?? pageProps['profile'] ?? pageProps;
      final fighterId = fighterProfile['fighter_id'] ?? fighterProfile['fighterId'] ?? 'Unknown Fighter';
      final shortId = (fighterProfile['short_id'] ?? fighterProfile['shortId'] ?? '').toString();
      final avatarUrl = fighterProfile['avatar_url'] ?? fighterProfile['character_image'] ?? '';
      final title = fighterProfile['title_name'] ?? fighterProfile['title'] ?? 'Street Fighter';
      final clubName = fighterProfile['club_name'] ?? fighterProfile['favorite_club_name'] ?? '';
      
      final lp = _toInt(fighterProfile['league_point'] ?? fighterProfile['lp']);
      final mr = _toInt(fighterProfile['master_rating'] ?? fighterProfile['mr']);
      final globalRank = fighterProfile['ranking'] ?? fighterProfile['global_rank'];
      final mainChar = fighterProfile['favorite_character_id'] ?? fighterProfile['main_character'] ?? 'luke';

      final totalMatches = _toInt(fighterProfile['total_matches'] ?? fighterProfile['play_count']);
      final totalWins = _toInt(fighterProfile['total_wins'] ?? fighterProfile['win_count']);
      final winRate = totalMatches > 0 ? (totalWins / totalMatches) * 100.0 : 0.0;

      return UserProfile(
        shortId: shortId,
        fighterId: fighterId,
        avatarUrl: avatarUrl,
        title: title,
        clubName: clubName,
        platform: platform,
        lp: lp,
        mr: mr,
        globalRank: globalRank != null ? int.tryParse(globalRank.toString()) : null,
        mainCharacterId: mainChar.toString().toLowerCase(),
        totalMatches: totalMatches,
        totalWins: totalWins,
        winRate: winRate,
        radarStats: RadarStats.defaultStats(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error parsing UserProfile from pageProps: $e');
      return null;
    }
  }

  static List<BattleRecord> parseBattleLog(
    Map<String, dynamic> nextData, {
    required String userShortId,
    required String platform,
  }) {
    final records = <BattleRecord>[];
    try {
      final pageProps = nextData['props']?['pageProps'];
      final rawList = pageProps != null
          ? (pageProps['replay_list'] ?? pageProps['battle_list'] ?? pageProps['battlelog'] ?? pageProps['replays'])
          : (nextData['replay_list'] ?? nextData['battle_list'] ?? nextData['battlelog'] ?? nextData['replays']);

      if (rawList is! List) return records;

      for (final item in rawList) {
        if (item is! Map<String, dynamic>) continue;

        final replayId = (item['replay_id'] ?? item['replayId'] ?? item['id'] ?? '').toString();

        // 1. Resolve playedAt timestamp
        DateTime playedAt = DateTime.now();
        final rawTime = item['uploaded_at'] ?? item['played_at'] ?? item['created_at'] ?? item['time'];
        if (rawTime is int) {
          if (rawTime > 10000000000) {
            playedAt = DateTime.fromMillisecondsSinceEpoch(rawTime);
          } else {
            playedAt = DateTime.fromMillisecondsSinceEpoch(rawTime * 1000);
          }
        } else if (rawTime is String && rawTime.isNotEmpty) {
          final parsedInt = int.tryParse(rawTime);
          if (parsedInt != null) {
            if (parsedInt > 10000000000) {
              playedAt = DateTime.fromMillisecondsSinceEpoch(parsedInt);
            } else {
              playedAt = DateTime.fromMillisecondsSinceEpoch(parsedInt * 1000);
            }
          } else {
            playedAt = DateTime.tryParse(rawTime) ?? DateTime.now();
          }
        }

        // 2. Resolve players
        final p1 = item['player1_info'] ?? item['player1'] ?? item['p1'] ?? {};
        final p2 = item['player2_info'] ?? item['player2'] ?? item['p2'] ?? {};

        final p1Sid = (p1['player']?['short_id'] ?? p1['player_info']?['short_id'] ?? p1['personal_info']?['short_id'] ?? p1['short_id'] ?? p1['sid'] ?? p1['user_id'] ?? p1['shortId'] ?? '').toString();
        final p2Sid = (p2['player']?['short_id'] ?? p2['player_info']?['short_id'] ?? p2['personal_info']?['short_id'] ?? p2['short_id'] ?? p2['sid'] ?? p2['user_id'] ?? p2['shortId'] ?? '').toString();

        final p1Fid = (p1['player']?['fighter_id'] ?? p1['player_info']?['fighter_id'] ?? p1['personal_info']?['fighter_id'] ?? p1['fighter_id'] ?? '').toString();
        final p2Fid = (p2['player']?['fighter_id'] ?? p2['player_info']?['fighter_id'] ?? p2['personal_info']?['fighter_id'] ?? p2['fighter_id'] ?? '').toString();

        bool isP1User = true;
        if (userShortId.isNotEmpty) {
          if (p1Sid == userShortId || p1Sid.contains(userShortId)) {
            isP1User = true;
          } else if (p2Sid == userShortId || p2Sid.contains(userShortId)) {
            isP1User = false;
          }
        }

        final userPlayer = isP1User ? p1 : p2;
        final oppPlayer = isP1User ? p2 : p1;

        // 3. Resolve scores & win
        final userRounds = userPlayer['round_results'] as List?;
        final oppRounds = oppPlayer['round_results'] as List?;

        int countWins(List? rounds) {
          if (rounds == null) return 0;
          return rounds.where((r) {
            if (r == null) return false;
            if (r is num) return r > 0;
            if (r is bool) return r;
            if (r is String) {
              final parsed = int.tryParse(r);
              return parsed != null ? parsed > 0 : (r.isNotEmpty && r != '0' && r != 'false');
            }
            return false;
          }).length;
        }

        int userScore = countWins(userRounds);
        int oppScore = countWins(oppRounds);

        if (userScore == 0 && oppScore == 0 && item['player1_score'] != null && item['player2_score'] != null) {
          userScore = (isP1User ? item['player1_score'] : item['player2_score']) as int;
          oppScore = (isP1User ? item['player2_score'] : item['player1_score']) as int;
        }

        final winnerSide = item['winner_side'] ?? item['winner'] ?? item['winner_id'];
        bool isWin = false;
        if (winnerSide != null) {
          isWin = winnerSide == (isP1User ? 1 : 2) || (winnerSide.toString() == (isP1User ? p1Sid : p2Sid));
        } else {
          isWin = userScore > oppScore;
        }

        // 4. Resolve characters
        final rawUserChar = userPlayer['character_id'] ??
            userPlayer['character_tool_name'] ??
            userPlayer['character_name'] ??
            userPlayer['char_id'] ??
            userPlayer['character']?['id'] ??
            userPlayer['character']?['character_id'] ??
            userPlayer['playing_character_id'] ??
            userPlayer['battle_character_id'] ??
            1;

        final rawOppChar = oppPlayer['character_id'] ??
            oppPlayer['character_tool_name'] ??
            oppPlayer['character_name'] ??
            oppPlayer['char_id'] ??
            oppPlayer['character']?['id'] ??
            oppPlayer['character']?['character_id'] ??
            oppPlayer['playing_character_id'] ??
            oppPlayer['battle_character_id'] ??
            1;

        final userChar = Sf6Characters.fromCapcomId(rawUserChar);
        final oppChar = Sf6Characters.fromCapcomId(rawOppChar);

        // 5. Resolve battle type
        BattleType battleType = BattleType.ranked;
        final rawBt = item['replay_battle_type'] ?? item['battle_type'] ?? item['battleType'];
        if (rawBt == 1 || rawBt == '1' || rawBt == 'ranked') {
          battleType = BattleType.ranked;
        } else if (rawBt == 2 || rawBt == '2' || rawBt == 'casual') {
          battleType = BattleType.casual;
        } else if (rawBt == 3 || rawBt == '3' || rawBt == 'custom' || rawBt == 'room') {
          battleType = BattleType.customRoom;
        } else if (rawBt == 4 || rawBt == '4' || rawBt == 'hub' || rawBt == 'battlehub') {
          battleType = BattleType.battleHub;
        }

        final rounds = <RoundDetail>[];
        if (userRounds != null && oppRounds != null) {
          final maxLen = userRounds.length > oppRounds.length ? userRounds.length : oppRounds.length;
          for (var i = 0; i < maxLen; i++) {
            final uCode = i < userRounds.length ? (userRounds[i] is num ? (userRounds[i] as num).toInt() : (int.tryParse(userRounds[i].toString()) ?? 0)) : 0;
            final oCode = i < oppRounds.length ? (oppRounds[i] is num ? (oppRounds[i] as num).toInt() : (int.tryParse(oppRounds[i].toString()) ?? 0)) : 0;
            if (uCode == 0 && oCode == 0) continue;
            final isPlayerRoundWin = uCode > 0;
            final winCode = isPlayerRoundWin ? uCode : oCode;
            rounds.add(RoundDetail(
              roundNum: i + 1,
              isPlayerWin: isPlayerRoundWin,
              finishType: winCode >= 8 ? RoundFinishType.ca : (winCode >= 4 ? RoundFinishType.perfect : RoundFinishType.ko),
            ));
          }
        }

        final opponentFighterName = (oppPlayer['player']?['fighter_id'] ?? oppPlayer['player_info']?['fighter_id'] ?? oppPlayer['personal_info']?['fighter_id'] ?? oppPlayer['fighter_id'] ?? '对手').toString();
        final finalOppShortId = (oppPlayer['player']?['short_id'] ?? oppPlayer['player_info']?['short_id'] ?? oppPlayer['personal_info']?['short_id'] ?? oppPlayer['short_id'] ?? '').toString();

        final userCtrl = (userPlayer['battle_input_type'] == 1 || userPlayer['control_type'] == 1 || userPlayer['input_type'] == 1) ? 'M' : 'C';
        final oppCtrl = (oppPlayer['battle_input_type'] == 1 || oppPlayer['control_type'] == 1 || oppPlayer['input_type'] == 1) ? 'M' : 'C';

        String resolvePlatform(Map p) {
          final pName = (p['platform_name'] ?? p['player']?['platform_name'] ?? p['player_info']?['platform_name'] ?? p['personal_info']?['platform_name'] ?? p['platform'] ?? '').toString().toLowerCase();
          if (pName.contains('steam') || pName.contains('pc')) return 'steam';
          if (pName.contains('ps5') || pName.contains('playstation_5')) return 'ps5';
          if (pName.contains('ps4') || pName.contains('playstation_4')) return 'ps4';
          if (pName.contains('xbox')) return 'xbox';
          if (pName.contains('switch')) return 'switch2';

          final hw = p['hardware_type'] ?? p['player']?['hardware_type'] ?? p['player_info']?['hardware_type'] ?? p['personal_info']?['hardware_type'];
          if (hw != null) {
            final hwInt = hw is num ? hw.toInt() : int.tryParse(hw.toString());
            if (hwInt == 1) return 'steam';
            if (hwInt == 2) return 'ps5';
            if (hwInt == 3) return 'ps4';
            if (hwInt == 4) return 'xbox';
            if (hwInt == 5) return 'switch2';
          }
          return 'cross';
        }

        records.add(BattleRecord(
          id: replayId.isNotEmpty ? replayId : 'match_${playedAt.millisecondsSinceEpoch}_${finalOppShortId}_${records.length}',
          shortId: userShortId,
          platform: platform,
          playedAt: playedAt,
          battleType: battleType,
          playerCharacterId: userChar.id,
          playerScore: userScore,
          playerLpChange: _toInt(userPlayer['league_point_diff'] ?? userPlayer['lp_change'] ?? userPlayer['point_diff']),
          playerMrChange: _toInt(userPlayer['master_rating_diff'] ?? userPlayer['mr_change'] ?? userPlayer['mr_diff']),
          playerCurrentLp: userPlayer['league_point'] != null ? _toInt(userPlayer['league_point']) : (userPlayer['lp'] != null ? _toInt(userPlayer['lp']) : null),
          playerCurrentMr: userPlayer['master_rating'] != null ? _toInt(userPlayer['master_rating']) : (userPlayer['mr'] != null ? _toInt(userPlayer['mr']) : null),
          playerControlType: userCtrl,
          opponentFighterId: opponentFighterName,
          opponentShortId: finalOppShortId,
          opponentPlatform: resolvePlatform(oppPlayer),
          opponentCharacterId: oppChar.id,
          opponentScore: oppScore,
          opponentLp: oppPlayer['league_point'] != null ? _toInt(oppPlayer['league_point']) : (oppPlayer['lp'] != null ? _toInt(oppPlayer['lp']) : null),
          opponentMr: oppPlayer['master_rating'] != null ? _toInt(oppPlayer['master_rating']) : (oppPlayer['mr'] != null ? _toInt(oppPlayer['mr']) : null),
          opponentRankTier: (oppPlayer['rank_tier'] ?? oppPlayer['league_rank_name'] ?? 'Gold').toString(),
          opponentControlType: oppCtrl,
          isWin: isWin,
          replayCode: replayId,
          rounds: rounds,
        ));
      }
    } catch (e) {
      print('Error parsing BattleLog: $e');
    }
    return records;
  }

  static List<FriendModel> parseFriends(Map<String, dynamic> nextData) {
    final friends = <FriendModel>[];
    try {
      final pageProps = nextData['props']?['pageProps'] ?? nextData;
      final rawList = pageProps['friend_list'] ?? pageProps['friends'] ?? pageProps['fighter_list'];
      if (rawList is! List) return friends;

      for (final item in rawList) {
        if (item is! Map) continue;
        final banner = item['fighter_banner_info'] is Map ? item['fighter_banner_info'] as Map : item;
        final personal = banner['personal_info'] is Map ? banner['personal_info'] as Map : (item['personal_info'] is Map ? item['personal_info'] as Map : banner);
        final league = banner['favorite_character_league_info'] is Map ? banner['favorite_character_league_info'] as Map : (item['favorite_character_league_info'] is Map ? item['favorite_character_league_info'] as Map : banner);

        final shortId = (personal['short_id'] ?? banner['short_id'] ?? item['short_id'] ?? '').toString().trim();
        
        String fighterId = '';
        for (final candidate in [
          personal['fighter_id'],
          personal['player_name'],
          personal['name'],
          personal['nickname'],
          banner['fighter_id'],
          banner['player_name'],
          item['fighter_id'],
          item['player_name'],
          item['name'],
        ]) {
          if (candidate != null && candidate.toString().trim().isNotEmpty) {
            fighterId = candidate.toString().trim();
            break;
          }
        }
        if (fighterId.isEmpty) {
          fighterId = shortId.isNotEmpty ? '格斗家_$shortId' : 'SF6好友';
        }

        final rawCharId = banner['favorite_character_id'] ?? item['favorite_character_id'] ?? item['character_id'] ?? 1;
        final charId = Sf6Characters.fromCapcomId(rawCharId).id;
        final rawLp = _toInt(league['league_point'] ?? item['league_point'] ?? item['lp']);
        final rawMr = _toInt(league['master_rating'] ?? item['master_rating'] ?? item['mr']);
        final lp = rawLp > 0 ? rawLp : 0;
        final mr = rawMr > 0 ? rawMr : 0;

        // Accurate Capcom online_status_info parsing
        final statusInfo = (banner['online_status_info'] is Map
            ? banner['online_status_info'] as Map
            : (item['online_status_info'] is Map ? item['online_status_info'] as Map : {})) as Map;
        final statusData = (statusInfo['online_status_data'] is Map ? statusInfo['online_status_data'] as Map : {}) as Map;
        final rawStatusName = (statusData['online_status_name'] ?? statusInfo['online_status_name'] ?? '').toString().trim();
        final statusCode = _toInt(statusInfo['online_status'] ?? item['online_status'], 1);

        final bool isOnline = ((statusCode > 1) && (rawStatusName != '离线状态') && rawStatusName.isNotEmpty) ||
            item['is_online'] == true || item['is_online'] == 1 || item['status'] == 'online';
        
        String statusText = '离线';
        if (isOnline) {
          if (rawStatusName.contains('排位')) {
            statusText = '排位赛中';
          } else if (rawStatusName.contains('练习') || rawStatusName.contains('训练')) {
            statusText = '训练模式';
          } else if (rawStatusName.contains('休闲')) {
            statusText = '休闲匹配';
          } else if (rawStatusName.contains('格斗中心') || rawStatusName.contains('大厅')) {
            statusText = '格斗中心';
          } else if (rawStatusName.isNotEmpty && rawStatusName != '离线状态') {
            statusText = rawStatusName;
          } else {
            statusText = '在线';
          }
        }

        friends.add(FriendModel(
          shortId: shortId,
          fighterId: fighterId,
          avatarUrl: (banner['avatar_url'] ?? item['avatar_url'] ?? '').toString(),
          platform: (personal['platform_name'] ?? item['platform'] ?? 'nintendo_switch_2').toString().toLowerCase(),
          isOnline: isOnline,
          statusText: statusText,
          mainCharacterId: charId,
          lp: lp,
          mr: mr,
          lastSeen: DateTime.tryParse(item['last_login_at']?.toString() ?? '') ?? DateTime.now(),
        ));
      }
    } catch (e) {
      print('Error parsing friends: $e');
    }
    return friends;
  }

  static ClubModel? parseClub(Map<String, dynamic> nextData) {
    try {
      final pageProps = nextData['props']?['pageProps'] ?? nextData;
      final query = nextData['query'] as Map<String, dynamic>? ?? {};
      final clubInfo = pageProps['circle_base_info'] ?? pageProps['club_info'] ?? pageProps['club'] ?? pageProps['circle'] ?? pageProps['joined_circle_list']?.firstOrNull;
      if (clubInfo == null && pageProps['circle_member_list'] == null && pageProps['member_list'] == null && pageProps['club_members'] == null) return null;

      final infoMap = clubInfo is Map ? clubInfo as Map<String, dynamic> : <String, dynamic>{};
      final setting = infoMap['circle_setting'] is Map ? infoMap['circle_setting'] as Map : {};

      final rawClubId = (infoMap['circle_id'] ?? infoMap['club_id'] ?? setting['circle_id'] ?? query['clubid'] ?? query['sid'] ?? infoMap['id'] ?? '').toString();
      final clubName = (infoMap['name'] ?? infoMap['circle_name'] ?? infoMap['club_name'] ?? setting['circle_name'] ?? '战队俱乐部').toString();
      final tag = (infoMap['circle_tag'] ?? infoMap['tag'] ?? setting['circle_tag'] ?? (clubName.length > 4 ? clubName.substring(0, 4) : clubName)).toString().toUpperCase();
      
      String cleanNotice = '';
      for (final candidate in [
        setting['comment'],
        setting['notice'],
        infoMap['comment'],
        infoMap['notice'],
        infoMap['policy'],
      ]) {
        if (candidate != null) {
          final str = candidate.toString().trim();
          if (str.isNotEmpty && !str.startsWith('{') && !str.contains('circle_name_setting')) {
            cleanNotice = str;
            break;
          }
        }
      }
      if (cleanNotice.isEmpty) cleanNotice = '欢迎加入战队交流与切磋！';

      final emblem = (infoMap['emblem_url'] ?? (infoMap['emblem'] is Map ? infoMap['emblem']['emblem_url'] : '') ?? '').toString();

      // Leader information
      final leaderObj = infoMap['leader'] is Map ? infoMap['leader'] as Map : (infoMap['leader_info'] is Map ? infoMap['leader_info'] as Map : {});
      final leaderPersonal = leaderObj['personal_info'] is Map ? leaderObj['personal_info'] as Map : leaderObj;
      final leaderShortId = (leaderPersonal['short_id'] ?? leaderObj['short_id'] ?? '').toString();
      final leaderFighterId = (leaderPersonal['fighter_id'] ?? leaderObj['fighter_id'] ?? '').toString();
      final leaderPlatform = (leaderPersonal['platform_name'] ?? leaderObj['platform_name'] ?? leaderObj['platform_tool_name'] ?? 'steam').toString();

      // Members parsing
      final rawMembers = pageProps['circle_member_list'] ?? pageProps['member_list'] ?? pageProps['club_members'] ?? pageProps['members'] ?? infoMap['members'] ?? [];
      final members = parseClubMembers(rawMembers, leaderShortId: leaderShortId);

      final totalMembers = _toInt(infoMap['total_member_count'] ?? infoMap['member_count'] ?? setting['member_count'], (members.isNotEmpty ? members.length : 1));
      final maxMembers = _toInt(setting['max_circle_member_number'] ?? infoMap['max_member_count'] ?? infoMap['max_members'], 100);
      final points = _toInt(infoMap['recently_point'] ?? infoMap['total_point'] ?? infoMap['total_points'] ?? setting['total_points'], 0);
      final onlineCount = _toInt(infoMap['online_member_count'] ?? pageProps['online_member_count'] ?? members.where((m) => m.isOnline).length, 0);

      // Extract tags
      final tags = <String>[];
      for (final tKey in ['tag1', 'tag2', 'tag3']) {
        final tObj = setting[tKey];
        if (tObj is Map && tObj['tag_name'] != null) {
          final tName = tObj['tag_name'].toString();
          final opt = (tObj['tag_option_name'] ?? '').toString();
          final formatted = tName.replaceAll('{{message1}}', opt).trim();
          if (formatted.isNotEmpty) tags.add(formatted);
        }
      }

      final isMain = pageProps['main_circle_id'] == rawClubId || pageProps['main_circle_flg'] == true || infoMap['main_circle_flg'] == true;

      return ClubModel(
        clubId: rawClubId,
        clubName: clubName,
        tag: tag,
        emblemUrl: emblem,
        notice: cleanNotice,
        memberCount: totalMembers > members.length ? totalMembers : (members.isNotEmpty ? members.length : totalMembers),
        maxMemberCount: maxMembers,
        totalMonthlyPoints: points,
        isMainClub: isMain,
        onlineMemberCount: onlineCount > 0 ? onlineCount : members.where((m) => m.isOnline).length,
        leaderFighterId: leaderFighterId,
        leaderShortId: leaderShortId,
        leaderPlatform: leaderPlatform,
        tags: tags,
        members: members,
      );
    } catch (e) {
      print('Error parsing club: $e');
      return null;
    }
  }

  static List<ClubModel> parseClubsList(Map<String, dynamic> nextData) {
    final clubs = <ClubModel>[];
    try {
      final pageProps = nextData['props']?['pageProps'] ?? nextData;
      final query = nextData['query'] as Map<String, dynamic>? ?? {};
      final mainCircleId = (pageProps['main_circle_id'] ?? '').toString();
      final joinedList = pageProps['joined_circle_list'] ?? pageProps['circle_list'] ?? pageProps['clubs'] ?? pageProps['club_list'];

      if (joinedList is List && joinedList.isNotEmpty) {
        for (final item in joinedList) {
          if (item is! Map) continue;
          final base = item['circle_base_info'] is Map ? item['circle_base_info'] as Map : item;
          final setting = base['circle_setting'] is Map ? base['circle_setting'] as Map : (item['circle_setting'] is Map ? item['circle_setting'] as Map : {});

          final clubId = (base['circle_id'] ?? base['club_id'] ?? setting['circle_id'] ?? item['circle_id'] ?? item['club_id'] ?? item['id'] ?? query['clubid'] ?? '').toString();
          final clubName = (base['name'] ?? base['circle_name'] ?? setting['circle_name'] ?? setting['name'] ?? item['circle_name'] ?? item['name'] ?? '战队俱乐部').toString();
          final tag = (base['circle_tag'] ?? base['tag'] ?? setting['circle_tag'] ?? setting['tag'] ?? item['circle_tag'] ?? (clubName.length > 4 ? clubName.substring(0, 4) : clubName)).toString().toUpperCase();
          
          String cleanNotice = '';
          final candidates = [
            setting['comment'],
            setting['notice'],
            setting['policy'],
            setting['message'],
            base['comment'],
            base['notice'],
            item['comment'],
            item['notice'],
          ];
          for (final c in candidates) {
            if (c != null) {
              final str = c.toString().trim();
              if (str.isNotEmpty && !str.startsWith('{') && !str.contains('background:') && !str.contains('circle_name_setting')) {
                cleanNotice = str;
                break;
              }
            }
          }
          if (cleanNotice.isEmpty) {
            cleanNotice = '欢迎加入战队交流与切磋！';
          }

          final memberCount = _toInt(base['total_member_count'] ?? base['member_count'] ?? setting['member_count'] ?? item['member_count'], 1);
          final maxCount = _toInt(setting['max_circle_member_number'] ?? base['max_member_count'] ?? item['max_members'], 100);
          final points = _toInt(base['recently_point'] ?? base['total_point'] ?? base['total_points'] ?? setting['total_points'] ?? item['total_points'], 0);
          final emblem = base['emblem'] is Map ? (base['emblem']['emblem_url'] ?? '') : (base['emblem_url'] ?? '');
          final onlineCount = _toInt(item['online_member_count'] ?? base['online_member_count'], 0);
          final isMain = item['main_circle_flg'] == true || (mainCircleId.isNotEmpty && clubId == mainCircleId);

          // Extract tags
          final tags = <String>[];
          for (final tKey in ['tag1', 'tag2', 'tag3']) {
            final tObj = setting[tKey];
            if (tObj is Map && tObj['tag_name'] != null) {
              final tName = tObj['tag_name'].toString();
              final opt = (tObj['tag_option_name'] ?? '').toString();
              final formatted = tName.replaceAll('{{message1}}', opt).trim();
              if (formatted.isNotEmpty) tags.add(formatted);
            }
          }

          // Leader info
          final leaderObj = base['leader'] ?? item['leader'] ?? base['leader_info'] ?? item['circle_leader'];
          String leaderFighterId = '';
          String leaderShortId = '';
          String leaderPlatform = 'steam';
          if (leaderObj is Map) {
            final lPersonal = leaderObj['personal_info'] is Map ? leaderObj['personal_info'] as Map : leaderObj;
            leaderShortId = (lPersonal['short_id'] ?? leaderObj['short_id'] ?? '').toString().trim();
            leaderFighterId = (lPersonal['fighter_id'] ?? leaderObj['fighter_id'] ?? '').toString().trim();
            leaderPlatform = (lPersonal['platform_name'] ?? leaderObj['platform_name'] ?? leaderObj['platform_tool_name'] ?? 'steam').toString();
          }

          final rawMembers = item['circle_member_list'] ?? item['member_list'] ?? item['members'] ?? base['circle_member_list'] ?? base['member_list'] ?? base['members'] ?? [];
          var members = parseClubMembers(rawMembers, leaderShortId: leaderShortId);

          if (members.isEmpty && leaderObj is Map) {
            final lPersonal = leaderObj['personal_info'] is Map ? leaderObj['personal_info'] as Map : leaderObj;
            final lBanner = leaderObj['fighter_banner_info'] is Map ? leaderObj['fighter_banner_info'] as Map : leaderObj;
            final lLeague = leaderObj['favorite_character_league_info'] is Map ? leaderObj['favorite_character_league_info'] as Map : leaderObj;
            final lRawChar = lBanner['favorite_character_id'] ?? leaderObj['favorite_character_id'] ?? 1;
            final lCharId = Sf6Characters.fromCapcomId(lRawChar).id;
            final lRawLp = _toInt(lLeague['league_point'] ?? leaderObj['league_point'] ?? leaderObj['lp']);
            final lRawMr = _toInt(lLeague['master_rating'] ?? leaderObj['master_rating'] ?? leaderObj['mr']);
            final lLp = lRawLp > 0 ? lRawLp : 0;
            final lMr = lRawMr > 0 ? lRawMr : 0;
            final lOnline = leaderObj['is_online'] == true || leaderObj['is_online'] == 1 || leaderObj['login_status'] == 1;

            members.add(ClubMember(
              shortId: leaderShortId,
              fighterId: leaderFighterId.isNotEmpty ? leaderFighterId : '战队会长',
              role: '战队会长',
              platform: leaderPlatform.toLowerCase(),
              mainCharacterId: lCharId,
              lp: lLp,
              mr: lMr,
              isOnline: lOnline,
              statusText: lOnline ? '大厅在线' : '离线',
            ));
          }

          clubs.add(ClubModel(
            clubId: clubId,
            clubName: clubName,
            tag: tag,
            emblemUrl: emblem.toString(),
            notice: cleanNotice,
            memberCount: memberCount > members.length ? memberCount : (members.isNotEmpty ? members.length : memberCount),
            maxMemberCount: maxCount,
            totalMonthlyPoints: points,
            isMainClub: isMain,
            onlineMemberCount: onlineCount > 0 ? onlineCount : members.where((m) => m.isOnline).length,
            leaderFighterId: leaderFighterId,
            leaderShortId: leaderShortId,
            leaderPlatform: leaderPlatform,
            tags: tags,
            members: members,
          ));
        }
      }
      if (clubs.isEmpty) {
        final singleClub = parseClub(nextData);
        if (singleClub != null) clubs.add(singleClub);
      }
    } catch (e) {
      print('Error parsing clubs list: $e');
    }
    return clubs;
  }

  static List<ClubMember> parseClubMembers(dynamic rawMembers, {String platform = 'steam', String leaderShortId = ''}) {
    final members = <ClubMember>[];
    if (rawMembers is List) {
      for (final m in rawMembers) {
        if (m is! Map) continue;
        final banner = m['fighter_banner_info'] is Map ? m['fighter_banner_info'] as Map : m;
        final personal = banner['personal_info'] is Map ? banner['personal_info'] as Map : (m['personal_info'] is Map ? m['personal_info'] as Map : banner);
        final league = banner['favorite_character_league_info'] is Map ? banner['favorite_character_league_info'] as Map : (m['favorite_character_league_info'] is Map ? m['favorite_character_league_info'] as Map : banner);

        final shortId = (personal['short_id'] ?? banner['short_id'] ?? m['short_id'] ?? '').toString().trim();
        
        String fighterId = '';
        for (final candidate in [
          personal['fighter_id'],
          personal['player_name'],
          personal['name'],
          banner['fighter_id'],
          banner['player_name'],
          m['fighter_id'],
          m['player_name'],
          m['name'],
        ]) {
          if (candidate != null && candidate.toString().trim().isNotEmpty) {
            fighterId = candidate.toString().trim();
            break;
          }
        }
        if (fighterId.isEmpty) {
          fighterId = shortId.isNotEmpty ? '成员_$shortId' : '战队成员';
        }

        final rawCharId = banner['favorite_character_id'] ?? m['favorite_character_id'] ?? m['character_id'] ?? 1;
        final charId = Sf6Characters.fromCapcomId(rawCharId).id;
        final rawLp = _toInt(league['league_point'] ?? m['league_point'] ?? m['lp']);
        final rawMr = _toInt(league['master_rating'] ?? m['master_rating'] ?? m['mr']);
        final lp = rawLp > 0 ? rawLp : 0;
        final mr = rawMr > 0 ? rawMr : 0;
        
        // Accurate Capcom online_status_info parsing
        final statusInfo = (banner['online_status_info'] is Map
            ? banner['online_status_info'] as Map
            : (m['online_status_info'] is Map ? m['online_status_info'] as Map : {})) as Map;
        final statusData = (statusInfo['online_status_data'] is Map ? statusInfo['online_status_data'] as Map : {}) as Map;
        final rawStatusName = (statusData['online_status_name'] ?? statusInfo['online_status_name'] ?? '').toString().trim();
        final statusCode = _toInt(statusInfo['online_status'] ?? m['online_status'], 1);

        // Battle Hub Server Info
        final bhRegion = (statusInfo['battlehub_region_name'] ?? '').toString().trim();
        final bhServer = (statusInfo['battlehub_formated_server_no'] ?? '').toString().trim();
        final bhFull = (bhRegion.isNotEmpty && bhServer.isNotEmpty) ? '$bhRegion $bhServer' : bhRegion;

        // In Capcom Buckler: online_status == 1 is "离线状态". Any statusCode > 1 (e.g. 8=练习, 11=排位赛, 12=休闲赛, 4=格斗中心) is ONLINE!
        final bool isOnline = (statusCode > 1) || 
            (rawStatusName.isNotEmpty && rawStatusName != '离线状态' && rawStatusName != '离线') ||
            (m['is_online'] == true || m['is_online'] == 1);
        
        String statusText = '离线';
        if (isOnline) {
          if (bhFull.isNotEmpty) {
            statusText = '格斗中心 ($bhFull)';
          } else if (rawStatusName.contains('排位')) {
            statusText = '排位赛中';
          } else if (rawStatusName.contains('练习') || rawStatusName.contains('训练')) {
            statusText = '训练模式';
          } else if (rawStatusName.contains('休闲')) {
            statusText = '休闲匹配';
          } else if (rawStatusName.contains('格斗中心') || rawStatusName.contains('大厅')) {
            statusText = '格斗中心';
          } else if (rawStatusName.contains('房') || rawStatusName.contains('自定义')) {
            statusText = '自定义房';
          } else if (rawStatusName.isNotEmpty && rawStatusName != '离线状态' && rawStatusName != '离线') {
            statusText = rawStatusName;
          } else {
            statusText = '大厅在线';
          }
        }

        final pos = m['position'] ?? m['role'] ?? m['circle_member_role'] ?? 3;
        String role = '战队成员';
        final isLeader = (shortId.isNotEmpty && leaderShortId.isNotEmpty && shortId == leaderShortId) ||
            pos == 1 || pos == '1' || m['is_leader'] == true;
        final isSubLeader = pos == 2 || pos == '2' || m['role']?.toString().contains('副') == true;

        if (isLeader) {
          role = '战队会长';
        } else if (isSubLeader) {
          role = '副会长';
        }

        final platName = (personal['platform_tool_name'] ?? personal['platform_name'] ?? m['platform'] ?? platform).toString().toLowerCase();

        members.add(ClubMember(
          shortId: shortId,
          fighterId: fighterId,
          avatarUrl: (banner['avatar_url'] ?? m['avatar_url'] ?? '').toString(),
          role: role,
          platform: platName,
          mainCharacterId: charId,
          lp: lp,
          mr: mr,
          isOnline: isOnline,
          statusText: statusText,
          battleHubServer: bhFull,
          monthlyPoints: _toInt(m['monthly_point'] ?? m['recently_point'] ?? m['total_point'] ?? 0),
        ));
      }

      // Sort: Online members first, then leader/subleader, then points
      members.sort((a, b) {
        if (a.isOnline != b.isOnline) {
          return a.isOnline ? -1 : 1;
        }
        final aIsLeader = a.role.contains('会长');
        final bIsLeader = b.role.contains('会长');
        if (aIsLeader != bIsLeader) {
          return aIsLeader ? -1 : 1;
        }
        if (b.mr != a.mr) return b.mr.compareTo(a.mr);
        return b.lp.compareTo(a.lp);
      });
    }
    return members;
  }

  static RadarStats parseRadarStats(Map<String, dynamic> stats) {
    if (stats.isEmpty) return RadarStats.defaultStats();
    try {
      final di = _toDouble(stats['drive_impact']);
      final diToDi = _toDouble(stats['drive_impact_to_drive_impact']);
      final parry = _toDouble(stats['drive_parry']);
      final justParry = _toDouble(stats['just_parry']);
      final pc = _toDouble(stats['punish_counter']);
      final rcvPc = _toDouble(stats['received_punish_counter']);
      final throwCount = _toDouble(stats['throw_count']);
      final rcvThrow = _toDouble(stats['received_throw_count']);
      final throwTech = _toDouble(stats['throw_tech']);
      final cornerTime = _toDouble(stats['corner_time']);
      final odArts = _toDouble(stats['gauge_rate_drive_arts']);
      final diGauge = _toDouble(stats['gauge_rate_drive_impact']);
      final sa2 = _toDouble(stats['gauge_rate_sa_lv2']);
      final sa3 = _toDouble(stats['gauge_rate_sa_lv3']);
      final ca = _toDouble(stats['gauge_rate_ca']);
      final rcvStun = _toDouble(stats['received_stun']);

      final offense = ((di * 18.0 + pc * 18.0 + throwCount * 15.0 + cornerTime * 3.5)).clamp(45.0, 98.0);
      final defense = ((parry * 25.0 + justParry * 70.0 + diToDi * 50.0 + (1.5 - rcvPc) * 15.0)).clamp(45.0, 98.0);
      final technique = ((sa2 * 45.0 + sa3 * 45.0 + ca * 50.0 + pc * 15.0)).clamp(45.0, 98.0);
      final driveGauge = ((odArts * 90.0 + diGauge * 80.0 + (1.0 - rcvStun) * 20.0)).clamp(45.0, 98.0);
      final antiAir = ((throwTech * 80.0 + justParry * 90.0 + parry * 20.0 + (2.0 - rcvThrow) * 10.0)).clamp(45.0, 98.0);

      return RadarStats(
        offense: double.parse(offense.toStringAsFixed(1)),
        defense: double.parse(defense.toStringAsFixed(1)),
        technique: double.parse(technique.toStringAsFixed(1)),
        driveGauge: double.parse(driveGauge.toStringAsFixed(1)),
        antiAir: double.parse(antiAir.toStringAsFixed(1)),
      );
    } catch (e) {
      print('Error calculating radar stats: $e');
      return RadarStats.defaultStats();
    }
  }

  static Map<String, List<MatchupStat>> parseOfficialRivalMatchups(Map<String, dynamic> nextData) {
    final result = <String, List<MatchupStat>>{};
    try {
      final pageProps = nextData['props']?['pageProps'] ?? nextData;
      final play = pageProps['play'] ?? pageProps;
      final rivalList = play['character_win_rates_by_rival_character'] as List?;
      if (rivalList == null) return result;

      for (final item in rivalList) {
        if (item is! Map) continue;
        final myCapcomId = item['character_id'];
        final myChar = (myCapcomId == 253 || myCapcomId == '253') ? 'all' : Sf6Characters.fromCapcomId(myCapcomId).id;
        final list = <MatchupStat>[];
        final rivals = item['rival_character_win_rates'] as List?;
        if (rivals != null) {
          for (final r in rivals) {
            if (r is! Map) continue;
            final oppCapcomId = r['rival_character_id'] ?? r['character_id'];
            if (oppCapcomId == 253 || oppCapcomId == '253') continue;
            final oppChar = Sf6Characters.fromCapcomId(oppCapcomId);
            final total = _toInt(r['battle_count'] ?? r['play_count'] ?? r['total_matches']);
            final wins = _toInt(r['win_count'] ?? r['wins']);
            final losses = total >= wins ? total - wins : 0;
            final winRate = _toDouble(r['win_rate'], (total > 0 ? (wins / total) * 100.0 : 0.0));

            list.add(MatchupStat(
              characterId: oppChar.id,
              totalMatches: total,
              wins: wins,
              losses: losses,
              winRate: winRate,
            ));
          }
        }
        if (list.isNotEmpty) {
          result[myChar] = list;
        }
      }
    } catch (e) {
      print('Error parsing official rival matchups: $e');
    }
    return result;
  }
}
