import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:sf6_tracker/models/matchup_stat.dart';
import 'package:sf6_tracker/models/user_profile.dart';
import 'package:sf6_tracker/services/auth_service.dart';

class LoginWebViewScreen extends StatefulWidget {
  final AuthService authService;

  const LoginWebViewScreen({
    super.key,
    required this.authService,
  });

  @override
  State<LoginWebViewScreen> createState() => _LoginWebViewScreenState();
}

class _LoginWebViewScreenState extends State<LoginWebViewScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  bool _isSyncing = false;
  String _syncStatus = '正在同步数据...';

  int _safeInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  double _safeDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _webViewController?.canGoBack() ?? false) {
                await _webViewController?.goBack();
              } else {
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
          title: const Text('Capcom ID 官方授权登录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, color: AppColors.accentNeonCyan),
              tooltip: '直达当前登录者个人主页',
              onPressed: () async {
                final knownSid = widget.authService.activePlatform?.shortId ?? '';
                if (knownSid.isNotEmpty) {
                  await _webViewController?.loadUrl(
                    urlRequest: URLRequest(url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/profile/$knownSid')),
                  );
                  return;
                }
                String sid = '';
                final found = await _webViewController?.evaluateJavascript(source: '''
                  (function() {
                    var links = document.querySelectorAll('a[href*="/profile/"]');
                    for (var i = 0; i < links.length; i++) {
                      var m = (links[i].getAttribute('href') || '').match(/\\/profile\\/(\\d+)/);
                      if (m && m[1]) return m[1];
                    }
                    if (window.__NEXT_DATA__ && window.__NEXT_DATA__.props && window.__NEXT_DATA__.props.pageProps) {
                      var p = window.__NEXT_DATA__.props.pageProps;
                      if (p.sid) return String(p.sid);
                      if (p.fighter_banner_info && p.fighter_banner_info.personal_info && p.fighter_banner_info.personal_info.short_id) {
                        return String(p.fighter_banner_info.personal_info.short_id);
                      }
                    }
                    return '';
                  })()
                ''');
                if (found != null && found.toString().isNotEmpty && found.toString() != '""') {
                  sid = found.toString().replaceAll('"', '').trim();
                }
                if (sid.isEmpty) {
                  try {
                    final cookieManager = CookieManager.instance();
                    final cookies = await cookieManager.getCookies(url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/'));
                    final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');
                    if (cookieHeader.isNotEmpty) {
                      final dio = Dio();
                      final discRes = await dio.get(
                        'https://www.streetfighter.com/6/buckler/zh-hans/fighterslist/friend',
                        options: Options(headers: {'Cookie': cookieHeader}),
                      );
                      final fm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(discRes.data.toString());
                      if (fm != null) {
                        final fData = jsonDecode(fm.group(1)!);
                        final p = fData['props']?['pageProps'];
                        sid = (p?['fighter_banner_info']?['personal_info']?['short_id'] ?? '').toString();
                      }
                    }
                  } catch (_) {}
                }
                if (sid.isNotEmpty) {
                  await _webViewController?.loadUrl(
                    urlRequest: URLRequest(url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/profile/$sid')),
                  );
                } else {
                  await _webViewController?.loadUrl(
                    urlRequest: URLRequest(url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/')),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.cleaning_services, color: AppColors.loseRed),
              tooltip: '清除登录缓存 / 切换其他账号',
              onPressed: () async {
                try {
                  final cookieManager = CookieManager.instance();
                  await cookieManager.deleteAllCookies();
                  await InAppWebViewController.clearAllCache();
                  await _webViewController?.loadUrl(
                    urlRequest: URLRequest(url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/')),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已清除登录凭据与缓存，请在网页中登录新账号')),
                    );
                  }
                } catch (e) {
                  AppLogger.instance.warn('WebView', '清除缓存异常: $e');
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.bug_report, color: AppColors.accentNeonYellow),
              tooltip: '查看嗅探与抓包诊断日志',
              onPressed: _showDiagnosticModal,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '刷新页面',
              onPressed: () async {
                try {
                  final currentUrl = await _webViewController?.getUrl();
                  if (currentUrl != null) {
                    await _webViewController?.loadUrl(urlRequest: URLRequest(url: currentUrl));
                  } else {
                    await _webViewController?.reload();
                  }
                } catch (_) {
                  await _webViewController?.reload();
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                if (_progress < 1.0)
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentNeonCyan),
                    minHeight: 3,
                  ),
                Expanded(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/'),
                    ),
                    initialSettings: InAppWebViewSettings(
                      useHybridComposition: true,
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      cacheEnabled: true,
                      thirdPartyCookiesEnabled: true,
                      supportMultipleWindows: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      transparentBackground: false,
                      useWideViewPort: true,
                      loadWithOverviewMode: true,
                      userAgent: 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36',
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      AppLogger.instance.info('WebView', 'WebView 控制器初始化完成');
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() => _progress = progress / 100.0);
                    },
                  ),
                ),
                _buildBottomSyncBar(),
              ],
            ),
            if (_isSyncing)
              Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentNeonCyan),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.accentNeonCyan),
                        const SizedBox(height: 18),
                        Text(
                          _syncStatus,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSyncBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: const Border(top: BorderSide(color: AppColors.borderSubtle, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentNeonCyan,
                  foregroundColor: Colors.black,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.cloud_sync, size: 22, color: Colors.black),
                label: const Text(
                  '已完成登录，立即一键同步战绩',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                onPressed: () {
                  if (_webViewController != null) {
                    _performFullSync(_webViewController!);
                  }
                },
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.bug_report, size: 14, color: AppColors.accentNeonYellow),
                  label: const Text('嗅探日志/抓包诊断', style: TextStyle(color: AppColors.accentNeonYellow, fontSize: 11)),
                  onPressed: _showDiagnosticModal,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit_note, size: 14, color: AppColors.textTertiary),
                  label: const Text('手动绑定 Short ID', style: TextStyle(color: AppColors.textTertiary, fontSize: 11, decoration: TextDecoration.underline)),
                  onPressed: () => _showManualInputDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performFullSync(InAppWebViewController controller) async {
    setState(() {
      _isSyncing = true;
      _syncStatus = '正在检测页面状态...';
    });

    try {
      final currentUrl = (await controller.getUrl())?.toString() ?? '';
      AppLogger.instance.sync('SyncEngine', '触发一键同步，当前 URL: $currentUrl');

      // 1. Intercept if on Capcom ID login or Cloudflare challenge
      if (currentUrl.contains('auth.cid.capcom.com') ||
          currentUrl.contains('authorize') ||
          currentUrl.contains('turnstile') ||
          currentUrl.contains('challenge')) {
        setState(() => _isSyncing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.loseRed,
              content: Text('检测到尚未完成卡普空账号登录或正在进行人机安全验证，请在上方网页勾选验证并成功登录后再点击同步！'),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // 2. Multi-stage intelligent Short ID discovery (ZERO manual navigation needed)
      setState(() => _syncStatus = '正在智能识别当前登录账号 Short ID...');

      String finalSid = '';
      final pageUrl = (await controller.getUrl())?.toString() ?? '';
      final urlMatch = RegExp(r'/profile/(\d+)').firstMatch(pageUrl);
      if (urlMatch != null) {
        finalSid = urlMatch.group(1)!;
      }

      // Stage A: Query DOM synchronous links / __NEXT_DATA__
      if (finalSid.isEmpty) {
        try {
          final probeSid = await controller.evaluateJavascript(source: '''
            (function() {
              var links = document.querySelectorAll('a[href*="/profile/"]');
              for (var i = 0; i < links.length; i++) {
                var m = (links[i].getAttribute('href') || '').match(/\\/profile\\/(\\d+)/);
                if (m && m[1]) return m[1];
              }
              if (window.__NEXT_DATA__ && window.__NEXT_DATA__.props && window.__NEXT_DATA__.props.pageProps) {
                var p = window.__NEXT_DATA__.props.pageProps;
                if (p.sid) return String(p.sid);
                if (p.fighter_banner_info && p.fighter_banner_info.personal_info && p.fighter_banner_info.personal_info.short_id) {
                  return String(p.fighter_banner_info.personal_info.short_id);
                }
              }
              return '';
            })()
          ''');
          if (probeSid != null && probeSid.toString().isNotEmpty && probeSid.toString() != '""') {
            final sid = probeSid.toString().replaceAll('"', '').trim();
            if (RegExp(r'^\d+$').hasMatch(sid)) {
              finalSid = sid;
            }
          }
        } catch (_) {}
      }

      // Stage B: Read WebView session cookies and fetch /fighterslist/friend via Dio
      final cookieManager = CookieManager.instance();
      final cookies = await cookieManager.getCookies(url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/'));
      final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');

      if (finalSid.isEmpty && cookieHeader.isNotEmpty) {
        try {
          final dio = Dio(BaseOptions(
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
            headers: {
              'Cookie': cookieHeader,
              'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
            },
          ));
          final discRes = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/fighterslist/friend');
          final fm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(discRes.data.toString());
          if (fm != null) {
            final fData = jsonDecode(fm.group(1)!);
            final fProps = fData['props']?['pageProps'] as Map<String, dynamic>? ?? {};
            final bInfo = fProps['fighter_banner_info'] as Map<String, dynamic>? ?? {};
            final pInfo = bInfo['personal_info'] as Map<String, dynamic>? ?? {};
            final discovered = (pInfo['short_id'] ?? bInfo['short_id'] ?? '').toString().trim();
            if (discovered.isNotEmpty && RegExp(r'^\d+$').hasMatch(discovered)) {
              finalSid = discovered;
              AppLogger.instance.sync('SyncEngine', '通过官方探针成功识别当前 Short ID: $finalSid');
            }
          }
        } catch (e) {
          AppLogger.instance.warn('SyncEngine', '官方探针定位异常: $e');
        }
      }

      // Stage C: Fallback to active platform shortId
      if (finalSid.isEmpty) {
        finalSid = widget.authService.activePlatform?.shortId ?? '';
      }

      if (finalSid.isEmpty) {
        setState(() => _isSyncing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('未能检测到当前登录账号的 Short ID，请确认卡普空官网已成功登录！'),
              backgroundColor: AppColors.loseRed,
            ),
          );
        }
        return;
      }

      // 3. Extract profile pageProps: directly via fast Dio GET or current WebView
      setState(() => _syncStatus = '正在提取个人档案与全量战绩...');
      Map<String, dynamic> pageProps = {};

      if (cookieHeader.isNotEmpty) {
        try {
          final dio = Dio(BaseOptions(
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
            headers: {
              'Cookie': cookieHeader,
              'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
            },
          ));
          final pRes = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/profile/$finalSid');
          final pm = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(pRes.data.toString());
          if (pm != null) {
            final pData = jsonDecode(pm.group(1)!);
            pageProps = Map<String, dynamic>.from(pData['props']?['pageProps'] ?? {});
            AppLogger.instance.sync('SyncEngine', '成功直接提取 profile 档案 pageProps 数据');
          }
        } catch (e) {
          AppLogger.instance.warn('SyncEngine', '直接拉取 profile 档案异常: $e');
        }
      }

      // If Dio extraction didn't populate pageProps, try evaluating DOM in WebView
      if (pageProps.isEmpty || pageProps['fighter_banner_info'] == null) {
        final nextDataResult = await controller.evaluateJavascript(source: '''
          (function() {
            try {
              if (window.__NEXT_DATA__ && window.__NEXT_DATA__.props && window.__NEXT_DATA__.props.pageProps) {
                return JSON.stringify(window.__NEXT_DATA__.props.pageProps);
              }
              var el = document.getElementById('__NEXT_DATA__');
              if (el && el.innerText) {
                var parsed = JSON.parse(el.innerText);
                if (parsed && parsed.props && parsed.props.pageProps) {
                  return JSON.stringify(parsed.props.pageProps);
                }
              }
            } catch(e) {}
            return "";
          })()
        ''');
        if (nextDataResult != null && nextDataResult.toString().isNotEmpty && nextDataResult.toString() != '""') {
          dynamic decoded = nextDataResult;
          if (decoded is String) {
            try { decoded = jsonDecode(decoded); } catch (_) {}
          }
          if (decoded is String) {
            try { decoded = jsonDecode(decoded); } catch (_) {}
          }
          if (decoded is Map) {
            pageProps = Map<String, dynamic>.from(decoded);
          }
        }
      }

      // Also ensure WebView navigates to the profile page for visual feedback
      final targetProfileUrl = 'https://www.streetfighter.com/6/buckler/zh-hans/profile/$finalSid';
      if (!pageUrl.contains('/profile/$finalSid')) {
        controller.loadUrl(urlRequest: URLRequest(url: WebUri(targetProfileUrl)));
      }

      final bannerInfo = pageProps['fighter_banner_info'] as Map<String, dynamic>? ?? {};

      String finalName = '';
      if (bannerInfo['personal_info'] != null && bannerInfo['personal_info']['fighter_id'] != null) {
        finalName = bannerInfo['personal_info']['fighter_id'].toString();
      } else if (bannerInfo['fighter_id'] != null) {
        finalName = bannerInfo['fighter_id'].toString();
      }

      if (finalName.isEmpty) {
        // Fallback DOM
        final domName = await controller.evaluateJavascript(source: '''
          (function() {
            var el = document.querySelector('[class*="fighter_id"], [class*="profile_name"], h1, h2');
            return el && el.innerText ? el.innerText.trim() : "";
          })()
        ''');
        if (domName != null && domName.toString().isNotEmpty) {
          finalName = domName.toString().replaceAll('"', '').trim();
        }
      }
      if (finalName.isEmpty) finalName = '玩家_$finalSid';

      int finalLp = 0;
      int finalMr = 0;
      final leagueInfo = bannerInfo['favorite_character_league_info'] as Map<String, dynamic>? ?? {};
      if (leagueInfo['league_point'] != null) {
        finalLp = (leagueInfo['league_point'] as num).toInt();
      }
      if (leagueInfo['master_rating'] != null) {
        finalMr = (leagueInfo['master_rating'] as num).toInt();
      }

      String circleName = '';
      final circleInfo = bannerInfo['main_circle'] as Map<String, dynamic>? ?? {};
      if (circleInfo['circle_name'] != null) {
        circleName = circleInfo['circle_name'].toString();
      }

      final favCharId = bannerInfo['favorite_character_id'] ?? 29;

      // Extract Platform
      PlatformType detectedPlatform = PlatformType.steam;
      final personal = bannerInfo['personal_info'] as Map<String, dynamic>? ?? {};
      final rawPlatId = personal['platform_id'] ?? personal['platform_type'] ?? bannerInfo['platform_id'] ?? bannerInfo['platform_type'];
      final rawPlatName = (personal['platform_name'] ?? personal['platform'] ?? bannerInfo['platform_name'] ?? '').toString().toLowerCase();

      if (rawPlatName.contains('steam') || rawPlatName.contains('pc') || rawPlatId == 1) {
        detectedPlatform = PlatformType.steam;
      } else if (rawPlatName.contains('switch') || rawPlatName.contains('nintendo') || rawPlatId == 5) {
        detectedPlatform = PlatformType.nintendoSwitch2;
      } else if (rawPlatName.contains('playstation') || rawPlatName.contains('ps5') || rawPlatName.contains('ps4') || rawPlatId == 2 || rawPlatId == 3) {
        detectedPlatform = PlatformType.playstation;
      } else if (rawPlatName.contains('xbox') || rawPlatId == 4) {
        detectedPlatform = PlatformType.xbox;
      } else {
        try {
          final domPlat = await controller.evaluateJavascript(source: '''
            (function() {
              var el = document.querySelector('[class*="platform_"], [class*="hardware_"], [class*="icon_platform"]');
              if (el) return el.className;
              var txt = document.body ? document.body.innerText.substring(0, 800).toLowerCase() : '';
              if (txt.indexOf('steam') !== -1 || txt.indexOf('pc') !== -1) return 'steam';
              if (txt.indexOf('playstation') !== -1 || txt.indexOf('ps5') !== -1 || txt.indexOf('ps4') !== -1) return 'ps';
              if (txt.indexOf('xbox') !== -1) return 'xbox';
              if (txt.indexOf('switch') !== -1) return 'switch';
              return '';
            })()
          ''');
          final dpStr = domPlat?.toString().toLowerCase() ?? '';
          if (dpStr.contains('steam') || dpStr.contains('pc')) {
            detectedPlatform = PlatformType.steam;
          } else if (dpStr.contains('ps') || dpStr.contains('playstation')) {
            detectedPlatform = PlatformType.playstation;
          } else if (dpStr.contains('xbox')) {
            detectedPlatform = PlatformType.xbox;
          } else if (dpStr.contains('switch') || dpStr.contains('nintendo')) {
            detectedPlatform = PlatformType.nintendoSwitch2;
          }
        } catch (_) {}
      }

      // 2. Fetch /play, /battlelog (pages 1..5), /friend and /circle using Dio with session cookies
      setState(() => _syncStatus = '正在并发拉取历史对局与全角色胜率...');

      final dio = Dio(BaseOptions(
        headers: {
          'Cookie': cookieHeader,
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Referer': 'https://www.streetfighter.com/6/buckler/zh-hans/profile/$finalSid',
          'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

      List<dynamic> rawUsages = [];
      List<dynamic> rawReplays = [];
      List<dynamic> rawFriends = [];
      List<dynamic> rawClubMembers = [];
      Map<String, dynamic> rawPlayPageProps = {};
      final circleId = circleInfo['circle_id']?.toString() ?? '';

      try {
        final playFuture = dio.get('https://www.streetfighter.com/6/buckler/zh-hans/profile/$finalSid/play').then((res) {
          final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(res.data.toString());
          if (m != null) {
            final pData = jsonDecode(m.group(1)!);
            final pProps = pData['props']?['pageProps'];
            if (pProps is Map<String, dynamic>) {
              rawPlayPageProps = pProps;
            }
            final playObj = pProps?['play'] ?? pProps;
            final cList = playObj?['character_league_infos'] ?? playObj?['character_league_list'] ?? playObj?['character_win_rates'] ?? playObj?['character_list'];
            if (cList is List) {
              final Map<String, Map<String, dynamic>> usageMap = {};
              for (final c in cList) {
                if (c is! Map) continue;
                final rawCid = c['character_id'] ?? c['character_tool_name'] ?? c['character_name'];
                final cChar = Sf6Characters.fromCapcomId(rawCid);
                final rawLp = _safeInt(c['league_info']?['league_point'] ?? c['league_point'] ?? c['lp']);
                final rawMr = _safeInt(c['league_info']?['master_rating'] ?? c['master_rating'] ?? c['mr']);
                
                // Filter out unranked/unplaced characters (e.g. -1 LP or 0 LP / 0 MR)
                if (rawLp <= 0 && rawMr <= 0) continue;

                final validLp = rawLp > 0 ? rawLp : 0;
                final validMr = rawMr > 0 ? rawMr : 0;
                final matches = _safeInt(c['play_count'] ?? c['total_matches'] ?? c['playing_count'] ?? c['matches']);
                final wins = _safeInt(c['win_count'] ?? c['wins']);
                final winRate = _safeDouble(c['win_rate'], (matches > 0 ? (wins / matches) * 100.0 : 0.0));

                usageMap[cChar.id] = {
                  'character_id': cChar.id,
                  'league_point': validLp,
                  'master_rating': validMr,
                  'play_count': matches,
                  'win_count': wins,
                  'win_rate': winRate,
                };
              }
              rawUsages = usageMap.values.toList();
            }
          }
        }).catchError((e) {
          AppLogger.instance.warn('SyncEngine', '拉取 /play 异常: $e');
        });

        final friendFuture = dio.get('https://www.streetfighter.com/6/buckler/zh-hans/fighterslist/friend').then((res) {
          final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(res.data.toString());
          if (m != null) {
            final fData = jsonDecode(m.group(1)!);
            final fFriends = NextDataParser.parseFriends(fData);
            if (fFriends.isNotEmpty) {
              rawFriends = fFriends.map((f) => f.toJson()).toList();
            }
          }
        }).catchError((e) {
          AppLogger.instance.warn('SyncEngine', '拉取 /fighterslist/friend 异常: $e');
        });

        final clubFuture = Future(() async {
          List<ClubModel> parsedClubs = [];
          
          // 1. Try official /club/list first (Capcom official route for all joined clubs)
          try {
            final listRes = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/club/list');
            final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(listRes.data.toString());
            if (m != null) {
              final cData = jsonDecode(m.group(1)!);
              parsedClubs = NextDataParser.parseClubsList(cData);
              if (parsedClubs.isNotEmpty) {
                AppLogger.instance.info('SyncEngine', '从 /club/list 成功解析 ${parsedClubs.length} 个俱乐部');
              }
            }
          } catch (e) {
            AppLogger.instance.warn('SyncEngine', '拉取 /club/list 异常: $e');
          }

          // 2. Fallback to /profile/$finalSid/club
          if (parsedClubs.isEmpty) {
            try {
              final profRes = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/profile/$finalSid/club');
              final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(profRes.data.toString());
              if (m != null) {
                final cData = jsonDecode(m.group(1)!);
                parsedClubs = NextDataParser.parseClubsList(cData);
                if (parsedClubs.isNotEmpty) {
                  AppLogger.instance.info('SyncEngine', '从 /profile/$finalSid/club 解析出 ${parsedClubs.length} 个俱乐部');
                }
              }
            } catch (e) {
              AppLogger.instance.warn('SyncEngine', '拉取 /profile/$finalSid/club 异常: $e');
            }
          }

          // 3. Fallback to main_circle from profile banner
          if (parsedClubs.isEmpty && circleName.isNotEmpty) {
            parsedClubs.add(ClubModel(
              clubId: circleId.isNotEmpty ? circleId : 'club_${circleName.hashCode.abs()}',
              clubName: circleName,
              tag: circleInfo['circle_tag']?.toString() ?? (circleName.length > 4 ? circleName.substring(0, 4).toUpperCase() : circleName.toUpperCase()),
              isMainClub: true,
              memberCount: 0,
              members: [],
            ));
          }

          // 4. Concurrently fetch full details for each club (/club/[clubid])
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
                    AppLogger.instance.info('SyncEngine', '成功获取战队 [${detailed.clubName}] 成员 ${detailed.members.length} 人 (在线 ${detailed.members.where((m) => m.isOnline).length} 人)');
                    continue;
                  }
                }
              } catch (e) {
                AppLogger.instance.warn('SyncEngine', '拉取战队详情 /club/${cur.clubId} 异常: $e');
              }
            }
            detailedClubs.add(cur.copyWith(isMainClub: isThisMain));
          }

          rawClubMembers = detailedClubs.map((c) => c.toJson()).toList();
          AppLogger.instance.info('SyncEngine', '俱乐部同步完成，共持久化 ${rawClubMembers.length} 个战队俱乐部');
        }).catchError((e) {
          AppLogger.instance.warn('SyncEngine', '俱乐部同步过程异常: $e');
        });

        final battlelogFutures = List.generate(10, (idx) {
          final p = idx + 1;
          final url = 'https://www.streetfighter.com/6/buckler/zh-hans/profile/$finalSid/battlelog${p > 1 ? '?page=$p' : ''}';
          return dio.get(url).then((res) {
            final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(res.data.toString());
            if (m != null) {
              final bData = jsonDecode(m.group(1)!);
              final bProps = bData['props']?['pageProps'];
              final rList = bProps?['replay_list'] ?? bProps?['battle_list'] ?? bProps?['battlelog'] ?? bProps?['replays'] ?? bProps?['play']?['replay_list'];
              if (rList is List && rList.isNotEmpty) {
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
            AppLogger.instance.warn('SyncEngine', '拉取 /battlelog 第 $p 页异常: $e');
          });
        });

        await Future.wait([
          playFuture,
          friendFuture,
          clubFuture,
          ...battlelogFutures,
        ]);
      } catch (e) {
        AppLogger.instance.warn('SyncEngine', '并发拉取子页面异常: $e');
      }

      // 3. Fallback character usages from pageProps['play'] if /play had no data
      if (rawUsages.isEmpty && pageProps['play'] != null) {
        final playObj = pageProps['play'];
        final cList = playObj['character_league_infos'] ?? playObj['character_league_list'] ?? playObj['character_win_rates'] ?? playObj['character_list'] ?? playObj['characters'];
        if (cList is List) {
          final Map<String, Map<String, dynamic>> usageMap = {};
          for (final c in cList) {
            if (c is! Map) continue;
            final rawCid = c['character_id'] ?? c['character_tool_name'] ?? c['character_name'];
            final cChar = Sf6Characters.fromCapcomId(rawCid);
            final rawLp = _safeInt(c['league_info']?['league_point'] ?? c['league_point'] ?? c['lp']);
            final rawMr = _safeInt(c['league_info']?['master_rating'] ?? c['master_rating'] ?? c['mr']);
            
            if (rawLp <= 0 && rawMr <= 0) continue;

            final validLp = rawLp > 0 ? rawLp : 0;
            final validMr = rawMr > 0 ? rawMr : 0;
            final matches = _safeInt(c['play_count'] ?? c['total_matches'] ?? c['playing_count'] ?? c['matches']);
            final wins = _safeInt(c['win_count'] ?? c['wins']);
            final winRate = _safeDouble(c['win_rate'], (matches > 0 ? (wins / matches) * 100.0 : 0.0));

            usageMap[cChar.id] = {
              'character_id': cChar.id,
              'league_point': validLp,
              'master_rating': validMr,
              'play_count': matches,
              'win_count': wins,
              'win_rate': winRate,
            };
          }
          rawUsages = usageMap.values.toList();
        }
      }

      if (rawUsages.isNotEmpty) {
        rawUsages.sort((a, b) => _safeInt(b['play_count']).compareTo(_safeInt(a['play_count'])));
      }

      // 4. Accurately resolve user's real character from match history
      String resolvedCharId = 'luke';
      if (rawReplays.isNotEmpty) {
        final counts = <String, int>{};
        for (final r in rawReplays) {
          final p1 = r['player1_info'] ?? r['player1'] ?? {};
          final p2 = r['player2_info'] ?? r['player2'] ?? {};
          final p1Sid = (p1['player']?['short_id'] ?? p1['player_info']?['short_id'] ?? p1['personal_info']?['short_id'] ?? p1['short_id'] ?? p1['sid'] ?? '').toString();
          final isP1 = (p1Sid == finalSid || p1Sid.contains(finalSid));
          final userP = isP1 ? p1 : p2;
          final rawChar = userP['character_id'] ?? userP['character_tool_name'] ?? userP['character_name'] ?? userP['char_id'] ?? 1;
          final charObj = Sf6Characters.fromCapcomId(rawChar);
          counts[charObj.id] = (counts[charObj.id] ?? 0) + 1;
        }
        if (counts.isNotEmpty) {
          final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          resolvedCharId = sorted.first.key;
        }
      } else if (rawUsages.isNotEmpty) {
        resolvedCharId = Sf6Characters.fromCapcomId(rawUsages.first['character_id']).id;
      } else {
        resolvedCharId = Sf6Characters.fromCapcomId(favCharId).id;
      }

      int resolvedPayloadLp = finalLp;
      int resolvedPayloadMr = finalMr;
      if (rawUsages.isNotEmpty) {
        Map<String, dynamic>? mainU;
        for (final u in rawUsages) {
          if (u is Map) {
            final uCid = Sf6Characters.fromCapcomId(u['character_id']).id;
            if (uCid.toLowerCase() == resolvedCharId.toLowerCase()) {
              mainU = Map<String, dynamic>.from(u);
              break;
            }
          }
        }
        if (mainU != null) {
          final cLp = _safeInt(mainU['league_point'] ?? mainU['lp']);
          final cMr = _safeInt(mainU['master_rating'] ?? mainU['mr']);
          if (cLp > 0 || cMr > 0) {
            resolvedPayloadLp = cLp;
            resolvedPayloadMr = cMr;
          }
        }
      }

      // 5. Parse official career rival matchups
      final officialMatchups = NextDataParser.parseOfficialRivalMatchups(
        {'play': rawPlayPageProps['play'] ?? rawPlayPageProps ?? pageProps['play'] ?? {}}
      );

      // 6. Parse official playstyle radar battle stats
      final rawBattleStats = (rawPlayPageProps['play']?['battle_stats'] ?? rawPlayPageProps['battle_stats'] ?? pageProps['play']?['battle_stats'] ?? pageProps['battle_stats']) as Map<String, dynamic>? ?? {};
      final radarStats = NextDataParser.parseRadarStats(rawBattleStats);

      setState(() => _isSyncing = false);

      final payload = {
        'short_id': finalSid,
        'fighter_id': finalName,
        'league_point': resolvedPayloadLp,
        'master_rating': resolvedPayloadMr,
        'circle_name': circleName,
        'circle_id': circleId,
        'favorite_char_id': resolvedCharId,
        'replays': rawReplays,
        'character_usages': rawUsages,
        'official_matchups': officialMatchups,
        'friends': rawFriends,
        'club_members': rawClubMembers,
        'radar_stats': radarStats.toJson(),
        'detected_platform': detectedPlatform,
      };

      AppLogger.instance.net('SyncEngine', '子页面网络抓包: /play=${rawUsages.length}角色, 官方全量对策表=${officialMatchups.length}条, /battlelog=${rawReplays.length}对局, /friend=${rawFriends.length}好友, /club=${rawClubMembers.length}俱乐部, 六维战斗评估=[攻:${radarStats.offense}, 防:${radarStats.defense}, 技:${radarStats.technique}, 槽:${radarStats.driveGauge}, 空:${radarStats.antiAir}]');
      AppLogger.instance.sync('SyncEngine', '全分子系统抓取就绪: Fighter ID=$finalName, LP=$finalLp, 平台=${detectedPlatform.displayName}, 战队=[$circleName], 实战主用角色=[${Sf6Characters.getById(resolvedCharId).nameZh}]');
      _showConfirmProfileDialog(context, payload);
    } catch (e, stackTrace) {
      setState(() => _isSyncing = false);
      AppLogger.instance.error('SyncEngine', '同步流程异常: $e', stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('动态抓取异常: $e'), backgroundColor: AppColors.loseRed),
        );
      }
    }
  }

  void _showConfirmProfileDialog(BuildContext context, Map<String, dynamic> data) {
    final shortId = (data['short_id'] ?? '').toString();
    final fighterId = (data['fighter_id'] ?? '').toString();
    final lp = (data['league_point'] as num?)?.toInt() ?? 0;
    final mr = (data['master_rating'] as num?)?.toInt() ?? 0;
    final circleName = (data['circle_name'] ?? '').toString();
    final circleId = (data['circle_id'] ?? '').toString();
    final favCharStr = (data['favorite_char_id'] ?? 'elena').toString();
    final rawReplays = data['replays'] as List? ?? [];
    final rawUsages = data['character_usages'] as List? ?? [];
    final officialMatchups = (data['official_matchups'] as Map<String, List<MatchupStat>>?) ?? {};
    final rawFriends = data['friends'] as List? ?? [];
    final rawClubMembers = data['club_members'] as List? ?? [];

    // Helper to find character's LP & MR in rawUsages
    Map<String, dynamic> findCharUsage(String charId) {
      if (rawUsages.isEmpty) return {};
      for (final u in rawUsages) {
        if (u is! Map) continue;
        final uCharId = u['character_id']?.toString().toLowerCase();
        final uObj = Sf6Characters.fromCapcomId(u['character_id']);
        if (uCharId == charId.toLowerCase() || uObj.id == charId.toLowerCase()) {
          return Map<String, dynamic>.from(u);
        }
      }
      return {};
    }

    int initialLp = lp;
    int initialMr = mr;
    if (rawUsages.isNotEmpty) {
      final match = findCharUsage(favCharStr);
      if (match.isNotEmpty) {
        final cLp = _safeInt(match['league_point'] ?? match['lp']);
        final cMr = _safeInt(match['master_rating'] ?? match['mr']);
        if (cLp > 0 || cMr > 0) {
          initialLp = cLp;
          initialMr = cMr;
        }
      }
    }

    final nameController = TextEditingController(text: fighterId);
    final shortIdController = TextEditingController(text: shortId);
    final lpController = TextEditingController(text: '$initialLp');
    final mrController = TextEditingController(text: '$initialMr');
    PlatformType selectedPlatform = (data['detected_platform'] as PlatformType?) ?? PlatformType.steam;
    String selectedCharacterId = favCharStr;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderCtx, setDialogState) {
            final currentCharObj = Sf6Characters.getById(selectedCharacterId);
            final currentDisplayLp = int.tryParse(lpController.text.trim()) ?? initialLp;
            return AlertDialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.verified, color: AppColors.winGreen),
                  SizedBox(width: 8),
                  Text('确认同步官方玩家档案', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accentNeonCyan.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.winGreen, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '实时动态嗅探：$currentDisplayLp LP  •  本命角色: ${currentCharObj.nameZh}' +
                                  (rawReplays.isNotEmpty ? '  •  已捕获 ${rawReplays.length} 局历史对战' : '') +
                                  (circleName.isNotEmpty ? '  •  战队: [$circleName]' : ''),
                              style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '玩家昵称 (Fighter ID)',
                        hintText: '输入你的游戏内昵称',
                        prefixIcon: Icon(Icons.person, size: 20, color: AppColors.accentNeonCyan),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: shortIdController,
                      decoration: const InputDecoration(
                        labelText: 'Short ID',
                        prefixIcon: Icon(Icons.tag, size: 20, color: AppColors.accentNeonYellow),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: Sf6Characters.all.any((c) => c.id == selectedCharacterId) ? selectedCharacterId : Sf6Characters.all.first.id,
                      decoration: const InputDecoration(
                        labelText: '选择/确认你的主玩角色',
                        prefixIcon: Icon(Icons.sports_martial_arts, size: 20, color: AppColors.accentNeonCyan),
                      ),
                      dropdownColor: AppColors.bgCard,
                      items: Sf6Characters.all.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.nameZh} (${c.nameEn})', style: const TextStyle(color: AppColors.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCharacterId = val;
                            final match = findCharUsage(val);
                            if (match.isNotEmpty) {
                              final cLp = (match['league_point'] ?? match['lp'] ?? 0) as int;
                              final cMr = (match['master_rating'] ?? match['mr'] ?? 0) as int;
                              lpController.text = '$cLp';
                              mrController.text = '$cMr';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'LP 积分',
                              hintText: '例如 15000',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: mrController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'MR 评分 (非大师为0)',
                              hintText: '0',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('选择游玩平台：', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: PlatformType.values.map((p) {
                        final isSelected = selectedPlatform == p;
                        return ChoiceChip(
                          label: Text(p.displayName),
                          selected: isSelected,
                          onSelected: (_) => setDialogState(() => selectedPlatform = p),
                          selectedColor: AppColors.accentNeonCyan.withOpacity(0.3),
                          backgroundColor: AppColors.bgSecondary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(dialogContext, rootNavigator: true).pop(),
                  child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.winGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSaving ? null : () async {
                    setDialogState(() => isSaving = true);
                    try {
                      final finalSid = shortIdController.text.trim().isNotEmpty ? shortIdController.text.trim() : shortId;
                      final finalName = nameController.text.trim().isNotEmpty ? nameController.text.trim() : '玩家_$finalSid';
                      final finalLp = int.tryParse(lpController.text.trim()) ?? lp;
                      final finalMr = int.tryParse(mrController.text.trim()) ?? 0;

                      final cookieManager = CookieManager.instance();
                      final cookies = await cookieManager.getCookies(url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/'));
                      final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');

                      // 1. Batch insert real battle records into SQLite if any
                      List<BattleRecord> records = [];
                      if (rawReplays.isNotEmpty) {
                        records = NextDataParser.parseBattleLog(
                          {'props': {'pageProps': {'replay_list': rawReplays}}},
                          userShortId: finalSid,
                          platform: selectedPlatform.code,
                        );
                        AppLogger.instance.sql('SyncEngine', 'NextDataParser 解析完成: 原始对局 ${rawReplays.length} 条 -> 转换为 ${records.length} 条有效记录');
                        if (records.isNotEmpty) {
                          await DatabaseHelper.instance.deleteBattleRecordsByShortId(finalSid);
                          await DatabaseHelper.instance.batchInsertBattleRecords(records);
                          AppLogger.instance.sql('SyncEngine', '成功向 SQLite 写入 ${records.length} 场真实对战记录 (已清理旧记录)');
                        }
                      }

                      // 1.1 Save official full career rival matchups
                      if (officialMatchups.isNotEmpty) {
                        await DatabaseHelper.instance.insertOfficialMatchupStats(
                          shortId: finalSid,
                          platform: selectedPlatform.code,
                          statsMap: officialMatchups,
                        );
                        AppLogger.instance.sql('SyncEngine', '成功持久化官方全生涯克制总览: 包含 ${officialMatchups.length} 个角色对策表');
                      }

                      // 2. Resolve true main character
                      String trueMainChar = selectedCharacterId;
                      AppLogger.instance.auth('SyncEngine', '确定主玩角色: $trueMainChar (${Sf6Characters.getById(trueMainChar).nameZh})');

                      // 3. Save Friends, Club Members, and Radar Battle Stats
                      List<Map<String, dynamic>> friendsJsonList = [];
                      if (rawFriends.isNotEmpty) {
                        friendsJsonList = rawFriends.map((f) => f is Map ? Map<String, dynamic>.from(f) : <String, dynamic>{}).toList();
                      }
                      List<Map<String, dynamic>> clubsJsonList = [];
                      if (rawClubMembers.isNotEmpty) {
                        clubsJsonList = rawClubMembers.map((c) => c is Map ? Map<String, dynamic>.from(c) : <String, dynamic>{}).toList();
                      } else if (circleName.isNotEmpty) {
                        clubsJsonList.add(ClubModel(
                          clubId: circleId.isNotEmpty ? circleId : 'club_${circleName.hashCode.abs()}',
                          clubName: circleName,
                          tag: circleName.length > 4 ? circleName.substring(0, 4).toUpperCase() : circleName.toUpperCase(),
                          memberCount: 1,
                          members: [],
                        ).toJson());
                      }

                      await StorageService.instance.saveSocialData(
                        finalSid,
                        friends: friendsJsonList,
                        clubs: clubsJsonList,
                      );

                      final radarStatsMap = (data['radar_stats'] as Map<String, dynamic>?) ?? {};
                      if (radarStatsMap.isNotEmpty) {
                        await StorageService.instance.saveRadarStatsJson(finalSid, radarStatsMap);
                      }

                      if (rawUsages.isNotEmpty) {
                        final usageList = rawUsages.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
                        await StorageService.instance.saveCharacterUsagesJson(finalSid, usageList);
                      }

                      List<CharacterUsage> parsedCharacterUsages = [];
                      if (rawUsages.isNotEmpty) {
                        for (final e in rawUsages) {
                          if (e is! Map) continue;
                          final cid = Sf6Characters.fromCapcomId(e['character_id']).id;
                          final uLp = _safeInt(e['league_point'] ?? e['lp']);
                          final uMr = _safeInt(e['master_rating'] ?? e['mr']);
                          final uMatches = _safeInt(e['play_count'] ?? e['matches'] ?? e['total_matches']);
                          final uWins = _safeInt(e['win_count'] ?? e['wins']);
                          final uWr = _safeDouble(e['win_rate'], (uMatches > 0 ? (uWins / uMatches) * 100.0 : 0.0));
                          parsedCharacterUsages.add(CharacterUsage(
                            characterId: cid,
                            matches: uMatches,
                            wins: uWins,
                            winRate: uWr,
                            lp: uLp,
                            mr: uMr,
                          ));
                        }
                      }

                      // 4. Save account and platform
                      await widget.authService.addAccountFromLogin(
                        capcomId: finalSid,
                        displayName: finalName,
                        cookieSession: cookieHeader,
                        platforms: [
                          PlatformProfile(
                            platformType: selectedPlatform,
                            shortId: finalSid,
                            fighterId: finalName,
                            avatarUrl: '',
                            currentLp: finalLp,
                            currentMr: finalMr,
                            clubName: circleName,
                            mainCharId: trueMainChar,
                            characterUsages: parsedCharacterUsages,
                          ),
                        ],
                      );

                      AppLogger.instance.sync('SyncEngine', '玩家档案已持久化: $finalName ($finalSid), 主玩: $trueMainChar, 战队: [$circleName]');

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext, rootNavigator: true).pop();
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('成功同步玩家：$finalName (LP: $finalLp, 平台: ${selectedPlatform.displayName}' + (circleName.isNotEmpty ? ', 战队: [$circleName])' : ')')),
                            backgroundColor: AppColors.winGreen,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      setDialogState(() => isSaving = false);
                      AppLogger.instance.error('SyncEngine', '保存异常: $e');
                    }
                  },
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('确认并保存', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManualInputDialog(BuildContext context) {
    final controller = TextEditingController(text: '');
    final nameController = TextEditingController();
    final lpController = TextEditingController(text: '0');
    final mrController = TextEditingController(text: '0');
    PlatformType selectedPlatform = PlatformType.steam;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.person_add, color: AppColors.accentNeonCyan),
                  SizedBox(width: 8),
                  Text('手动绑定玩家资料', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '输入 10 位 Short ID 或直接粘贴个人主页 URL：',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Short ID 或个人主页网址',
                        hintText: '例如 1234567890 或 https://.../profile/1234567890',
                      ),
                      onChanged: (val) {
                        final reg = RegExp(r'/profile/(\d+)');
                        final match = reg.firstMatch(val);
                        if (match != null) {
                          controller.text = match.group(1)!;
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '玩家昵称 (Fighter ID)',
                        hintText: '输入你的游戏内昵称 (如留空默认使用Short ID)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'LP 积分',
                              hintText: '例如 15000',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: mrController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'MR 评分 (非大师填 0)',
                              hintText: '0',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('选择游玩平台：', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: PlatformType.values.map((p) {
                        final isSelected = selectedPlatform == p;
                        return ChoiceChip(
                          label: Text(p.displayName),
                          selected: isSelected,
                          onSelected: (_) => setDialogState(() => selectedPlatform = p),
                          selectedColor: AppColors.accentNeonCyan.withOpacity(0.3),
                          backgroundColor: AppColors.bgSecondary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentNeonCyan,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    String input = controller.text.trim();
                    final reg = RegExp(r'(\d{8,12})');
                    final match = reg.firstMatch(input);
                    final extractedId = match != null ? match.group(1)! : input;
                    final lpVal = int.tryParse(lpController.text.trim()) ?? 0;
                    final mrVal = int.tryParse(mrController.text.trim()) ?? 0;
                    final fighterName = nameController.text.trim().isNotEmpty
                        ? nameController.text.trim()
                        : '玩家_$extractedId';

                    if (extractedId.isNotEmpty) {
                      await widget.authService.addAccountFromShortId(
                        shortId: extractedId,
                        fighterId: fighterName,
                        platformType: selectedPlatform,
                        lp: lpVal,
                        mr: mrVal,
                      );
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已成功绑定玩家: $fighterName (Short ID: $extractedId, 平台: ${selectedPlatform.displayName})')),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('确认绑定', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDiagnosticModal() async {
    if (_webViewController == null) return;

    final currentUrl = (await _webViewController!.getUrl())?.toString() ?? '未知';
    final title = await _webViewController!.getTitle() ?? '未知';

    final diagnosticJson = await _webViewController!.evaluateJavascript(source: '''
      (function() {
        var report = {
          url: window.location.href,
          title: document.title,
          page_type: (function() {
            var u = window.location.href;
            if (u.indexOf('/profile/') !== -1) return '【个人主页资料档案页】';
            if (u.indexOf('/battlelog') !== -1) return '【格斗对战记录库】';
            if (u.indexOf('/play') !== -1) return '【各角色基本资料页】';
            return '【官方新闻与活动主页 (点击同步将自动跳转个人页)】';
          })(),
          cookies_length: document.cookie ? document.cookie.length : 0,
          has_next_data: !!window.__NEXT_DATA__,
          next_data_keys: window.__NEXT_DATA__ && window.__NEXT_DATA__.props ? Object.keys(window.__NEXT_DATA__.props) : [],
          page_props_keys: window.__NEXT_DATA__ && window.__NEXT_DATA__.props && window.__NEXT_DATA__.props.pageProps ? Object.keys(window.__NEXT_DATA__.props.pageProps) : [],
          sample_headings: Array.from(document.querySelectorAll('h1, h2, h3')).map(function(e) { return e.innerText; }).slice(0, 8),
          detected_platform: (function() {
            var html = document.body.innerHTML.toLowerCase();
            if (html.indexOf('switch') !== -1 || html.indexOf('nintendo') !== -1) return 'Nintendo Switch (NS2)';
            if (html.indexOf('ps5') !== -1 || html.indexOf('ps4') !== -1) return 'PlayStation';
            if (html.indexOf('xbox') !== -1) return 'Xbox';
            if (html.indexOf('steam') !== -1) return 'Steam';
            return '未知';
          })(),
          next_data_preview: window.__NEXT_DATA__ ? JSON.stringify(window.__NEXT_DATA__.props).substring(0, 800) : ''
        };
        return JSON.stringify(report, null, 2);
      })()
    ''');

    final activeAccount = widget.authService.activeAccount;
    final activePlatform = widget.authService.activePlatform;
    final dbRecords = await DatabaseHelper.instance.getBattleRecords(
      shortId: activePlatform?.shortId ?? '',
      platform: activePlatform?.platformType.code ?? '',
    );

    final fullReport = AppLogger.instance.buildComprehensiveReport(
      activeAccountName: activeAccount?.displayName ?? '未登录',
      activePlatformName: activePlatform?.platformType.displayName ?? '未选择',
      activeShortId: activePlatform?.shortId ?? '无',
      activeLp: activePlatform?.currentLp ?? 0,
      activeMr: activePlatform?.currentMr ?? 0,
      dbBattleRecordsCount: dbRecords.length,
      currentUrl: currentUrl,
      pageTitle: title,
      webviewDiagnosticJson: diagnosticJson?.toString(),
    );

    if (!mounted) return;

    String selectedFilter = 'ALL';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final logs = AppLogger.instance.getLogsByLevel(selectedFilter);
            final errorWarnCount = AppLogger.instance.errorCount + AppLogger.instance.warnCount;
            final syncCount = AppLogger.instance.syncCount;
            final netCount = AppLogger.instance.netCount;

            final conciseSummary = AppLogger.instance.buildConciseDiagnosticSummary(
              activeAccountName: activeAccount?.displayName ?? '未登录',
              activePlatformName: activePlatform?.platformType.displayName ?? '未选择',
              activeShortId: activePlatform?.shortId ?? '无',
              activeLp: activePlatform?.currentLp ?? 0,
              activeMr: activePlatform?.currentMr ?? 0,
              clubName: activePlatform?.clubName ?? '',
              dbBattleRecordsCount: dbRecords.length,
              currentUrl: currentUrl,
            );

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monitor_heart, color: AppColors.accentNeonYellow, size: 22),
                          const SizedBox(width: 8),
                          const Text('WebView 实时抓包与诊断', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_sweep, color: AppColors.textTertiary, size: 20),
                            tooltip: '清空历史日志',
                            onPressed: () {
                              AppLogger.instance.clear();
                              setModalState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已清空运行日志缓存'), duration: Duration(seconds: 1)),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textSecondary),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDiagnosticFilterChip('全部 (${AppLogger.instance.logs.length})', 'ALL', selectedFilter, setModalState),
                        const SizedBox(width: 6),
                        _buildDiagnosticFilterChip('异常/警告 ($errorWarnCount)', 'ISSUES', selectedFilter, setModalState, alertColor: AppColors.loseRed),
                        const SizedBox(width: 6),
                        _buildDiagnosticFilterChip('同步流水 ($syncCount)', 'SYNC', selectedFilter, setModalState, alertColor: AppColors.winGreen),
                        const SizedBox(width: 6),
                        _buildDiagnosticFilterChip('网络抓包 ($netCount)', 'NET', selectedFilter, setModalState, alertColor: AppColors.accentNeonCyan),
                      ],
                    ),
                  ),
                  const Divider(height: 18),
                  Expanded(
                    child: logs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline, size: 48, color: AppColors.winGreen.withOpacity(0.5)),
                                const SizedBox(height: 8),
                                const Text('当前分类下暂无日志记录，运行良好', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: logs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (c, idx) {
                              final entry = logs[idx];
                              Color badgeColor;
                              Color badgeBg;
                              switch (entry.level) {
                                case 'ERROR':
                                  badgeColor = AppColors.loseRed;
                                  badgeBg = AppColors.loseRed.withOpacity(0.18);
                                  break;
                                case 'WARN':
                                  badgeColor = AppColors.accentNeonYellow;
                                  badgeBg = AppColors.accentNeonYellow.withOpacity(0.18);
                                  break;
                                case 'SYNC':
                                  badgeColor = AppColors.winGreen;
                                  badgeBg = AppColors.winGreen.withOpacity(0.18);
                                  break;
                                case 'NET':
                                  badgeColor = AppColors.accentNeonCyan;
                                  badgeBg = AppColors.accentNeonCyan.withOpacity(0.18);
                                  break;
                                default:
                                  badgeColor = AppColors.textSecondary;
                                  badgeBg = AppColors.bgSecondary;
                              }

                              final timeStr = DateFormat('HH:mm:ss.SSS').format(entry.timestamp);

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSecondary,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: badgeColor.withOpacity(0.25)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: badgeBg,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            entry.level,
                                            style: TextStyle(color: badgeColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '[$timeStr]',
                                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 10.5, fontFamily: 'monospace'),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            entry.tag,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    SelectableText(
                                      entry.message,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: entry.level == 'ERROR' ? AppColors.loseRed : AppColors.textPrimary,
                                        fontFamily: 'monospace',
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.content_paste_go, color: Colors.black, size: 16),
                          label: const Text('复制精简诊断报告 (发给开发)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentNeonYellow,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: conciseSummary));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已复制精简诊断报告！内容精炼，无冗余刷屏，可直接发给开发排查。'), backgroundColor: AppColors.winGreen),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.copy_all, size: 15, color: AppColors.accentNeonCyan),
                          label: const Text('复制全量黑匣子', style: TextStyle(color: AppColors.accentNeonCyan, fontSize: 11.5)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accentNeonCyan),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: fullReport));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已复制全量黑匣子流水日志！'), backgroundColor: AppColors.accentNeonCyan),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiagnosticFilterChip(String label, String value, String selected, void Function(void Function()) setModalState, {Color? alertColor}) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setModalState(() => selected = value),
      selectedColor: (alertColor ?? AppColors.accentNeonCyan).withOpacity(0.25),
      backgroundColor: AppColors.bgSecondary,
      labelStyle: TextStyle(
        color: isSelected ? (alertColor ?? AppColors.accentNeonCyan) : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11.5,
      ),
    );
  }
}
