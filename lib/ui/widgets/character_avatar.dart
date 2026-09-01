import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';

class CharacterAvatar extends StatelessWidget {
  final String characterId;
  final double size;
  final bool showBorder;
  final Color? borderColor;

  const CharacterAvatar({
    super.key,
    required this.characterId,
    this.size = 44,
    this.showBorder = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final char = Sf6Characters.getById(characterId);
    final color = _getCharacterThemeColor(char.id);
    final assetPath = 'assets/images/characters/${char.id}.png';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? color.withOpacity(0.85),
                width: size > 40 ? 2.0 : 1.2,
              )
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            if (char.avatarUrl.isNotEmpty) {
              return Image.network(
                char.avatarUrl,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackText(char);
                },
              );
            }
            return _buildFallbackText(char);
          },
        ),
      ),
    );
  }

  Widget _buildFallbackText(Sf6Character char) {
    if (char.id == 'random' || char.shortCode == '?') {
      return Center(
        child: Icon(
          Icons.help_outline_rounded,
          color: AppColors.accentNeonCyan,
          size: size * 0.62,
        ),
      );
    }
    return Center(
      child: Text(
        char.shortCode,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getCharacterThemeColor(String charId) {
    final lower = charId.toLowerCase();
    if (lower == 'random' || lower == 'cha' || lower == '?') return AppColors.accentNeonCyan;
    if (lower.contains('ryu')) return const Color(0xFFE53935);
    if (lower.contains('ken')) return const Color(0xFFFF9800);
    if (lower.contains('cammy')) return const Color(0xFF00E676);
    if (lower.contains('luke')) return const Color(0xFF00B0FF);
    if (lower.contains('akuma') || lower.contains('gouki')) return const Color(0xFFD50000);
    if (lower.contains('ed')) return const Color(0xFF7C4DFF);
    if (lower.contains('jp')) return const Color(0xFF651FFF);
    if (lower.contains('chun')) return const Color(0xFF00E5FF);
    if (lower.contains('zangief')) return const Color(0xFFFF5252);
    if (lower.contains('guile')) return const Color(0xFF76FF03);
    if (lower.contains('juri')) return const Color(0xFFFF007F);
    if (lower.contains('rashid')) return const Color(0xFFFFD600);
    if (lower.contains('terry')) return const Color(0xFFFF1744);
    if (lower.contains('mai')) return const Color(0xFFFF4081);
    if (lower.contains('elena')) return const Color(0xFF00E5FF);
    if (lower.contains('viper')) return const Color(0xFFFF6D00);
    if (lower.contains('alex')) return const Color(0xFFFFAB00);
    if (lower.contains('yasmine') || lower.contains('yasmin')) return const Color(0xFFE040FB);
    if (lower.contains('ingrid')) return const Color(0xFFFFD700);
    if (lower.contains('bison') || lower.contains('vega')) return const Color(0xFFB71C1C);
    if (lower.contains('sagat')) return const Color(0xFFFF6F00);
    return const Color(0xFF00E5FF);
  }
}
