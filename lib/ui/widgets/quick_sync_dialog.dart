import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/network/next_data_parser.dart';
import 'package:sf6_tracker/core/storage/database_helper.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/club_model.dart';
import 'package:sf6_tracker/models/user_profile.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';
import 'package:sf6_tracker/ui/screens/auth/login_webview_screen.dart';

class QuickSyncDialog extends StatefulWidget {
  final AuthService authService;
  final BattleLogService battleLogService;
  final StatsService statsService;
  final SocialService socialService;

  const QuickSyncDialog({
    super.key,
    required this.authService,
    required this.battleLogService,
    required this.statsService,
    required this.socialService,
  });

  static Future<void> show(
    BuildContext context, {
    required AuthService authService,
    required BattleLogService battleLogService,
    required StatsService statsService,
    required SocialService socialService,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => QuickSyncDialog(
        authService: authService,
        battleLogService: battleLogService,
        statsService: statsService,
        socialService: socialService,
      ),
    );
  }

  @override
  State<QuickSyncDialog> createState() => _QuickSyncDialogState();
}

class _QuickSyncDialogState extends State<QuickSyncDialog> {
  String _status = '正在准备官方高速同步...';
  double _progress = 0.1;
  bool _isDone = false;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDirectHttpSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            _isDone ? Icons.check_circle : (_isError ? Icons.error_outline : Icons.sync),
            color: _isDone ? AppColors.winGreen : (_isError ? AppColors.loseRed : AppColors.accentNeonCyan),
          ),
          const SizedBox(width: 8),
          Text(
            _isDone ? '同步完成' : (_isError ? '需要重新登录' : '一键官方数据同步'),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.bgSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isDone ? AppColors.winGreen : (_isError ? AppColors.loseRed : AppColors.accentNeonCyan),
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _status,
              style: TextStyle(
                color: _isError ? AppColors.loseRed : AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (_isError) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_isError) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginWebViewScreen(authService: widget.authService),
                ),
              );
            },
            child: const Text('前往网页登录授权', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ] else if (_isDone) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.winGreen),
            onPressed: () => Navigator.pop(context),
            child: const Text('完成', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }

  Future<void> _startDirectHttpSync() async {
    try {
      final activePlat = widget.authService.activePlatform;
      String shortId = activePlat?.shortId ?? '';

      setState(() {
        _status = '正在获取官方登录会话与 Cookie...';
        _progress = 0.2;
      });

      final cookieManager = CookieManager.instance();
      final cookies = await cookieManager.getCookies(url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/'));
      String cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');

      if (cookieHeader.isEmpty && widget.authService.activeAccount?.cookieSession.isNotEmpty == true) {
        cookieHeader = widget.authService.activeAccount!.cookieSession;
      }

      if (cookieHeader.isEmpty) {
        setState(() {
          _isError = true;
          _status = '未检测到有效的官方登录会话，请先登录一次。';
          _errorMessage = '点击下方按钮前往官方网页登录。';
        });
        return;
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
        setState(() {
          _isError = true;
          _status = '未检测到已绑定的 Short ID，请先在登录页面完成同步或手动绑定。';
          _errorMessage = '点击下方按钮前往官方网页登录并同步。';
        });
        return;
      }

      final profileUrl = 'https://www.streetfighter.com/6/buckler/zh-hans/profile/$shortId';

      setState(() {
        _status = '正在拉取官方个人主页档案...';
        _progress = 0.35;
      });

      final profileRes = await dio.get(profileUrl);
      final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(profileRes.data.toString());

      if (m == null) {
        setState(() {
          _isError = true;
          _status = '官方登录会话已过期，请重新登录。';
          _errorMessage = '未能从官方服务器读取到有效数据。';
        });
        return;
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
      final circleId = (circleInfo['circle_id'] ?? '').toString();

      setState(() {
        _status = '正在并发拉取历史对局、全角色积分、好友与战队...';
        _progress = 0.55;
      });

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
        
        // 1. Parse character league points & ratings
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

        // 2. Merge character win rates / battle count
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
        AppLogger.instance.warn('SyncEngine', '快速同步 /play 异常: $e');
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
        AppLogger.instance.warn('SyncEngine', '快速同步 /friend 异常: $e');
      });

      // 3. Fetch /profile/$shortId/club and /club/$cid
      final clubFuture = dio.get('https://www.streetfighter.com/6/buckler/zh-hans/profile/$shortId/club').then((res) async {
        final cm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(res.data.toString());
        if (cm != null) {
          final cData = jsonDecode(cm.group(1)!);
          var cClubs = NextDataParser.parseClubsList(cData);
          if (cClubs.isNotEmpty) {
            final cid = cClubs.first.clubId;
            AppLogger.instance.info('SyncEngine', '检测到所属战队 ID: $cid (${cClubs.first.clubName})');
            if (cid.isNotEmpty && !cid.startsWith('club_')) {
              try {
                final detailRes = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/club/$cid');
                final dm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(detailRes.data.toString());
                if (dm != null) {
                  final dData = jsonDecode(dm.group(1)!);
                  final singleClub = NextDataParser.parseClub(dData);
                  if (singleClub != null && singleClub.members.isNotEmpty) {
                    AppLogger.instance.info('SyncEngine', '成功获取战队 ${singleClub.clubName} 成员 ${singleClub.members.length} 人 (在线 ${singleClub.members.where((m) => m.isOnline).length} 人)');
                    cClubs = [singleClub];
                  }
                }
              } catch (e) {
                AppLogger.instance.warn('SyncEngine', '拉取战队详情 /club/$cid 异常: $e');
              }
            }
            rawClubMembers = cClubs.map((c) => c.toJson()).toList();
          }
        }
      }).catchError((e) {
        AppLogger.instance.warn('SyncEngine', '快速同步战队 /profile/$shortId/club 异常: $e');
      });

      // 4. Fetch 10 pages of battlelog (up to 100 replays)
      final battlelogFutures = List.generate(10, (idx) {
        final p = idx + 1;
        final url = 'https://www.streetfighter.com/6/buckler/zh-hans/profile/$shortId/battlelog${p > 1 ? '?page=$p' : ''}';
        return dio.get(url).then((res) {
          final bm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(res.data.toString());
          if (bm != null) {
            final bData = jsonDecode(bm.group(1)!);
            final bProps = bData['props']?['pageProps'];
            final rList = bProps?['replay_list'] ?? bProps?['battle_list'] ?? bProps?['battlelog'] ?? bProps?['replays'] ?? bProps?['play']?['replay_list'];
            if (rList is List) {
              for (final item in rList) {
                final rId = item['replay_id'] ?? item['id'] ?? '${item['uploaded_at']}_${item['player1_info']?['short_id']}';
                final exists = rawReplays.any((ex) {
                  final exId = ex['replay_id'] ?? ex['id'] ?? '${ex['uploaded_at']}_${ex['player1_info']?['short_id']}';
                  return exId == rId;
                });
                if (!exists) {
                  rawReplays.add(item);
                }
              }
            }
          }
        }).catchError((e) {
          AppLogger.instance.warn('SyncEngine', '快速同步 battlelog 第 $p 页异常: $e');
        });
      });

      await Future.wait([playFuture, friendFuture, clubFuture, ...battlelogFutures]);

      setState(() {
        _status = '正在写入 SQLite 本地数据库并刷新所有页面...';
        _progress = 0.85;
      });

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

      // 3. Keep current main character or resolve from character usages
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
      await widget.authService.updateActiveProfile(
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
      await widget.battleLogService.loadRecords(
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

      await widget.statsService.loadStats(
        shortId: shortId,
        platform: activePlat?.platformType.code ?? 'switch2',
      );

      await widget.socialService.loadSocialData(
        shortId: shortId,
        clubName: circleName,
      );

      setState(() {
        _isDone = true;
        _progress = 1.0;
        _status = '🎉 同步成功！已更新 ${rawReplays.length} 局对战、全角色积分、${rawFriends.length} 位好友与战队成员。';
      });

      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 已成功一键高速同步官方最新战绩 (更新 ${rawReplays.length} 局对战)'),
            backgroundColor: AppColors.winGreen,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _status = '同步异常: $e';
        _errorMessage = '请检查网络或重新登录一次。';
      });
    }
  }
}
