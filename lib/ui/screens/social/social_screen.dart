import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/models/friend_model.dart';
import 'package:sf6_tracker/models/club_model.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';
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
  bool _filterOnlyOnline = false;
  bool _filterOnlyOnlineFriends = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (widget.authService != null && widget.battleLogService != null && widget.statsService != null) {
      await QuickSyncDialog.show(
        context,
        authService: widget.authService!,
        battleLogService: widget.battleLogService!,
        statsService: widget.statsService!,
        socialService: widget.socialService,
      );
    } else {
      await widget.socialService.loadSocialData(shortId: widget.authService?.activePlatform?.shortId);
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
            title: const Text('好友与俱乐部', style: TextStyle(fontWeight: FontWeight.bold)),
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
                Tab(text: clubs.isNotEmpty ? '战队俱乐部 (${clubs.first.clubName})' : '战队俱乐部'),
              ],
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentNeonCyan))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFriendsTab(friends),
                    _buildClubTab(clubs),
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

    final onlineFriends = friends.where((f) => f.isOnline).toList();
    final displayedFriends = _filterOnlyOnlineFriends ? onlineFriends : friends;

    return RefreshIndicator(
      color: AppColors.accentNeonCyan,
      backgroundColor: AppColors.bgCard,
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          // 顶部筛选器
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
          const SizedBox(height: 6),
          ...displayedFriends.map((friend) {
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
                  color: friend.isOnline ? statusColor.withOpacity(0.35) : AppColors.borderSubtle,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showFriendDetailModal(context, friend),
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
                              // 第 1 行：游戏名字 + 平台徽章
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
                              // 第 2 行：在线状态（在线显示在做什么，不在线显示离线）
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
                              // 第 3 行：段位与积分
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

  Widget _buildClubTab(List<ClubModel> clubs) {
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
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 56, color: AppColors.textTertiary),
                SizedBox(height: 12),
                Text(
                  '暂未加入任何俱乐部/战队',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  '在游戏内或卡普空官网加入战队后，下拉刷新或一键同步即可在此直接显示俱乐部与战友成员',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final primaryClub = clubs.first;

    return RefreshIndicator(
      color: AppColors.accentNeonCyan,
      backgroundColor: AppColors.bgCard,
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Club Main Banner Cards
          ...clubs.asMap().entries.map((entry) {
            final idx = entry.key;
            final club = entry.value;
            final isPrimary = idx == 0;

            return InkWell(
              onTap: () => _showClubDetailModal(context, club),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isPrimary ? AppColors.accentNeonPink.withOpacity(0.6) : AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: (isPrimary ? AppColors.accentNeonPink : Colors.black).withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: (isPrimary ? AppColors.accentNeonPink : AppColors.accentNeonCyan).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isPrimary ? AppColors.accentNeonPink : AppColors.accentNeonCyan, width: 1.5),
                          ),
                          child: Text(
                            '[${club.tag.isNotEmpty ? club.tag : "CLUB"}]',
                            style: TextStyle(color: isPrimary ? AppColors.accentNeonPink : AppColors.accentNeonCyan, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ),
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
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (isPrimary) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentNeonYellow.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.accentNeonYellow.withOpacity(0.6)),
                                      ),
                                      child: const Text('主战队', style: TextStyle(color: AppColors.accentNeonYellow, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '战队成员: ${club.memberCount}/${club.maxMemberCount} 人 · 状态: 活跃',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.info_outline, color: AppColors.accentNeonCyan, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Quick stats grid
                    Row(
                      children: [
                        _buildClubStatItem('总成员', '${club.memberCount} 人', AppColors.accentNeonCyan),
                        const SizedBox(width: 8),
                        _buildClubStatItem('在线状态', '活跃', AppColors.winGreen),
                        const SizedBox(width: 8),
                        _buildClubStatItem('月度积分', '${club.totalMonthlyPoints} pt', AppColors.accentNeonYellow),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.campaign, size: 16, color: AppColors.accentNeonYellow),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            club.notice.isNotEmpty ? club.notice : '欢迎加入战队交流与切磋！',
                            style: const TextStyle(color: AppColors.accentNeonYellow, fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          // 2. Club Members Section & Filter
          if (primaryClub.members.isNotEmpty) ...[
            const SizedBox(height: 12),
            // 分段切换与统计条
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _filterOnlyOnline = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_filterOnlyOnline ? AppColors.accentNeonCyan.withOpacity(0.18) : AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: !_filterOnlyOnline ? AppColors.accentNeonCyan : AppColors.borderSubtle,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '全部成员 (${primaryClub.members.length})',
                            style: TextStyle(
                              color: !_filterOnlyOnline ? AppColors.accentNeonCyan : AppColors.textSecondary,
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
                      onTap: () => setState(() => _filterOnlyOnline = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _filterOnlyOnline ? AppColors.winGreen.withOpacity(0.18) : AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _filterOnlyOnline ? AppColors.winGreen : AppColors.borderSubtle,
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
                                  color: primaryClub.members.where((m) => m.isOnline).isNotEmpty ? AppColors.winGreen : AppColors.textTertiary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '仅看在线 (${primaryClub.members.where((m) => m.isOnline).length})',
                                style: TextStyle(
                                  color: _filterOnlyOnline ? AppColors.winGreen : AppColors.textSecondary,
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
            const SizedBox(height: 6),
            ...primaryClub.members
                .where((m) => !_filterOnlyOnline || m.isOnline)
                .map((member) {
              final statusColor = member.isOnline
                  ? (member.statusText.contains('排位')
                      ? AppColors.winGreen
                      : (member.statusText.contains('格斗中心')
                          ? AppColors.accentNeonPink
                          : (member.statusText.contains('训练') || member.statusText.contains('练习')
                              ? AppColors.accentNeonYellow
                              : (member.statusText.contains('休闲')
                                  ? AppColors.accentNeonCyan
                                  : AppColors.winGreen))))
                  : AppColors.textTertiary;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: member.isOnline ? statusColor.withOpacity(0.35) : AppColors.borderSubtle,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showMemberDetailModal(context, member),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CharacterAvatar(characterId: member.mainCharacterId, size: 42),
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
                                // 第 1 行：游戏名字 + （仅限会长/副会长职务标签）
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        member.fighterId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (member.role.isNotEmpty && (member.role.contains('会长') || member.role.contains('Leader'))) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: (member.role.contains('副') ? AppColors.accentNeonPink : AppColors.accentNeonCyan).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: (member.role.contains('副') ? AppColors.accentNeonPink : AppColors.accentNeonCyan).withOpacity(0.5),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          member.role,
                                          style: TextStyle(
                                            color: member.role.contains('副') ? AppColors.accentNeonPink : AppColors.accentNeonCyan,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // 第 2 行：在线状态（不在线显示离线，在线显示具体在做什么）
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
                                            member.isOnline ? member.statusText : '离线',
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // 第 3 行：段位积分
                                if (member.lp > 0 || member.mr > 0)
                                  RankBadge(lp: member.lp, mr: member.mr, showPoints: true, scale: 0.8)
                                else
                                  const Text(
                                    '未定级  •  0 LP',
                                    style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_moon, color: AppColors.accentNeonCyan, size: 18),
                      SizedBox(width: 8),
                      Text('战队在线与状态概览', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '官方同步已成功关联你的战队档案。战队成员总数为 ${primaryClub.memberCount > 0 ? primaryClub.memberCount : primaryClub.members.length} 人。在官网个人资料或游戏中可直接发起战队切磋与语音交流。',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ],
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
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showClubDetailModal(BuildContext context, ClubModel club) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentNeonPink.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accentNeonPink),
                    ),
                    child: Text(
                      '[${club.tag.isNotEmpty ? club.tag : "CLUB"}]',
                      style: const TextStyle(color: AppColors.accentNeonPink, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(club.clubName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('战队 ID: ${club.clubId.isNotEmpty ? club.clubId : "SF6-CLUB"}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('战队公告与寄语：', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  club.notice.isNotEmpty ? club.notice : '欢迎加入战队交流与切磋！',
                  style: const TextStyle(color: AppColors.accentNeonYellow, fontSize: 12, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('战队总人数: ${club.memberCount} / ${club.maxMemberCount}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text('月度总积分: ${club.totalMonthlyPoints} pt', style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('关闭详情', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMemberDetailModal(BuildContext context, ClubMember member) {
    final char = Sf6Characters.getById(member.mainCharacterId);
    final statusColor = member.statusText.contains('排位')
        ? AppColors.winGreen
        : (member.statusText.contains('格斗中心')
            ? AppColors.accentNeonPink
            : (member.statusText.contains('训练')
                ? AppColors.accentNeonYellow
                : (member.isOnline ? AppColors.winGreen : AppColors.textTertiary)));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.accentNeonCyan, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Stack(
                  children: [
                    CharacterAvatar(characterId: member.mainCharacterId, size: 60),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bgCard, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.fighterId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: member.fighterId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已复制玩家昵称'), duration: Duration(seconds: 1)),
                              );
                            },
                            child: const Icon(Icons.copy, size: 14, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: member.role == '战队会长'
                                  ? AppColors.accentNeonPink.withOpacity(0.2)
                                  : (member.role == '副会长' ? AppColors.accentNeonYellow.withOpacity(0.2) : AppColors.bgSecondary),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              member.role,
                              style: TextStyle(
                                color: member.role == '战队会长'
                                    ? AppColors.accentNeonPink
                                    : (member.role == '副会长' ? AppColors.accentNeonYellow : AppColors.textSecondary),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ID: ${member.shortId.isNotEmpty ? member.shortId : "保密"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                            ),
                          ),
                          if (member.shortId.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: member.shortId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('已复制 Short ID: ${member.shortId} (可在游戏内加好友)'), backgroundColor: AppColors.winGreen),
                                );
                              },
                              child: const Icon(Icons.copy, size: 12, color: AppColors.textTertiary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Live Status Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: statusColor, size: 18),
                  const SizedBox(width: 8),
                  const Text('当前实时状态: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(
                    member.isOnline ? member.statusText : '离线',
                    style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Main Character & Rank
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CharacterAvatar(characterId: char.id, size: 32, showBorder: false),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('主力: ${char.nameZh}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                          Text(char.archetype, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  if (member.lp > 0 || member.mr > 0)
                    RankBadge(lp: member.lp, mr: member.mr, showPoints: true, scale: 0.85),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFriendDetailModal(BuildContext context, FriendModel friend) {
    final char = Sf6Characters.getById(friend.mainCharacterId);
    final statusColor = friend.statusText.contains('排位')
        ? AppColors.winGreen
        : (friend.statusText.contains('格斗中心')
            ? AppColors.accentNeonPink
            : (friend.statusText.contains('训练')
                ? AppColors.accentNeonYellow
                : (friend.isOnline ? AppColors.winGreen : AppColors.textTertiary)));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.accentNeonCyan, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Stack(
                  children: [
                    CharacterAvatar(characterId: friend.mainCharacterId, size: 60),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bgCard, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              friend.fighterId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: friend.fighterId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已复制玩家昵称'), duration: Duration(seconds: 1)),
                              );
                            },
                            child: const Icon(Icons.copy, size: 14, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentNeonCyan.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatPlatform(friend.platform),
                              style: const TextStyle(
                                color: AppColors.accentNeonCyan,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ID: ${friend.shortId.isNotEmpty ? friend.shortId : "保密"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                            ),
                          ),
                          if (friend.shortId.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: friend.shortId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('已复制 Short ID: ${friend.shortId} (可在游戏内加好友)'), backgroundColor: AppColors.winGreen),
                                );
                              },
                              child: const Icon(Icons.copy, size: 12, color: AppColors.textTertiary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Live Status Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: statusColor, size: 18),
                  const SizedBox(width: 8),
                  const Text('当前实时状态: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(
                    friend.isOnline ? friend.statusText : '离线',
                    style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Main Character & Rank
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CharacterAvatar(characterId: char.id, size: 32, showBorder: false),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('主力: ${char.nameZh}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                          Text(char.archetype, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  if (friend.lp > 0 || friend.mr > 0)
                    RankBadge(lp: friend.lp, mr: friend.mr, showPoints: true, scale: 0.85),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
