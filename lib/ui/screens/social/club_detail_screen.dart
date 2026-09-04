import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/constants/ranks.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/models/club_model.dart';
import 'package:sf6_tracker/models/friend_model.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/ui/screens/social/player_profile_screen.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/rank_badge.dart';

class ClubDetailScreen extends StatefulWidget {
  final ClubModel club;
  final AuthService authService;
  final BattleLogService? battleLogService;

  const ClubDetailScreen({
    super.key,
    required this.club,
    required this.authService,
    this.battleLogService,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _onlyOnline = false;
  List<String> _followedIds = [];
  List<FriendModel> _followedPlayers = [];

  @override
  void initState() {
    super.initState();
    _loadFollowed();
  }

  Future<void> _loadFollowed() async {
    final ids = await StorageService.instance.getFollowedShortIds();
    final players = await StorageService.instance.getFollowedPlayers();
    if (mounted) {
      setState(() {
        _followedIds = ids;
        _followedPlayers = players;
      });
    }
  }

  bool _isMemberFollowed(ClubMember m) {
    final sId = m.shortId.trim();
    final fId = m.fighterId.trim().toLowerCase();
    if (sId.isNotEmpty && _followedIds.contains(sId)) return true;
    for (final p in _followedPlayers) {
      if (sId.isNotEmpty && p.shortId.trim() == sId) return true;
      if (fId.isNotEmpty && p.fighterId.trim().toLowerCase() == fId) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;

    // Filter members
    var members = club.members.where((m) {
      if (_onlyOnline && !m.isOnline) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = m.fighterId.toLowerCase().contains(q);
        final matchesId = m.shortId.toLowerCase().contains(q);
        return matchesName || matchesId;
      }
      return true;
    }).toList();

    // Sort: Followed strictly first, then online, then points/name
    members.sort((a, b) {
      final aFollow = _isMemberFollowed(a);
      final bFollow = _isMemberFollowed(b);
      if (aFollow && !bFollow) return -1;
      if (!aFollow && bFollow) return 1;

      if (a.isOnline && !b.isOnline) return -1;
      if (!a.isOnline && b.isOnline) return 1;

      return b.lp.compareTo(a.lp);
    });

    final onlineCount = club.members.where((m) => m.isOnline).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '[${club.tag.isNotEmpty ? club.tag : "CLUB"}] ${club.clubName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          if (club.isMainClub)
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentNeonYellow.withOpacity(0.18),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.accentNeonYellow, width: 0.8),
              ),
              child: const Center(
                child: Text(
                  '主战队',
                  style: TextStyle(color: AppColors.accentNeonYellow, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Online Switcher
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: AppColors.bgSecondary.withOpacity(0.5),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '搜索成员昵称或 Short ID...',
                    hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16, color: AppColors.textTertiary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.bgCard,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.accentNeonCyan),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      label: Text('全部成员 (${club.members.length})'),
                      selected: !_onlyOnline,
                      onSelected: (_) => setState(() => _onlyOnline = false),
                      selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                      backgroundColor: AppColors.bgCard,
                      labelStyle: TextStyle(
                        color: !_onlyOnline ? AppColors.accentNeonCyan : AppColors.textSecondary,
                        fontWeight: !_onlyOnline ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text('仅看在线 ($onlineCount)'),
                      selected: _onlyOnline,
                      onSelected: (_) => setState(() => _onlyOnline = true),
                      selectedColor: AppColors.winGreen.withOpacity(0.25),
                      backgroundColor: AppColors.bgCard,
                      labelStyle: TextStyle(
                        color: _onlyOnline ? AppColors.winGreen : AppColors.textSecondary,
                        fontWeight: _onlyOnline ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Members List
          Expanded(
            child: members.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty ? '未找到符合条件的成员' : '战队暂无成员数据',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final m = members[idx];
                      final char = Sf6Characters.getById(m.mainCharacterId);
                      final rank = Sf6Rank.fromLpOrMr(m.lp, mr: m.mr);
                      final isLeader = m.role.contains('会') || m.shortId == club.leaderShortId;
                      final isFollowed = _isMemberFollowed(m);

                      return InkWell(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlayerProfileScreen(
                                shortId: m.shortId,
                                fighterId: m.fighterId,
                                mainCharacterId: m.mainCharacterId,
                                lp: m.lp,
                                mr: m.mr,
                                platform: m.platform,
                                isOnline: m.isOnline,
                                statusText: m.statusText,
                                battleHubServer: m.battleHubServer,
                                clubName: club.clubName,
                                clubRole: m.role,
                                authService: widget.authService,
                              ),
                            ),
                          );
                          _loadFollowed();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isFollowed
                                  ? AppColors.accentNeonYellow.withOpacity(0.6)
                                  : (m.isOnline ? AppColors.accentNeonCyan.withOpacity(0.3) : AppColors.borderSubtle),
                              width: isFollowed ? 1.4 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              CharacterAvatar(characterId: m.mainCharacterId, size: 40),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            m.fighterId.isNotEmpty ? m.fighterId : '格斗家_${m.shortId}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (isFollowed) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.star, size: 14, color: AppColors.accentNeonYellow),
                                        ],
                                        if (isLeader) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentNeonYellow.withOpacity(0.18),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              m.role.isNotEmpty ? m.role : '会长',
                                              style: const TextStyle(color: AppColors.accentNeonYellow, fontSize: 9.5, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: m.isOnline ? AppColors.winGreen : AppColors.textTertiary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          m.statusText,
                                          style: TextStyle(
                                            color: m.isOnline ? AppColors.winGreen : AppColors.textTertiary,
                                            fontSize: 10.5,
                                            fontWeight: m.isOnline ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          char.nameZh,
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  RankBadge(rank: rank, showIconOnly: false),
                                  const SizedBox(height: 2),
                                  Text(
                                    m.mr > 0 ? '${m.mr} MR' : '${m.lp} LP',
                                    style: const TextStyle(
                                      color: AppColors.accentNeonCyan,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: Icon(
                                  isFollowed ? Icons.star : Icons.star_border,
                                  color: isFollowed ? AppColors.accentNeonYellow : AppColors.textTertiary,
                                  size: 20,
                                ),
                                tooltip: isFollowed ? '取消特别关注' : '特别关注 (置顶并在好友列表中显示)',
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                onPressed: () async {
                                  final friend = FriendModel(
                                    shortId: m.shortId,
                                    fighterId: m.fighterId,
                                    avatarUrl: m.avatarUrl,
                                    platform: m.platform,
                                    isOnline: m.isOnline,
                                    statusText: m.statusText,
                                    mainCharacterId: m.mainCharacterId,
                                    lp: m.lp,
                                    mr: m.mr,
                                    lastSeen: DateTime.now(),
                                  );
                                  final nowFollowed = await StorageService.instance.toggleFollowPlayer(friend);
                                  await _loadFollowed();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(nowFollowed
                                            ? '已关注 ${m.fighterId.isNotEmpty ? m.fighterId : "成员"}，将在俱乐部与好友列表置顶展示'
                                            : '已取消关注 ${m.fighterId.isNotEmpty ? m.fighterId : "成员"}'),
                                        backgroundColor: nowFollowed ? AppColors.winGreen : AppColors.bgSecondary,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                              const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
