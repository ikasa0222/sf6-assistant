import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/network/next_data_parser.dart';
import 'package:sf6_tracker/core/storage/database_helper.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/models/club_model.dart';
import 'package:sf6_tracker/models/user_profile.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';

class SyncResult {
  final bool success;
  final bool needLogin;
  final String message;
  final int recordsUpdated;
  final int friendsUpdated;
  final int clubsUpdated;

  const SyncResult({
    required this.success,
    this.needLogin = false,
    required this.message,
    this.recordsUpdated = 0,
    this.friendsUpdated = 0,
    this.clubsUpdated = 0,
  });
}

class CapcomSyncEngine {
  static bool _isSyncing = false;
  static bool get isSyncing => _isSyncing;

  static Future<SyncResult> performFullSync({
    required AuthService authService,
    required BattleLogService battleLogService,
    StatsService? statsService,
    SocialService? socialService,
    void Function(double progress, String status)? onProgress,
  }) async {
    if (_isSyncing) {
      return const SyncResult(
        success: false,
        message: '正在自动更新数据中，请稍候...',
      );
    }

    _isSyncing = true;
    battleLogService.setSyncing(true);

    try {
      final activePlat = authService.activePlatform;
      String shortId = activePlat?.shortId ?? '';

      onProgress?.call(0.15, '正在获取官方登录会话与 Cookie...');

      final cookieManager = CookieManager.instance();
      final cookies = await cookieManager.getCookies(url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/'));
      String cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');

      if (cookieHeader.isEmpty && authService.activeAccount?.cookieSession.isNotEmpty == true) {
        cookieHeader = authService.activeAccount!.cookieSession;
      }

      if (cookieHeader.isEmpty) {
        return const SyncResult(
          success: false,
          needLogin: true,
          message: '未检测到有效的官方登录会话，请先登录授权。',
        );
      }

      final dio = Dio(BaseOptions(
        headers: {
          'Cookie': cookieHeader,
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36',
          'Referer': 'https://www.streetfighter.com/6/buckler/zh-hans/',
          'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

      // Auto-discover Short ID if not set
      if (shortId.isEmpty) {
        try {
          final discRes = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/fighterslist/friend');
          final fm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(discRes.data.toString());
          if (fm != null) {
            final fData = jsonDecode(fm.group(1)!);
            final fProps = fData['props']?['pageProps'] as Map<String, dynamic>? ?? {};
            final bInfo = fProps['fighter_banner_info'] as Map<String, dynamic>? ?? {};
            final pInfo = bInfo['personal_info'] as Map<String, dynamic>? ?? {};
            shortId = (pInfo['short_id'] ?? bInfo['short_id'] ?? '').toString();
          }
        } catch (_) {}
      }

      if (shortId.isEmpty) {
        return const SyncResult(
          success: false,
          needLogin: true,
          message: '未检测到已绑定的 Short ID，请先在登录页面完成同步。',
        );
      }

      final profileUrl = 'https://www.streetfighter.com/6/buckler/zh-hans/profile/$shortId';
      onProgress?.call(0.3, '正在拉取官方个人主页档案...');

      final profileRes = await dio.get(profileUrl);
      final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(profileRes.data.toString());

      if (m == null) {
        return const SyncResult(
          success: false,
          needLogin: true,
          message: '官方登录会话已过期，请重新登录。',
        );
      }

      final nextData = jsonDecode(m.group(1)!);
      final pageProps = nextData['props']?['pageProps'] as Map<String, dynamic>? ?? {};
      final bannerInfo = pageProps['fighter_banner_info'] as Map<String, dynamic>? ?? {};
      final personalInfo = bannerInfo['personal_info'] as Map<String, dynamic>? ?? {};
      final leagueInfo = bannerInfo['favorite_character_league_info'] as Map<String, dynamic>? ?? {};
      final circleInfo = bannerInfo['main_circle'] as Map<String, dynamic>? ?? {};

      final fighterName = (personalInfo['fighter_id'] ?? bannerInfo['fighter_id'] ?? activePlat?.fighterId ?? '玩家_$shortId').toString();
      final rawBannerLp = leagueInfo['league_point'] ?? activePlat?.currentLp ?? 0;
      final rawBannerMr = leagueInfo['master_rating'] ?? activePlat?.currentMr ?? 0;
      final lp = rawBannerLp is num ? rawBannerLp.toInt() : (int.tryParse(rawBannerLp.toString()) ?? 0);
      final mr = rawBannerMr is num ? rawBannerMr.toInt() : (int.tryParse(rawBannerMr.toString()) ?? 0);
      final circleName = (circleInfo['circle_name'] ?? activePlat?.clubName ?? '').toString();

      onProgress?.call(0.45, '正在并发拉取历史对局、全角色积分、好友与战队...');

      List<dynamic> rawReplays = [];
      List<dynamic> rawFriends = [];
      List<dynamic> rawClubMembers = [];
      List<CharacterUsage> characterUsages = [];

      // 1. Fetch /play
      final playFuture = dio.get('https://www.streetfighter.com/6/buckler/zh-hans/profile/$shortId/play').then((res) {
        final pm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(res.data.toString());
        if (pm == null) return;
        final playData = jsonDecode(pm.group(1)!);
        final playObj = playData['props']?['pageProps']?['play'] ?? playData['props']?['pageProps'];

        final Map<String, CharacterUsage> usageMap = {};

        final cList = playObj?['character_league_infos'] ?? playObj?['character_league_list'] ?? [];
        if (cList is List) {
          for (final c in cList) {
            if (c is! Map) continue;
            final rawCid = c['character_id'] ?? c['character_tool_name'] ?? c['character_name'];
            final cChar = Sf6Characters.fromCapcomId(rawCid);
            final rawLpNum = c['league_info']?['league_point'] ?? c['league_point'] ?? c['lp'] ?? 0;
            final rawMrNum = c['league_info']?['master_rating'] ?? c['master_rating'] ?? c['mr'] ?? 0;
            final rawLp = rawLpNum is num ? rawLpNum.toInt() : (int.tryParse(rawLpNum.toString()) ?? 0);
            final rawMr = rawMrNum is num ? rawMrNum.toInt() : (int.tryParse(rawMrNum.toString()) ?? 0);

            if (rawLp <= 0 && rawMr <= 0) continue;

            final validLp = rawLp > 0 ? rawLp : 0;
            final validMr = rawMr > 0 ? rawMr : 0;
            final rawMatches = c['play_count'] ?? c['total_matches'] ?? c['playing_count'] ?? c['matches'] ?? c['battle_count'] ?? 0;
            final matches = rawMatches is num ? rawMatches.toInt() : (int.tryParse(rawMatches.toString()) ?? 0);
            final rawWins = c['win_count'] ?? c['wins'] ?? 0;
            final wins = rawWins is num ? rawWins.toInt() : (int.tryParse(rawWins.toString()) ?? 0);
            final rawWr = c['win_rate'];
            final winRate = rawWr is num ? rawWr.toDouble() : (double.tryParse(rawWr?.toString() ?? '') ?? (matches > 0 ? (wins / matches) * 100.0 : 0.0));

            usageMap[cChar.id] = CharacterUsage(
              characterId: cChar.id,
              matches: matches,
              wins: wins,
              winRate: winRate,
              lp: validLp,
              mr: validMr,
            );
          }
        }

        final winList = playObj?['character_win_rates'] ?? playObj?['character_win_rate_list'] ?? playObj?['character_list'] ?? playObj?['character_play_stats'] ?? [];
        if (winList is List) {
          for (final c in winList) {
            if (c is! Map) continue;
            final rawCid = c['character_id'] ?? c['character_tool_name'] ?? c['character_name'];
            final cChar = Sf6Characters.fromCapcomId(rawCid);
            final rawMatches = c['play_count'] ?? c['total_matches'] ?? c['playing_count'] ?? c['matches'] ?? c['battle_count'] ?? 0;
            final matches = rawMatches is num ? rawMatches.toInt() : (int.tryParse(rawMatches.toString()) ?? 0);
            final rawWins = c['win_count'] ?? c['wins'] ?? 0;
            final wins = rawWins is num ? rawWins.toInt() : (int.tryParse(rawWins.toString()) ?? 0);
            final rawWr = c['win_rate'];
            final winRate = rawWr is num ? rawWr.toDouble() : (double.tryParse(rawWr?.toString() ?? '') ?? (matches > 0 ? (wins / matches) * 100.0 : 0.0));

            if (usageMap.containsKey(cChar.id)) {
              final cur = usageMap[cChar.id]!;
              usageMap[cChar.id] = CharacterUsage(
                characterId: cur.characterId,
                matches: matches > 0 ? matches : cur.matches,
                wins: wins > 0 ? wins : cur.wins,
                winRate: winRate > 0 ? winRate : cur.winRate,
                lp: cur.lp,
                mr: cur.mr,
              );
            }
          }
        }

        characterUsages = usageMap.values.toList();
        characterUsages.sort((a, b) {
          if (b.mr != a.mr) return b.mr.compareTo(a.mr);
          if (b.lp != a.lp) return b.lp.compareTo(a.lp);
          return b.matches.compareTo(a.matches);
        });
      }).catchError((e) {
        AppLogger.instance.warn('SyncEngine', '同步 /play 异常: $e');
      });

      // 2. Fetch /friend
      final friendFuture = dio.get('https://www.streetfighter.com/6/buckler/zh-hans/fighterslist/friend').then((res) {
        final fm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(res.data.toString());
        if (fm != null) {
          final fData = jsonDecode(fm.group(1)!);
          final fFriends = NextDataParser.parseFriends(fData);
          if (fFriends.isNotEmpty) {
            rawFriends = fFriends.map((f) => f.toJson()).toList();
          }
        }
      }).catchError((e) {
        AppLogger.instance.warn('SyncEngine', '同步 /friend 异常: $e');
      });

      // 3. Fetch clubs
      final clubFuture = Future(() async {
        List<ClubModel> parsedClubs = [];

        try {
          final listRes = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/club/list');
          final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(listRes.data.toString());
          if (m != null) {
            final cData = jsonDecode(m.group(1)!);
            parsedClubs = NextDataParser.parseClubsList(cData);
          }
        } catch (_) {}

        if (parsedClubs.isEmpty) {
          try {
            final profRes = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/profile/$shortId/club');
            final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(profRes.data.toString());
            if (m != null) {
              final cData = jsonDecode(m.group(1)!);
              parsedClubs = NextDataParser.parseClubsList(cData);
            }
          } catch (_) {}
        }

        if (parsedClubs.isEmpty && circleName.isNotEmpty) {
          parsedClubs.add(ClubModel(
            clubId: circleInfo['circle_id']?.toString() ?? 'club_${circleName.hashCode.abs()}',
            clubName: circleName,
            tag: circleInfo['circle_tag']?.toString() ?? (circleName.length > 4 ? circleName.substring(0, 4).toUpperCase() : circleName.toUpperCase()),
            isMainClub: true,
            memberCount: 0,
            members: [],
          ));
        }

        final detailedClubs = <ClubModel>[];
        final realMainClubId = parsedClubs.any((c) => c.isMainClub)
            ? parsedClubs.firstWhere((c) => c.isMainClub).clubId
            : (parsedClubs.isNotEmpty ? parsedClubs.first.clubId : '');

        for (int i = 0; i < parsedClubs.length; i++) {
          final cur = parsedClubs[i];
          final bool isThisMain = cur.clubId == realMainClubId || (realMainClubId.isEmpty && i == 0);

          if (cur.clubId.isNotEmpty && !cur.clubId.startsWith('club_')) {
            try {
              final detailRes = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/club/${cur.clubId}');
              final dm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(detailRes.data.toString());
              if (dm != null) {
                final dData = jsonDecode(dm.group(1)!);
                final detailed = NextDataParser.parseClub(dData);
                if (detailed != null) {
                  detailedClubs.add(cur.copyWith(
                    clubName: detailed.clubName.isNotEmpty ? detailed.clubName : cur.clubName,
                    tag: detailed.tag.isNotEmpty ? detailed.tag : cur.tag,
                    emblemUrl: detailed.emblemUrl.isNotEmpty ? detailed.emblemUrl : cur.emblemUrl,
                    notice: detailed.notice.isNotEmpty ? detailed.notice : cur.notice,
                    memberCount: detailed.memberCount > 0 ? detailed.memberCount : cur.memberCount,
                    maxMemberCount: detailed.maxMemberCount,
                    totalMonthlyPoints: detailed.totalMonthlyPoints > 0 ? detailed.totalMonthlyPoints : cur.totalMonthlyPoints,
                    isMainClub: isThisMain,
                    onlineMemberCount: detailed.onlineMemberCount > 0 ? detailed.onlineMemberCount : cur.onlineMemberCount,
                    leaderFighterId: detailed.leaderFighterId.isNotEmpty ? detailed.leaderFighterId : cur.leaderFighterId,
                    leaderShortId: detailed.leaderShortId.isNotEmpty ? detailed.leaderShortId : cur.leaderShortId,
                    leaderPlatform: detailed.leaderPlatform.isNotEmpty ? detailed.leaderPlatform : cur.leaderPlatform,
                    tags: detailed.tags.isNotEmpty ? detailed.tags : cur.tags,
                    members: detailed.members.isNotEmpty ? detailed.members : cur.members,
                  ));
                  continue;
                }
              }
            } catch (_) {}
          }
          detailedClubs.add(cur.copyWith(isMainClub: isThisMain));
        }

        rawClubMembers = detailedClubs.map((c) => c.toJson()).toList();
      }).catchError((e) {
        AppLogger.instance.warn('SyncEngine', '同步战队模块异常: $e');
      });

      // 4. Fetch 10 pages of battlelog (up to 100 replays)
      final battlelogFutures = List.generate(10, (idx) {
        final p = idx + 1;
        final url = 'https://www.streetfighter.com/6/buckler/zh-hans/profile/$shortId/battlelog${p > 1 ? "?page=$p" : ""}';
        return dio.get(url).then((res) {
          final bm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(res.data.toString());
          if (bm != null) {
            final bData = jsonDecode(bm.group(1)!);
            final bProps = bData['props']?['pageProps'];
            final rList = bProps?['replay_list'] ?? bProps?['battle_list'] ?? bProps?['battlelog'] ?? bProps?['replays'] ?? bProps?['play']?['replay_list'];
            if (rList is List) {
              for (final item in rList) {
                final rId = item['replay_id'] ?? item['id'] ?? '${item["uploaded_at"]}_${item["player1_info"]?["short_id"]}';
                final exists = rawReplays.any((ex) {
                  final exId = ex['replay_id'] ?? ex['id'] ?? '${ex["uploaded_at"]}_${ex["player1_info"]?["short_id"]}';
                  return exId == rId;
                });
                if (!exists) {
                  rawReplays.add(item);
                }
              }
            }
          }
        }).catchError((e) {
          AppLogger.instance.warn('SyncEngine', '同步 battlelog 第 $p 页异常: $e');
        });
      });

      await Future.wait([playFuture, friendFuture, clubFuture, ...battlelogFutures]);

      onProgress?.call(0.85, '正在写入 SQLite 本地数据库并刷新所有页面...');

      // 1. Save replays to SQLite
      if (rawReplays.isNotEmpty) {
        final records = NextDataParser.parseBattleLog(
          {'props': {'pageProps': {'replay_list': rawReplays}}},
          userShortId: shortId,
          platform: activePlat?.platformType.code ?? 'switch2',
        );
        if (records.isNotEmpty) {
          await DatabaseHelper.instance.deleteBattleRecordsByShortId(shortId);
          await DatabaseHelper.instance.batchInsertBattleRecords(records);
        }
      }

      // 2. Save social data
      if (rawFriends.isNotEmpty || rawClubMembers.isNotEmpty) {
        await StorageService.instance.saveSocialData(
          shortId,
          friends: rawFriends.map((f) => f is Map ? Map<String, dynamic>.from(f) : <String, dynamic>{}).toList(),
          clubs: rawClubMembers.map((c) => c is Map ? Map<String, dynamic>.from(c) : <String, dynamic>{}).toList(),
        );
      }

      // 3. Resolve main character
      String mainChar = activePlat?.mainCharId.isNotEmpty == true ? activePlat!.mainCharId : 'luke';
      if (characterUsages.isNotEmpty) {
        final sorted = List<CharacterUsage>.from(characterUsages)..sort((a, b) => b.matches.compareTo(a.matches));
        mainChar = sorted.first.characterId;
      }

      int finalDirectLp = lp;
      int finalDirectMr = mr;
      if (finalDirectLp <= 0 && finalDirectMr <= 0 && characterUsages.isNotEmpty) {
        CharacterUsage? mainU;
        for (final u in characterUsages) {
          if (u.characterId.toLowerCase() == mainChar.toLowerCase()) {
            mainU = u;
            break;
          }
        }
        mainU ??= characterUsages.first;
        finalDirectLp = mainU.lp;
        finalDirectMr = mainU.mr;
      }

      // 4. Update AuthService
      await authService.updateActiveProfile(
        fighterId: fighterName,
        shortId: shortId,
        platformType: activePlat?.platformType ?? PlatformType.nintendoSwitch2,
        lp: finalDirectLp,
        mr: finalDirectMr,
        mainCharId: mainChar,
        clubName: circleName,
        characterUsages: characterUsages,
      );

      // 5. Refresh Services
      await battleLogService.loadRecords(
        shortId: shortId,
        platform: activePlat?.platformType.code ?? 'switch2',
        fighterId: fighterName,
        lp: finalDirectLp,
        mr: finalDirectMr,
        mainCharId: mainChar,
        clubName: circleName,
        characterUsages: characterUsages,
        forceSync: true,
      );

      if (statsService != null) {
        await statsService.loadStats(
          shortId: shortId,
          platform: activePlat?.platformType.code ?? 'switch2',
        );
      }

      if (socialService != null) {
        await socialService.loadSocialData(
          shortId: shortId,
          clubName: circleName,
        );
      }

      AppLogger.instance.sync(
        'CapcomSyncEngine',
        '全量数据同步完成: 对局 ${rawReplays.length} 局, 角色 ${characterUsages.length} 个, 好友 ${rawFriends.length} 个, 战队 ${rawClubMembers.length} 个',
      );

      onProgress?.call(1.0, '同步成功！已更新 ${rawReplays.length} 局对战、全角色积分、${rawFriends.length} 位好友与战队。');

      return SyncResult(
        success: true,
        message: '已成功同步官方最新战绩 (更新 ${rawReplays.length} 局对战)',
        recordsUpdated: rawReplays.length,
        friendsUpdated: rawFriends.length,
        clubsUpdated: rawClubMembers.length,
      );
    } catch (e, stack) {
      AppLogger.instance.error('CapcomSyncEngine', '同步异常: $e\n$stack');
      return SyncResult(
        success: false,
        message: '同步异常: $e',
      );
    } finally {
      _isSyncing = false;
      battleLogService.setSyncing(false);
    }
  }
}
