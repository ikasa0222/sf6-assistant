import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/theme/app_theme_colors.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';

class ShareBattleCard extends StatelessWidget {
  final BattleRecord record;

  const ShareBattleCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final r = record;
    final isWin = r.isWin;
    final timeStr = DateFormat('yyyy-MM-dd HH:mm').format(r.playedAt);
    final oppChar = Sf6Characters.getById(r.opponentCharacterId);
    final myChar = Sf6Characters.getById(r.playerCharacterId);

    return Container(
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWin ? colors.winGreen.withOpacity(0.5) : colors.loseRed.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isWin ? colors.winGreen : colors.loseRed).withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.accentPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'SF6',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'STREET FIGHTER 6 战报',
                    style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              Text(
                timeStr,
                style: TextStyle(color: colors.textSecondary, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: isWin ? colors.winGreen : colors.loseRed,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isWin ? colors.winGreen : colors.loseRed).withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              isWin ? 'VICTORY' : 'DEFEAT',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  CharacterAvatar(characterId: r.playerCharacterId, size: 64),
                  const SizedBox(height: 8),
                  Text(
                    myChar.nameZh,
                    style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    r.playerCurrentMr != null ? '${r.playerCurrentMr} MR' : '${r.playerCurrentLp} LP',
                    style: TextStyle(color: colors.rankMaster, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${r.playerScore} : ${r.opponentScore}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'FINAL SCORE',
                    style: TextStyle(color: colors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                children: [
                  CharacterAvatar(characterId: r.opponentCharacterId, size: 64),
                  const SizedBox(height: 8),
                  Text(
                    oppChar.nameZh,
                    style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    r.opponentFighterId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (r.replayCode.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, color: colors.accentPrimary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'REPLAY CODE: ${r.replayCode}',
                    style: TextStyle(
                      color: colors.accentPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Generated by SF6 Fighter Companion App',
            style: TextStyle(color: colors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
