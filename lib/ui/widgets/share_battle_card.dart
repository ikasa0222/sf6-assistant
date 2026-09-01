import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';

class ShareBattleCard extends StatelessWidget {
  final BattleRecord record;

  const ShareBattleCard({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final r = record;
    final isWin = r.isWin;
    final timeStr = DateFormat('yyyy-MM-dd HH:mm').format(r.playedAt);
    final oppChar = Sf6Characters.getById(r.opponentCharacterId);
    final myChar = Sf6Characters.getById(r.playerCharacterId);

    return Container(
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWin ? AppColors.winGreen.withOpacity(0.5) : AppColors.loseRed.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isWin ? AppColors.winGreen : AppColors.loseRed).withOpacity(0.15),
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
                      color: AppColors.accentNeonPink,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'SF6',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'STREET FIGHTER 6 战报',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              Text(
                timeStr,
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: isWin ? AppColors.winGreen : AppColors.loseRed,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isWin ? AppColors.winGreen : AppColors.loseRed).withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              isWin ? 'VICTORY' : 'DEFEAT',
              style: const TextStyle(
                color: Colors.black,
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
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    r.playerCurrentMr != null ? '${r.playerCurrentMr} MR' : '${r.playerCurrentLp} LP',
                    style: const TextStyle(color: AppColors.rankMaster, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${r.playerScore} : ${r.opponentScore}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'FINAL SCORE',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                children: [
                  CharacterAvatar(characterId: r.opponentCharacterId, size: 64),
                  const SizedBox(height: 8),
                  Text(
                    oppChar.nameZh,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    r.opponentFighterId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
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
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam, color: AppColors.accentNeonCyan, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'REPLAY CODE: ${r.replayCode}',
                    style: const TextStyle(
                      color: AppColors.accentNeonCyan,
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
          const Text(
            'Generated by SF6 Fighter Companion App',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
