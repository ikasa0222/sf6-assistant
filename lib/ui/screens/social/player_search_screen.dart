import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/core/network/next_data_parser.dart';
import 'package:sf6_tracker/core/storage/database_helper.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/models/friend_model.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/ui/screens/social/player_profile_screen.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/rank_badge.dart';

class SearchPlayerResult {
  final String shortId;
  final String fighterId;
  final String mainCharacterId;
  final int lp;
  final int mr;
  final String platform;
  final String clubName;
  final String sourceDescription;
  final bool isOfficialNetwork;

  const SearchPlayerResult({
    required this.shortId,
    required this.fighterId,
    required this.mainCharacterId,
    this.lp = 0,
    this.mr = 0,
    this.platform = '1',
    this.clubName = '',
    required this.sourceDescription,
    this.isOfficialNetwork = false,
  });
}

class PlayerSearchScreen extends StatefulWidget {
  final AuthService? authService;
  final SocialService socialService;
  final BattleLogService? battleLogService;

  const PlayerSearchScreen({
    super.key,
    this.authService,
    required this.socialService,
    this.battleLogService,
  });

  @override
  State<PlayerSearchScreen> createState() => _PlayerSearchScreenState();
}

class _PlayerSearchScreenState extends State<PlayerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isShortIdMode = false;
  bool _isSearchingNetwork = false;
  String _networkErrorMessage = '';

  List<String> _recentSearches = [];
  List<SearchPlayerResult> _localResults = [];
  List<SearchPlayerResult> _networkResults = [];

  static const String _keyRecentSearches = 'sf6_recent_player_searches';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_onSearchInputChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchInputChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyRecentSearches) ?? [];
      if (mounted) setState(() => _recentSearches = list);
    } catch (_) {}
  }

  Future<void> _saveRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.remove(clean);
      _recentSearches.insert(0, clean);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
      await prefs.setStringList(_keyRecentSearches, _recentSearches);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRecentSearches);
      if (mounted) setState(() => _recentSearches = []);
    } catch (_) {}
  }

  void _onSearchInputChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _localResults = [];
        _networkResults = [];
        _networkErrorMessage = '';
      });
      return;
    }

    if (RegExp(r'^\d{7,12}$').hasMatch(query)) {
      if (!_isShortIdMode) {
        setState(() => _isShortIdMode = true);
      }
    }

    _filterLocalResults(query);
  }

  Future<void> _filterLocalResults(String query) async {
    final qLower = query.toLowerCase();
    final Map<String, SearchPlayerResult> map = {};

    for (final f in widget.socialService.friends) {
      final sIdMatch = f.shortId.contains(query);
      final fIdMatch = f.fighterId.toLowerCase().contains(qLower);
      if (sIdMatch || fIdMatch) {
        map[f.shortId] = SearchPlayerResult(
          shortId: f.shortId,
          fighterId: f.fighterId,
          mainCharacterId: f.mainCharacterId,
          lp: f.lp,
          mr: f.mr,
          platform: f.platform,
          sourceDescription: '好友列表',
        );
      }
    }

    for (final c in widget.socialService.clubs) {
      for (final m in c.members) {
        final sIdMatch = m.shortId.contains(query);
        final fIdMatch = m.fighterId.toLowerCase().contains(qLower);
        if (sIdMatch || fIdMatch) {
          if (!map.containsKey(m.shortId)) {
            map[m.shortId] = SearchPlayerResult(
              shortId: m.shortId,
              fighterId: m.fighterId,
              mainCharacterId: m.mainCharacterId,
              lp: m.lp,
              mr: m.mr,
              platform: m.platform,
              clubName: c.clubName,
              sourceDescription: '战队 [${c.clubName}]',
            );
          }
        }
      }
    }

    try {
      final activeSid = widget.authService?.activePlatform?.shortId ?? '';
      final dbRecords = await DatabaseHelper.instance.getAllBattleRecords(
        shortId: activeSid,
      );

      final oppCounts = <String, int>{};
      final oppNames = <String, String>{};
      final oppChars = <String, String>{};
      final oppPlatforms = <String, String>{};

      for (final r in dbRecords) {
        final oSid = r.opponentShortId.trim();
        final oFid = r.opponentFighterId.trim();
        if (oSid.isEmpty && oFid.isEmpty) continue;
        final key = oSid.isNotEmpty ? oSid : oFid;
        oppCounts[key] = (oppCounts[key] ?? 0) + 1;
        if (oFid.isNotEmpty) oppNames[key] = oFid;
        if (r.opponentCharacterId.isNotEmpty) oppChars[key] = r.opponentCharacterId;
        if (r.opponentPlatform.isNotEmpty) oppPlatforms[key] = r.opponentPlatform;
      }

      for (final entry in oppCounts.entries) {
        final key = entry.key;
        final name = oppNames[key] ?? key;
        final count = entry.value;
        final isShortId = RegExp(r'^\d+$').hasMatch(key);
        final sIdMatch = isShortId && key.contains(query);
        final fIdMatch = name.toLowerCase().contains(qLower);

        if (sIdMatch || fIdMatch) {
          final targetSid = isShortId ? key : '';
          if (!map.containsKey(targetSid) && targetSid.isNotEmpty) {
            map[targetSid] = SearchPlayerResult(
              shortId: targetSid,
              fighterId: name,
              mainCharacterId: oppChars[key] ?? 'luke',
              platform: oppPlatforms[key] ?? '1',
              sourceDescription: '历史交手对手 ($count 次对决)',
            );
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _localResults = map.values.toList();
      });
    }
  }

  Future<void> _performNetworkSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    _saveRecentSearch(query);
    _searchFocusNode.unfocus();

    setState(() {
      _isSearchingNetwork = true;
      _networkErrorMessage = '';
      _networkResults = [];
    });

    try {
      String cookieHeader = widget.authService?.activeAccount?.cookieSession ?? '';
      try {
        final cookieManager = CookieManager.instance();
        final cookies = await cookieManager.getCookies(
          url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/'),
        ).timeout(const Duration(seconds: 3));
        final nativeHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');
        if (nativeHeader.isNotEmpty) {
          cookieHeader = nativeHeader;
        }
      } catch (_) {}

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        validateStatus: (status) => status != null && status < 500,
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36',
          'Referer': 'https://www.streetfighter.com/6/buckler/zh-hans/fighterslist/search',
          'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        },
      ));

      final List<SearchPlayerResult> results = [];

      void parseFighterList(dynamic list) {
        if (list is! List) return;
        for (final item in list) {
          if (item is! Map) continue;
          final personal = item['personal_info'] ?? item['fighter_banner_info']?['personal_info'] ?? item;
          final sid = (personal['short_id'] ?? item['short_id'] ?? '').toString();
          final fName = (personal['fighter_id'] ?? item['fighter_id'] ?? '').toString();
          if (sid.isEmpty && fName.isEmpty) continue;

          final rawChar = item['favorite_character_id'] ?? item['fighter_banner_info']?['favorite_character_id'] ?? 'luke';
          final charObj = Sf6Characters.fromCapcomId(rawChar);
          final league = item['favorite_character_league_info'] ?? item['league_info'];
          final lp = int.tryParse((league?['league_point'] ?? 0).toString()) ?? 0;
          final mr = int.tryParse((league?['master_rating'] ?? 0).toString()) ?? 0;
          final platId = (personal['platform_id'] ?? '1').toString();
          final club = (item['circle_name'] ?? item['circle']?['circle_name'] ?? item['main_circle']?['circle_name'] ?? '').toString();

          results.add(SearchPlayerResult(
            shortId: sid,
            fighterId: fName,
            mainCharacterId: charObj.id,
            lp: lp,
            mr: mr,
            platform: platId,
            clubName: club,
            sourceDescription: '官方 Buckler 全网搜索匹配',
            isOfficialNetwork: true,
          ));
        }
      }

      if (_isShortIdMode || RegExp(r'^\d{8,12}$').hasMatch(query)) {
        final sid = query.replaceAll(RegExp(r'\D'), '');
        final searchUrl = 'https://www.streetfighter.com/6/buckler/zh-hans/fighterslist/search/result?short_id=$sid&page=1';
        final res = await dio.get(searchUrl);

        if (res.statusCode == 403) {
          _networkErrorMessage = '官方登录会话已过期，请在设置中重新登录卡普空账号后再搜索。';
        } else if (res.statusCode == 200) {
          final data = NextDataParser.extractNextData(res.data.toString());
          if (data != null) {
            final pageProps = data['props']?['pageProps'];
            parseFighterList(pageProps?['fighter_banner_list']);
            parseFighterList(pageProps?['fighter_list']);
            parseFighterList(pageProps?['search_result']);
            parseFighterList(pageProps?['fighters']);
          }
        }

        // Secondary fallback: if official search list is empty, try direct profile
        if (results.isEmpty && (res.statusCode == 200 || res.statusCode == 400 || res.statusCode == 404)) {
          try {
            final profRes = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/profile/$sid');
            if (profRes.statusCode == 200) {
              final pData = NextDataParser.extractNextData(profRes.data.toString());
              if (pData != null) {
                final props = pData['props']?['pageProps'];
                final banner = props?['fighter_banner_info'] ?? props?['fighter_banner'];
                final personal = banner?['personal_info'] ?? props?['personal_info'];
                final fName = (personal?['fighter_id'] ?? props?['fighter_id'] ?? '').toString();
                if (fName.isNotEmpty) {
                  final rawChar = banner?['favorite_character_id'] ?? props?['favorite_character_id'] ?? 'luke';
                  final charObj = Sf6Characters.fromCapcomId(rawChar);
                  final league = banner?['favorite_character_league_info'] ?? props?['league_info'];
                  final lp = int.tryParse((league?['league_point'] ?? 0).toString()) ?? 0;
                  final mr = int.tryParse((league?['master_rating'] ?? 0).toString()) ?? 0;
                  final platId = (personal?['platform_id'] ?? '1').toString();
                  final club = (banner?['circle']?['circle_name'] ?? '').toString();
                  results.add(SearchPlayerResult(
                    shortId: sid,
                    fighterId: fName,
                    mainCharacterId: charObj.id,
                    lp: lp,
                    mr: mr,
                    platform: platId,
                    clubName: club,
                    sourceDescription: '官方 Buckler 实时个人主页',
                    isOfficialNetwork: true,
                  ));
                }
              }
            }
          } catch (_) {}
        }
      } else {
        final encQuery = Uri.encodeComponent(query);
        final searchUrl = 'https://www.streetfighter.com/6/buckler/zh-hans/fighterslist/search/result?fighter_id=$encQuery&page=1';
        final res = await dio.get(searchUrl);

        if (res.statusCode == 403) {
          _networkErrorMessage = '官方登录会话已过期，请在设置中重新登录卡普空账号后再搜索。';
        } else if (res.statusCode == 200) {
          final data = NextDataParser.extractNextData(res.data.toString());
          if (data != null) {
            final pageProps = data['props']?['pageProps'];
            parseFighterList(pageProps?['fighter_banner_list']);
            parseFighterList(pageProps?['fighter_list']);
            parseFighterList(pageProps?['search_result']);
            parseFighterList(pageProps?['fighters']);
            parseFighterList(pageProps?['list']);
          }
        }
      }

      if (mounted) {
        setState(() {
          _networkResults = results;
          _isSearchingNetwork = false;
          if (results.isEmpty && _networkErrorMessage.isEmpty) {
            _networkErrorMessage = '卡普空全网暂未检索到匹配的玩家，请核对 10 位数字用户码或玩家名称（确保该玩家已在 Buckler 开启公开展示）。';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        final errText = e.toString();
        String friendlyMsg = '全网搜索网络连接异常，请检查网络或稍后重试。';
        if (errText.contains('403')) {
          friendlyMsg = '官方登录会话已过期，请在设置中重新登录官方账号后再进行全网搜索。';
        } else if (errText.contains('400')) {
          friendlyMsg = '未在卡普空官方检索到匹配的玩家，请核对 10 位数字用户码是否输入正确。';
        } else if (errText.contains('503')) {
          friendlyMsg = '卡普空官方服务器正在临时维护中 (503)，请稍后再试。';
        }
        setState(() {
          _isSearchingNetwork = false;
          _networkErrorMessage = friendlyMsg;
        });
      }
    }
  }

  void _openPlayerProfile(SearchPlayerResult p) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerProfileScreen(
          shortId: p.shortId,
          fighterId: p.fighterId,
          mainCharacterId: p.mainCharacterId,
          lp: p.lp,
          mr: p.mr,
          platform: p.platform,
          clubName: p.clubName,
          authService: widget.authService,
        ),
      ),
    );
  }

  void _openInBrowserSearch(String query) {
    final enc = Uri.encodeComponent(query);
    final targetUrl = _isShortIdMode
        ? 'https://www.streetfighter.com/6/buckler/zh-hans/fighterslist/search/result?short_id=$enc&page=1'
        : 'https://www.streetfighter.com/6/buckler/zh-hans/fighterslist/search/result?fighter_id=$enc&page=1';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text('官方检索: $query'),
            backgroundColor: AppColors.bgCard,
          ),
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(targetUrl)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasInput = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('全网搜索玩家', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _searchFocusNode.hasFocus ? AppColors.accentNeonCyan : AppColors.borderSubtle,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _performNetworkSearch(),
                      decoration: InputDecoration(
                        hintText: _isShortIdMode ? '输入 10 位玩家识别码 (Short ID)' : '输入 Fighter ID 玩家昵称',
                        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                        prefixIcon: Icon(
                          _isShortIdMode ? Icons.tag : Icons.search,
                          color: _isShortIdMode ? AppColors.accentNeonYellow : AppColors.accentNeonCyan,
                          size: 20,
                        ),
                        suffixIcon: hasInput
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocusNode.requestFocus();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentNeonCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _performNetworkSearch,
                  child: _isSearchingNetwork
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('全网搜索', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Row(
            children: [
              const Text('搜索模式: ', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Fighter ID 昵称'),
                selected: !_isShortIdMode,
                onSelected: (val) {
                  setState(() => _isShortIdMode = !val);
                  _filterLocalResults(_searchController.text.trim());
                },
                selectedColor: AppColors.accentNeonCyan.withOpacity(0.2),
                backgroundColor: AppColors.bgSecondary,
                labelStyle: TextStyle(
                  color: !_isShortIdMode ? AppColors.accentNeonCyan : AppColors.textSecondary,
                  fontWeight: !_isShortIdMode ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('10 位 Short ID'),
                selected: _isShortIdMode,
                onSelected: (val) {
                  setState(() => _isShortIdMode = val);
                  _filterLocalResults(_searchController.text.trim());
                },
                selectedColor: AppColors.accentNeonYellow.withOpacity(0.2),
                backgroundColor: AppColors.bgSecondary,
                labelStyle: TextStyle(
                  color: _isShortIdMode ? AppColors.accentNeonYellow : AppColors.textSecondary,
                  fontWeight: _isShortIdMode ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!hasInput && _recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('最近搜索历史', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: const Text('清空历史', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _recentSearches.map((s) {
                return ActionChip(
                  label: Text(s),
                  backgroundColor: AppColors.bgSecondary,
                  labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                  onPressed: () {
                    _searchController.text = s;
                    _performNetworkSearch();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          if (_networkResults.isNotEmpty) ...[
            _buildSectionHeader('官方全网检索匹配 (${_networkResults.length})', AppColors.accentNeonYellow),
            const SizedBox(height: 8),
            ..._networkResults.map((r) => _buildPlayerCard(r)),
            const SizedBox(height: 16),
          ],

          if (_isSearchingNetwork) ...[
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('正在连接卡普空 Buckler 官方服务器全网匹配中...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (_networkErrorMessage.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.loseRed.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.accentNeonYellow),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _networkErrorMessage,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  if (hasInput) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_browser, size: 16, color: AppColors.accentNeonCyan),
                        label: Text('在内置浏览器中全网搜索 "${_searchController.text.trim()}"', style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accentNeonCyan),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => _openInBrowserSearch(_searchController.text.trim()),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_localResults.isNotEmpty) ...[
            _buildSectionHeader('本地好友与历史对手联想 (${_localResults.length})', AppColors.accentNeonCyan),
            const SizedBox(height: 8),
            ..._localResults.map((r) => _buildPlayerCard(r)),
            const SizedBox(height: 16),
          ] else if (hasInput && _networkResults.isEmpty && !_isSearchingNetwork && _networkErrorMessage.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.person_search, size: 40, color: AppColors.textTertiary),
                  SizedBox(height: 10),
                  Text('本地暂无匹配的记录，点击右上角 "全网搜索" 可检索官方千万玩家', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(SearchPlayerResult p) {
    final char = Sf6Characters.getById(p.mainCharacterId);
    final rank = Sf6Rank.fromLpOrMr(p.lp, mr: p.mr);
    final platformType = PlatformType.fromCode(p.platform);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: p.isOfficialNetwork ? AppColors.accentNeonYellow.withOpacity(0.5) : AppColors.borderSubtle,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openPlayerProfile(p),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CharacterAvatar(characterId: char.id, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            p.fighterId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: p.isOfficialNetwork
                                ? AppColors.accentNeonYellow.withOpacity(0.15)
                                : AppColors.accentNeonCyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            p.sourceDescription,
                            style: TextStyle(
                              color: p.isOfficialNetwork ? AppColors.accentNeonYellow : AppColors.accentNeonCyan,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: p.shortId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('已复制 Short ID: ${p.shortId}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.tag, size: 12, color: AppColors.textTertiary),
                              Text(
                                p.shortId,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.copy, size: 10, color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  ${platformType.displayName}',
                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                        ),
                        if (p.clubName.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '[${p.clubName}]',
                            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RankBadge(rank: rank, showIconOnly: false),
                        const SizedBox(width: 8),
                        Text(
                          p.mr > 0 ? '${p.mr} MR' : '${p.lp} LP',
                          style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '主力: ${char.nameZh}',
                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
