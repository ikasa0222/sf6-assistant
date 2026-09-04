import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/core/network/next_data_parser.dart';
import 'package:sf6_tracker/core/storage/database_helper.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/rank_badge.dart';

class PlayerProfileScreen extends StatefulWidget {
  final String shortId;
  final String fighterId;
  final String mainCharacterId;
  final int lp;
  final int mr;
  final String platform;
  final bool isOnline;
  final String statusText;
  final String battleHubServer;
  final String clubName;
  final String clubRole;
  final AuthService? authService;

  const PlayerProfileScreen({
    super.key,
    required this.shortId,
    required this.fighterId,
    required this.mainCharacterId,
    required this.lp,
    this.mr = 0,
    required this.platform,
    this.isOnline = false,
    this.statusText = '离线',
    this.battleHubServer = '',
    this.clubName = '',
    this.clubRole = '',
    this.authService,
  });

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  bool _isFollowed = false;
  bool _isLoadingHeadToHead = true;
  List<BattleRecord> _headToHeadRecords = [];

  // Public match history tab
  int _selectedTab = 0; // 0: 与我交手, 1: 近期全网对局
  bool _isLoadingPublicReplays = false;
  bool _publicReplaysLoaded = false;
  List<dynamic> _publicReplays = [];
  String _publicReplaysError = '';

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
    _loadHeadToHeadRecords();
  }

  Future<void> _checkFollowStatus() async {
    final followed = await StorageService.instance.isFollowing(widget.shortId);
    if (mounted) setState(() => _isFollowed = followed);
  }

  Future<void> _toggleFollow() async {
    HapticFeedback.lightImpact();
    final nowFollowed = await StorageService.instance.toggleFollow(widget.shortId);
    if (!mounted) return;
    setState(() => _isFollowed = nowFollowed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nowFollowed ? '已添加特别关注，将置顶显示在好友列表中' : '已取消特别关注'),
        backgroundColor: nowFollowed ? AppColors.winGreen : AppColors.bgSecondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadHeadToHeadRecords() async {
    setState(() => _isLoadingHeadToHead = true);
    final myPlatform = widget.authService?.activePlatform?.platformType.code ?? widget.platform;
    final allRecords = await DatabaseHelper.instance.getBattleRecords(
      shortId: widget.authService?.activePlatform?.shortId ?? '',
      platform: myPlatform,
      limit: 500,
    );

    final filtered = allRecords.where((r) {
      final sId = r.opponentShortId.trim();
      final fId = r.opponentFighterId.trim().toLowerCase();
      return (sId.isNotEmpty && sId == widget.shortId.trim()) ||
          (widget.fighterId.isNotEmpty && fId == widget.fighterId.trim().toLowerCase());
    }).toList();

    if (mounted) {
      setState(() {
        _headToHeadRecords = filtered;
        _isLoadingHeadToHead = false;
      });
    }
  }

  Future<void> _fetchPublicReplays() async {
    if (_isLoadingPublicReplays || _publicReplaysLoaded) return;
    setState(() {
      _isLoadingPublicReplays = true;
      _publicReplaysError = '';
    });

    try {
      final cookieManager = CookieManager.instance();
      final cookies = await cookieManager.getCookies(url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/'));
      final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
          'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        },
      ));

      final res = await dio.get('https://www.streetfighter.com/6/buckler/zh-hans/profile/${widget.shortId}/battlelog?page=1');
      final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(res.data.toString());
      if (m != null) {
        final data = NextDataParser.extractNextData(res.data.toString());
        if (data != null) {
          final parsed = NextDataParser.parseBattleLog(
            data,
            userShortId: widget.shortId,
            platform: widget.platform,
          );
          if (mounted) {
            setState(() {
              _publicReplays = parsed;
              _publicReplaysLoaded = true;
              _isLoadingPublicReplays = false;
            });
            return;
          }
        }
      }
      if (mounted) {
        setState(() {
          _publicReplaysLoaded = true;
          _isLoadingPublicReplays = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _publicReplaysError = '该玩家未公开全网对局或网络连接受限';
          _isLoadingPublicReplays = false;
          _publicReplaysLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rank = Sf6Rank.fromLpOrMr(widget.lp, mr: widget.mr);
    final char = Sf6Characters.getById(widget.mainCharacterId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('格斗家个人资料', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(
              _isFollowed ? Icons.star : Icons.star_border,
              color: _isFollowed ? AppColors.accentNeonYellow : AppColors.textSecondary,
              size: 24,
            ),
            tooltip: _isFollowed ? '取消特别关注' : '特别关注 (置顶好友列表)',
            onPressed: _toggleFollow,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Card
            _buildHeroCard(rank, char),
            const SizedBox(height: 14),

            // 2. Head-to-Head & Match History Module with Segmented Switcher
            _buildMatchHistorySection(),
            const SizedBox(height: 16),

            // 3. Quick Action Buttons
            _buildQuickActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(Sf6Rank rank, Sf6Character char) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFollowed ? AppColors.accentNeonYellow.withOpacity(0.6) : AppColors.borderSubtle,
          width: _isFollowed ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CharacterAvatar(characterId: widget.mainCharacterId, size: 62),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.fighterId.isNotEmpty ? widget.fighterId : '格斗家_${widget.shortId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (_isFollowed) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentNeonYellow.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.accentNeonYellow, width: 0.8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: AppColors.accentNeonYellow, size: 12),
                                SizedBox(width: 3),
                                Text('特别关注', style: TextStyle(color: AppColors.accentNeonYellow, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Short ID: ${widget.shortId}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 12, fontFamily: 'monospace')),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: widget.shortId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已复制 Short ID'), duration: Duration(seconds: 1)),
                            );
                          },
                          child: const Icon(Icons.copy, size: 13, color: AppColors.accentNeonCyan),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.bgSecondary,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            widget.platform.toUpperCase(),
                            style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (widget.clubName.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.accentNeonPink.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.accentNeonPink.withOpacity(0.5)),
                            ),
                            child: Text(
                              '[${widget.clubName}] ${widget.clubRole.isNotEmpty ? widget.clubRole : "成员"}',
                              style: const TextStyle(color: AppColors.accentNeonPink, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),

          // Online status & Rank row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.isOnline ? AppColors.winGreen : AppColors.textTertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.statusText + (widget.battleHubServer.isNotEmpty ? ' (${widget.battleHubServer})' : ''),
                    style: TextStyle(
                      color: widget.isOnline ? AppColors.winGreen : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: widget.isOnline ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              RankBadge(rank: rank, showIconOnly: false),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('主力角色: ${char.nameZh}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(
                widget.mr > 0 ? '${widget.mr} MR' : '${widget.lp} LP',
                style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHistorySection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Switcher
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Center(child: Text('与我交手 (${_headToHeadRecords.length}场)')),
                    selected: _selectedTab == 0,
                    onSelected: (_) => setState(() => _selectedTab = 0),
                    selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                    backgroundColor: AppColors.bgSecondary,
                    labelStyle: TextStyle(
                      color: _selectedTab == 0 ? AppColors.accentNeonCyan : AppColors.textSecondary,
                      fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('近期全网对局')),
                    selected: _selectedTab == 1,
                    onSelected: (_) {
                      setState(() => _selectedTab = 1);
                      if (!_publicReplaysLoaded) _fetchPublicReplays();
                    },
                    selectedColor: AppColors.accentNeonYellow.withOpacity(0.25),
                    backgroundColor: AppColors.bgSecondary,
                    labelStyle: TextStyle(
                      color: _selectedTab == 1 ? AppColors.accentNeonYellow : AppColors.textSecondary,
                      fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content body
          Padding(
            padding: const EdgeInsets.all(14),
            child: _selectedTab == 0 ? _buildHeadToHeadContent() : _buildPublicReplaysContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadToHeadContent() {
    if (_isLoadingHeadToHead) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_headToHeadRecords.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.history_toggle_off, color: AppColors.textTertiary, size: 36),
              SizedBox(height: 8),
              Text('暂无交手记录', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
              SizedBox(height: 4),
              Text('在排位赛或格斗中心切磋对局后将自动汇总', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
        ),
      );
    }

    final wins = _headToHeadRecords.where((r) => r.isWin).length;
    final total = _headToHeadRecords.length;
    final losses = total - wins;
    final winRate = total > 0 ? (wins / total * 100).toStringAsFixed(1) : '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary bar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('历史战绩', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text('$wins胜 - $losses负', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Column(
                children: [
                  const Text('我方胜率', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(
                    '$winRate%',
                    style: TextStyle(
                      color: double.parse(winRate) >= 50 ? AppColors.winGreen : AppColors.loseRed,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('交手总数', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text('$total 场', style: const TextStyle(color: AppColors.accentNeonCyan, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Recent matches list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _headToHeadRecords.take(15).length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final rec = _headToHeadRecords[idx];
            final myChar = Sf6Characters.getById(rec.playerCharacterId);
            final oppChar = Sf6Characters.getById(rec.opponentCharacterId);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: rec.isWin ? AppColors.winGreen.withOpacity(0.3) : AppColors.loseRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: rec.isWin ? AppColors.winGreen : AppColors.loseRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        rec.isWin ? '胜' : '负',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CharacterAvatar(characterId: myChar.id, size: 28),
                  const SizedBox(width: 6),
                  const Text('VS', style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  CharacterAvatar(characterId: oppChar.id, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${myChar.nameZh} 对阵 ${oppChar.nameZh}',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          rec.battleType.displayName,
                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${rec.playerScore} - ${rec.opponentScore}',
                    style: TextStyle(
                      color: rec.isWin ? AppColors.winGreen : AppColors.loseRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPublicReplaysContent() {
    if (_isLoadingPublicReplays) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('正在拉取该玩家官方近期公开对局...', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (_publicReplaysError.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const Icon(Icons.lock_outline, color: AppColors.textTertiary, size: 36),
              SizedBox(height: 8),
              Text(_publicReplaysError, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (_publicReplays.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text('暂无官方公开战绩', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _publicReplays.take(10).length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final item = _publicReplays[idx];
        final bool isWin = item['is_win'] == true || item['win'] == true;
        final oppName = item['opponent_name'] ?? item['opp_name'] ?? '格斗家';
        final oppCharName = item['opponent_character_name'] ?? item['opp_character'] ?? '';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isWin ? AppColors.winGreen : AppColors.loseRed).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isWin ? '获胜' : '战败',
                  style: TextStyle(color: isWin ? AppColors.winGreen : AppColors.loseRed, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '对阵 $oppName ${oppCharName.isNotEmpty ? "($oppCharName)" : ""}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.language, size: 16),
            label: const Text('在内置浏览器查看官方 Buckler 主页', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentNeonCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text('${widget.fighterId} 的官方主页')),
                    body: InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri('https://www.streetfighter.com/6/buckler/zh-hans/profile/${widget.shortId}'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 14, color: AppColors.textSecondary),
                label: const Text('复制 Short ID', style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.shortId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制 Short ID'), duration: Duration(seconds: 1)),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.badge, size: 14, color: AppColors.textSecondary),
                label: const Text('复制玩家昵称', style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.fighterId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制玩家昵称'), duration: Duration(seconds: 1)),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
