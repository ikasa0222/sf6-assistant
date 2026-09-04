import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/models/friend_model.dart';
import 'package:sf6_tracker/models/club_model.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';
import 'package:sf6_tracker/ui/screens/social/club_detail_screen.dart';
import 'package:sf6_tracker/ui/screens/social/player_profile_screen.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/quick_sync_dialog.dart';
import 'package:sf6_tracker/ui/widgets/rank_badge.dart';

class SocialScreen extends StatefulWidget {
  final SocialService socialService;
  final AuthService? authService;
  final BattleLogService? battleLogService;
  final StatsService? statsService;

  const SocialScreen({
    super.key,
    required this.socialService,
    this.authService,
    this.battleLogService,
    this.statsService,
  });

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _filterOnlyOnlineFriends = false;
  List<String> _followedIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFollowed();
  }

  Future<void> _loadFollowed() async {
    final list = await StorageService.instance.getFollowedShortIds();
    if (mounted) {
      setState(() => _followedIds = list);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (widget.battleLogService?.isBackgroundSyncing == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在自动更新数据中，请稍候...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (widget.authService != null && widget.battleLogService != null && widget.statsService != null) {
      await QuickSyncDialog.show(
        context,
        authService: widget.authService!,
        battleLogService: widget.battleLogService!,
        statsService: widget.statsService!,
        socialService: widget.socialService,
      );
      _loadFollowed();
    } else {
      await widget.socialService.loadSocialData(shortId: widget.authService?.activePlatform?.shortId);
      _loadFollowed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.socialService,
      builder: (context, _) {
        final friends = widget.socialService.friends;
        final clubs = widget.socialService.clubs;
        final isLoading = widget.socialService.isLoading;
        final onlineFriends = widget.socialService.onlineFriendsCount;

        return Scaffold(
          appBar: AppBar(
            title: const Text('好友与战队', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                tooltip: '同步刷新社交数据',
                icon: const Icon(Icons.sync, color: AppColors.accentNeonCyan),
                onPressed: _handleRefresh,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accentNeonCyan,
              labelColor: AppColors.accentNeonCyan,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Tab(text: '好友列表 ($onlineFriends 在线)'),
                Tab(
                  text: clubs.isNotEmpty
                      ? (clubs.length > 1
                          ? '战队俱乐部 (${clubs.length})'
                          : '战队俱乐部 (${clubs.first.clubName})')
                      : '战队俱乐部',
                ),
              ],
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentNeonCyan))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFriendsTab(friends),
                    _buildClubsTab(clubs),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFriendsTab(List<FriendModel> friends) {
    if (friends.isEmpty) {
      return RefreshIndicator(
        color: AppColors.accentNeonCyan,
        backgroundColor: AppColors.bgCard,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 56, color: AppColors.textTertiary),
                SizedBox(height: 12),
                Text(
                  '暂无已同步的好友',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  '在卡普空官方关注好友后，下拉刷新或一键同步即可在此直接查看好友在线状态与段位',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sortedFriends = List<FriendModel>.from(friends);
    sortedFriends.sort((a, b) {
      final aFollowed = _followedIds.contains(a.shortId);
      final bFollowed = _followedIds.contains(b.shortId);
      if (aFollowed && !bFollowed) return -1;
      if (!aFollowed && bFollowed) return 1;
      if (a.isOnline && !b.isOnline) return -1;
      if (!a.isOnline && b.isOnline) return 1;
      return a.fighterId.compareTo(b.fighterId);
    });

    final onlineFriends = sortedFriends.where((f) => f.isOnline).toList();
    final displayedFriends = _filterOnlyOnlineFriends ? onlineFriends : sortedFriends;

    return RefreshIndicator(
      color: AppColors.accentNeonCyan,
      backgroundColor: AppColors.bgCard,
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _filterOnlyOnlineFriends = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_filterOnlyOnlineFriends ? AppColors.accentNeonCyan.withOpacity(0.18) : AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !_filterOnlyOnlineFriends ? AppColors.accentNeonCyan : AppColors.borderSubtle,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '全部好友 (${friends.length})',
                          style: TextStyle(
                            color: !_filterOnlyOnlineFriends ? AppColors.accentNeonCyan : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _filterOnlyOnlineFriends = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _filterOnlyOnlineFriends ? AppColors.winGreen.withOpacity(0.18) : AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _filterOnlyOnlineFriends ? AppColors.winGreen : AppColors.borderSubtle,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: onlineFriends.isNotEmpty ? AppColors.winGreen : AppColors.textTertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '仅看在线 (${onlineFriends.length})',
                              style: TextStyle(
                                color: _filterOnlyOnlineFriends ? AppColors.winGreen : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...displayedFriends.map((friend) {
            final isFollowed = _followedIds.contains(friend.shortId);
            final statusColor = friend.isOnline
                ? (friend.statusText.contains('排位')
                    ? AppColors.winGreen
                    : (friend.statusText.contains('格斗中心')
                        ? AppColors.accentNeonPink
                        : (friend.statusText.contains('训练') || friend.statusText.contains('练习')
                            ? AppColors.accentNeonYellow
                            : (friend.statusText.contains('休闲')
                                ? AppColors.accentNeonCyan
                                : AppColors.winGreen))))
                : AppColors.textTertiary;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFollowed
                      ? AppColors.accentNeonYellow.withOpacity(0.65)
                      : (friend.isOnline ? statusColor.withOpacity(0.35) : AppColors.borderSubtle),
                  width: isFollowed ? 1.4 : 1.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerProfileScreen(
                          shortId: friend.shortId,
                          fighterId: friend.fighterId,
                          mainCharacterId: friend.mainCharacterId,
                          lp: friend.lp,
                          mr: friend.mr,
                          platform: friend.platform,
                          isOnline: friend.isOnline,
                          statusText: friend.statusText,
                          authService: widget.authService,
                        ),
                      ),
                    ).then((_) => _loadFollowed());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            CharacterAvatar(characterId: friend.mainCharacterId, size: 42),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.bgCard, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Line 1: Fighter Name + Star + Platform
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      friend.fighterId,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isFollowed) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.star, size: 14, color: AppColors.accentNeonYellow),
                                  ],
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgSecondary,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      _formatPlatform(friend.platform),
                                      style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Line 2: Status + Character Name
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          friend.isOnline ? friend.statusText : '离线',
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    Sf6Characters.getById(friend.mainCharacterId).nameZh,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Line 3: Rank & LP/MR
                              if (friend.lp > 0 || friend.mr > 0)
                                RankBadge(lp: friend.lp, mr: friend.mr, showPoints: true, scale: 0.8)
                              else
                                const Text(
                                  '未定级  •  0 LP',
                                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildClubsTab(List<ClubModel> clubs) {
    if (clubs.isEmpty) {
      return RefreshIndicator(
        color: AppColors.accentNeonCyan,
        backgroundColor: AppColors.bgCard,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 56, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                const Text(
                  '暂未加入任何战队俱乐部',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                const Text(
                  '在卡普空官方加入战队后，点击下方一键同步即可直接在此显示战队与成员列表',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan, foregroundColor: Colors.black),
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('一键同步战队信息', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _handleRefresh,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accentNeonCyan,
      backgroundColor: AppColors.bgCard,
      onRefresh: _handleRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: clubs.length,
        itemBuilder: (context, index) {
          final club = clubs[index];
          final isPrimary = club.isMainClub || (index == 0 && !clubs.any((c) => c.isMainClub));
          final onlineMembersCount = club.members.where((m) => m.isOnline).length;
          final displayOnline = onlineMembersCount > 0 ? onlineMembersCount : club.onlineMemberCount;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPrimary ? AppColors.accentNeonPink.withOpacity(0.5) : AppColors.borderSubtle,
                width: isPrimary ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isPrimary ? AppColors.accentNeonPink : Colors.black).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (widget.authService != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClubDetailScreen(
                          club: club,
                          authService: widget.authService!,
                          battleLogService: widget.battleLogService,
                        ),
                      ),
                    ).then((_) => _loadFollowed());
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Emblem + Name + Main Club Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (club.emblemUrl.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.bgSecondary,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isPrimary ? AppColors.accentNeonPink : AppColors.accentNeonCyan,
                                    width: 1.5,
                                  ),
                                ),
                                child: Image.network(
                                  club.emblemUrl,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildClubTagBadge(club, isPrimary),
                                ),
                              ),
                            ),
                          ] else ...[
                            _buildClubTagBadge(club, isPrimary),
                          ],
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        club.clubName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (isPrimary) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentNeonYellow.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.accentNeonYellow.withOpacity(0.6)),
                                        ),
                                        child: const Text(
                                          '主战队',
                                          style: TextStyle(
                                            color: AppColors.accentNeonYellow,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentNeonCyan.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.accentNeonCyan.withOpacity(0.5)),
                                        ),
                                        child: Text(
                                          '战队 ${index + 1}',
                                          style: const TextStyle(
                                            color: AppColors.accentNeonCyan,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '[${club.tag.isNotEmpty ? club.tag : "CLUB"}]  •  ID: ${club.clubId.isNotEmpty ? club.clubId : "保密"}',
                                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.accentNeonCyan, size: 22),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Leader row - separated line to prevent overflow
                      if (club.leaderFighterId.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.stars, size: 14, color: AppColors.accentNeonYellow),
                            const SizedBox(width: 5),
                            const Text('会长: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            Expanded(
                              child: Text(
                                club.leaderFighterId,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.accentNeonYellow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Stats row
                      Row(
                        children: [
                          _buildClubStatItem('总成员', '${club.memberCount}/${club.maxMemberCount} 人', AppColors.accentNeonCyan),
                          const SizedBox(width: 8),
                          _buildClubStatItem('在线活跃', '$displayOnline 人在线', displayOnline > 0 ? AppColors.winGreen : AppColors.textTertiary),
                          const SizedBox(width: 8),
                          _buildClubStatItem('月度积分', '${club.totalMonthlyPoints} pt', AppColors.accentNeonYellow),
                        ],
                      ),

                      // Tags
                      if (club.tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: club.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.bgSecondary,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Text(
                                '# $tag',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // Notice
                      if (club.notice.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.bgSecondary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.campaign, size: 14, color: AppColors.accentNeonYellow),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  club.notice,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '点击进入二级页面查看完整成员列表与切磋',
                            style: TextStyle(color: AppColors.accentNeonCyan, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          Icon(Icons.arrow_forward, size: 13, color: AppColors.accentNeonCyan),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClubTagBadge(ClubModel club, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: (isPrimary ? AppColors.accentNeonPink : AppColors.accentNeonCyan).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isPrimary ? AppColors.accentNeonPink : AppColors.accentNeonCyan, width: 1.5),
      ),
      child: Text(
        '[${club.tag.isNotEmpty ? club.tag : "CLUB"}]',
        style: TextStyle(
          color: isPrimary ? AppColors.accentNeonPink : AppColors.accentNeonCyan,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildClubStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPlatform(String p) {
    final lower = p.toLowerCase();
    if (lower.contains('switch')) return 'Switch';
    if (lower.contains('steam')) return 'Steam';
    if (lower.contains('ps5') || lower.contains('playstation_5')) return 'PS5';
    if (lower.contains('ps4') || lower.contains('playstation_4')) return 'PS4';
    if (lower.contains('xbox')) return 'Xbox';
    if (lower.contains('cross')) return '跨平台';
    return lower.length > 5 ? lower.substring(0, 5).toUpperCase() : lower.toUpperCase();
  }
}
