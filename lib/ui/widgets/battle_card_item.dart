import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/share_battle_card.dart';
import 'package:sf6_tracker/ui/widgets/share_battle_dialog.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/ui/screens/social/player_profile_screen.dart';

class BattleCardItem extends StatefulWidget {
  final BattleRecord record;
  final VoidCallback? onShare;
  final VoidCallback? onAddNote;
  final AuthService? authService;
  final bool isEmbedded;
  final bool showViewProfileButton;
  final EdgeInsetsGeometry? customMargin;

  const BattleCardItem({
    super.key,
    required this.record,
    this.onShare,
    this.onAddNote,
    this.authService,
    this.isEmbedded = false,
    this.showViewProfileButton = true,
    this.customMargin,
  });

  @override
  State<BattleCardItem> createState() => _BattleCardItemState();
}

class _BattleCardItemState extends State<BattleCardItem> {
  bool _isExpanded = false;

  void _showShareDialog(BuildContext context, BattleRecord record) {
    ShareBattleDialog.show(context, record);
  }

  String _formatPlatform(String raw) {
    return PlatformType.formatPlatformBadge(raw);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final isWin = r.isWin;
    final oppChar = Sf6Characters.getById(r.opponentCharacterId);

    final defaultMargin = widget.isEmbedded
        ? const EdgeInsets.symmetric(horizontal: 0, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 6);
    final cardColor = widget.isEmbedded ? AppColors.bgSecondary : AppColors.bgCard;

    return Container(
      margin: widget.customMargin ?? defaultMargin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWin ? AppColors.winGreen.withOpacity(0.35) : AppColors.loseRed.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isWin ? AppColors.winGreen : AppColors.loseRed,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    children: [
                      CharacterAvatar(characterId: r.playerCharacterId, size: 40),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: r.playerControlType == 'M' ? AppColors.accentNeonYellow : AppColors.accentNeonCyan,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            r.playerControlType,
                            style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isWin ? AppColors.winGreen : AppColors.loseRed).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isWin ? 'WIN' : 'LOSE',
                          style: TextStyle(
                            color: isWin ? AppColors.winGreen : AppColors.loseRed,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${r.playerScore} - ${r.opponentScore}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      CharacterAvatar(characterId: r.opponentCharacterId, size: 40),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: r.opponentControlType == 'M' ? AppColors.accentNeonYellow : AppColors.accentNeonCyan,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            r.opponentControlType,
                            style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
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
                        Text(
                          r.opponentFighterId.isNotEmpty ? r.opponentFighterId : '未知对手',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              oppChar.nameZh,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (r.opponentMr != null && r.opponentMr! > 0)
                              Text(
                                '${r.opponentMr} MR',
                                style: const TextStyle(
                                  color: AppColors.rankMaster,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 54),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (r.playerMrChange != 0)
                          Text(
                            '${r.playerMrChange > 0 ? '+' : ''}${r.playerMrChange} MR',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: r.playerMrChange > 0 ? AppColors.winGreen : AppColors.loseRed,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else if (r.playerLpChange != 0)
                          Text(
                            '${r.playerLpChange > 0 ? '+' : ''}${r.playerLpChange} LP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: r.playerLpChange > 0 ? AppColors.winGreen : AppColors.loseRed,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MM-dd').format(r.playedAt),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(r.playedAt),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '模式: ${r.battleType.displayName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          '对手平台: ${_formatPlatform(r.opponentPlatform)}',
                          style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (r.opponentShortId.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: r.opponentShortId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('已复制对手 Short ID: ${r.opponentShortId}'),
                                    backgroundColor: AppColors.winGreen,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.tag, size: 14, color: AppColors.accentNeonYellow),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Short ID: ${r.opponentShortId}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.copy, size: 12, color: AppColors.textTertiary),
                                ],
                              ),
                            ),
                          ),
                          if (widget.showViewProfileButton && !widget.isEmbedded && r.opponentShortId.isNotEmpty)
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PlayerProfileScreen(
                                      shortId: r.opponentShortId,
                                      fighterId: r.opponentFighterId,
                                      mainCharacterId: r.opponentCharacterId,
                                      lp: r.opponentLp ?? 0,
                                      mr: r.opponentMr ?? 0,
                                      platform: r.opponentPlatform,
                                      authService: widget.authService,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentNeonCyan.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.accentNeonCyan.withOpacity(0.6)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_search, size: 13, color: AppColors.accentNeonCyan),
                                    SizedBox(width: 4),
                                    Text(
                                      '查看对方资料',
                                      style: TextStyle(
                                        color: AppColors.accentNeonCyan,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (r.rounds.isNotEmpty) ...[
                    const Text(
                      '回合详情 (Round Breakdown)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: r.rounds.map((round) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.bgSecondary,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: round.isPlayerWin ? AppColors.winGreen.withOpacity(0.4) : AppColors.loseRed.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'R${round.roundNum}: ',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              Text(
                                round.isPlayerWin ? '胜' : '负',
                                style: TextStyle(
                                  color: round.isPlayerWin ? AppColors.winGreen : AppColors.loseRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${round.finishType.displayName})',
                                style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.bgInput,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.videocam, size: 14, color: AppColors.accentNeonCyan),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  r.replayCode.isNotEmpty ? r.replayCode : '无录像代码',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              if (r.replayCode.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: r.replayCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已复制对战录像代码到剪贴板！'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(Icons.copy, size: 14, color: AppColors.accentNeonCyan),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.share, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.bgSecondary,
                          foregroundColor: AppColors.accentNeonCyan,
                        ),
                        onPressed: widget.onShare ?? () => _showShareDialog(context, r),
                        tooltip: '生成战报长图',
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.edit_note, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.bgSecondary,
                          foregroundColor: AppColors.accentNeonYellow,
                        ),
                        onPressed: widget.onAddNote,
                        tooltip: '添加对战笔记',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
