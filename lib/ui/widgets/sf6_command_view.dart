import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';

enum CommandDisplayMode {
  graphic, // 街霸官网图形 (方向箭头 + 蓝/黄/红拳脚图标)
  numpad,  // 经典数字简记 (5LP, 2MK, 236P)
  chinese, // 中文通俗全称 (站轻拳/腿, 蹲中拳/腿, 升龙拳)
  modern,  // 现代模式 (轻/中/重/SP)
  ;

  String get displayName {
    switch (this) {
      case CommandDisplayMode.graphic:
        return '官方图形';
      case CommandDisplayMode.numpad:
        return '5LP 数字';
      case CommandDisplayMode.chinese:
        return '站轻腿 中文';
      case CommandDisplayMode.modern:
        return '现代模式';
    }
  }
}

class Sf6CommandView extends StatelessWidget {
  final String rawCommand;
  final CommandDisplayMode mode;
  final double iconSize;
  final TextStyle? textStyle;
  final bool wrap;

  const Sf6CommandView({
    super.key,
    required this.rawCommand,
    required this.mode,
    this.iconSize = 18.0,
    this.textStyle,
    this.wrap = true,
  });

  @override
  Widget build(BuildContext context) {
    if (rawCommand.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    switch (mode) {
      case CommandDisplayMode.numpad:
        return _buildNumpadView(context);
      case CommandDisplayMode.chinese:
        return _buildChineseView(context);
      case CommandDisplayMode.modern:
        return _buildModernView(context);
      case CommandDisplayMode.graphic:
        return _buildGraphicView(context);
    }
  }

  Widget _buildNumpadView(BuildContext context) {
    final style = textStyle ??
        const TextStyle(
          color: AppColors.accentNeonCyan,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.3,
        );
    return SelectableText(rawCommand, style: style);
  }

  Widget _buildChineseView(BuildContext context) {
    final style = textStyle ??
        const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        );
    final translated = translateToChinese(rawCommand);
    return SelectableText(translated, style: style);
  }

  Widget _buildModernView(BuildContext context) {
    final style = textStyle ??
        const TextStyle(
          color: AppColors.rankGold,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        );
    final modernText = translateToModern(rawCommand);
    return SelectableText(modernText, style: style);
  }

  Widget _buildGraphicView(BuildContext context) {
    final tokens = _tokenizeCommand(rawCommand);
    final widgets = <Widget>[];

    for (int i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      final item = _buildTokenWidget(t);
      if (item != null) {
        widgets.add(item);
      }
    }

    if (widgets.isEmpty) {
      return _buildNumpadView(context);
    }

    if (wrap) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 3,
        runSpacing: 4,
        children: widgets,
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgets.map((w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 1.5), child: w)).toList(),
        ),
      );
    }
  }

  Widget? _buildTokenWidget(String token) {
    final t = token.trim();
    if (t.isEmpty) return null;

    // Badges / Tags
    final upper = t.toUpperCase();
    if (upper == 'PC' || upper == 'PUNISH') {
      return _badgeWidget('PC 确反', AppColors.loseRed);
    }
    if (upper == 'CH') {
      return _badgeWidget('CH 打断', Colors.orangeAccent);
    }
    if (upper == 'DR' || upper == 'DRIVE RUSH' || upper == 'PDR') {
      return _badgeWidget('绿冲', AppColors.winGreen);
    }
    if (upper == 'DI' || upper == 'DRIVE IMPACT') {
      return _badgeWidget('迸发', AppColors.accentNeonCyan);
    }
    if (upper == 'DASH') {
      return _badgeWidget('前冲', AppColors.textSecondary);
    }
    if (upper == 'OD' || upper == 'EX') {
      return _badgeWidget('OD', AppColors.rankGold);
    }
    if (upper == 'SA1' || upper == 'SA2' || upper == 'SA3' || upper == 'CA') {
      return _badgeWidget(upper, Colors.purpleAccent);
    }

    // Connectors
    if (t == '>' || t == '->' || t == '~>' || t == '~') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(Icons.arrow_forward_ios, size: iconSize * 0.55, color: AppColors.textTertiary),
      );
    }
    if (t == ',') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(',', style: TextStyle(color: AppColors.textTertiary, fontSize: iconSize * 0.8, fontWeight: FontWeight.bold)),
      );
    }
    if (t == '+' || t == '/') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Text(t, style: TextStyle(color: AppColors.textTertiary, fontSize: iconSize * 0.75, fontWeight: FontWeight.bold)),
      );
    }

    // Move token (e.g. 5LP, 236P, 623HP, 2MK, 4HP)
    return _buildSingleMoveGraphic(t);
  }

  Widget _badgeWidget(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.6), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSingleMoveGraphic(String moveText) {
    final subElements = <Widget>[];

    // Check motion prefixes (e.g. 236, 214, 623, 421, 41236, 63214, 236236, 214214, 4蓄6, 2蓄8)
    String clean = moveText;
    
    // Motions
    if (clean.startsWith('236236')) {
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-dr.png'));
      subElements.add(_arrow('key-r.png'));
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-dr.png'));
      subElements.add(_arrow('key-r.png'));
      clean = clean.substring(6);
    } else if (clean.startsWith('214214')) {
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-dl.png'));
      subElements.add(_arrow('key-l.png'));
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-dl.png'));
      subElements.add(_arrow('key-l.png'));
      clean = clean.substring(6);
    } else if (clean.startsWith('41236')) {
      subElements.add(_arrow('key-l.png'));
      subElements.add(_arrow('key-dl.png'));
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-dr.png'));
      subElements.add(_arrow('key-r.png'));
      clean = clean.substring(5);
    } else if (clean.startsWith('63214')) {
      subElements.add(_arrow('key-r.png'));
      subElements.add(_arrow('key-dr.png'));
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-dl.png'));
      subElements.add(_arrow('key-l.png'));
      clean = clean.substring(5);
    } else if (clean.startsWith('236')) {
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-dr.png'));
      subElements.add(_arrow('key-r.png'));
      clean = clean.substring(3);
    } else if (clean.startsWith('214')) {
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-dl.png'));
      subElements.add(_arrow('key-l.png'));
      clean = clean.substring(3);
    } else if (clean.startsWith('623')) {
      subElements.add(_arrow('key-r.png'));
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-dr.png'));
      clean = clean.substring(3);
    } else if (clean.startsWith('421')) {
      subElements.add(_arrow('key-l.png'));
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-dl.png'));
      clean = clean.substring(3);
    } else if (clean.startsWith('4蓄6') || clean.startsWith('[4]6')) {
      subElements.add(_arrow('key-l.png'));
      subElements.add(_textTiny('(蓄)'));
      subElements.add(_arrow('key-r.png'));
      clean = clean.replaceAll(RegExp(r'^(4蓄6|\[4\]6)'), '');
    } else if (clean.startsWith('2蓄8') || clean.startsWith('[2]8')) {
      subElements.add(_arrow('key-d.png'));
      subElements.add(_textTiny('(蓄)'));
      subElements.add(_arrow('key-u.png'));
      clean = clean.replaceAll(RegExp(r'^(2蓄8|\[2\]8)'), '');
    } else if (clean.startsWith('22')) {
      subElements.add(_arrow('key-d.png'));
      subElements.add(_arrow('key-d.png'));
      clean = clean.substring(2);
    } else if (clean.startsWith('66')) {
      subElements.add(_arrow('key-r.png'));
      subElements.add(_arrow('key-r.png'));
      clean = clean.substring(2);
    } else if (clean.isNotEmpty && clean[0] == '2') {
      subElements.add(_arrow('key-d.png'));
      clean = clean.substring(1);
    } else if (clean.isNotEmpty && clean[0] == '4') {
      subElements.add(_arrow('key-l.png'));
      clean = clean.substring(1);
    } else if (clean.isNotEmpty && clean[0] == '6') {
      subElements.add(_arrow('key-r.png'));
      clean = clean.substring(1);
    } else if (clean.isNotEmpty && clean[0] == '8') {
      subElements.add(_arrow('key-u.png'));
      clean = clean.substring(1);
    } else if (clean.isNotEmpty && clean[0] == '1') {
      subElements.add(_arrow('key-dl.png'));
      clean = clean.substring(1);
    } else if (clean.isNotEmpty && clean[0] == '3') {
      subElements.add(_arrow('key-dr.png'));
      clean = clean.substring(1);
    } else if (clean.isNotEmpty && clean[0] == '5') {
      // 5 is neutral, usually implicit with punch/kick, no direction needed
      clean = clean.substring(1);
    }

    clean = clean.trim();
    if (clean.startsWith('+')) clean = clean.substring(1).trim();

    // Now parse button part
    final upperClean = clean.toUpperCase();
    if (upperClean == 'LP') {
      subElements.add(_button('icon_punch_l.png'));
    } else if (upperClean == 'MP') {
      subElements.add(_button('icon_punch_m.png'));
    } else if (upperClean == 'HP') {
      subElements.add(_button('icon_punch_h.png'));
    } else if (upperClean == 'P' || upperClean == 'PPP') {
      subElements.add(_button('icon_punch.png'));
    } else if (upperClean == 'PP') {
      subElements.add(_badgeWidget('OD', AppColors.rankGold));
      subElements.add(_button('icon_punch.png'));
    } else if (upperClean == 'LK') {
      subElements.add(_button('icon_kick_l.png'));
    } else if (upperClean == 'MK') {
      subElements.add(_button('icon_kick_m.png'));
    } else if (upperClean == 'HK') {
      subElements.add(_button('icon_kick_h.png'));
    } else if (upperClean == 'K' || upperClean == 'KKK') {
      subElements.add(_button('icon_kick.png'));
    } else if (upperClean == 'KK') {
      subElements.add(_badgeWidget('OD', AppColors.rankGold));
      subElements.add(_button('icon_kick.png'));
    } else if (upperClean.isNotEmpty) {
      subElements.add(
        Text(
          clean,
          style: TextStyle(
            color: AppColors.accentNeonCyan,
            fontSize: iconSize * 0.75,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (subElements.isEmpty) {
      return Text(moveText, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: subElements.map((e) => Padding(padding: const EdgeInsets.only(right: 1.5), child: e)).toList(),
    );
  }

  Widget _arrow(String filename) {
    return Image.asset(
      'assets/images/controller/$filename',
      width: iconSize,
      height: iconSize,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.arrow_forward, size: 14, color: AppColors.textTertiary),
    );
  }

  Widget _button(String filename) {
    return Image.asset(
      'assets/images/controller/$filename',
      width: iconSize * 1.15,
      height: iconSize * 1.15,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.circle, size: 14, color: AppColors.accentNeonCyan),
    );
  }

  Widget _textTiny(String t) {
    return Text(t, style: TextStyle(color: AppColors.textTertiary, fontSize: iconSize * 0.55, fontWeight: FontWeight.bold));
  }

  List<String> _tokenizeCommand(String input) {
    // Splits tokens while keeping delimiters (>, comma, ~, +, /)
    final tokens = <String>[];
    final regex = RegExp(r'(PC|CH|DR|DI|DASH|OD|SA[1-3]|CA|>|~>|~|,|\+|/|[^\s>,~+/]+)', caseSensitive: false);
    for (final match in regex.allMatches(input)) {
      final val = match.group(0);
      if (val != null && val.trim().isNotEmpty) {
        tokens.add(val.trim());
      }
    }
    return tokens;
  }

  static String translateToChinese(String cmd) {
    String res = cmd;
    // Common prefixes / states
    res = res.replaceAll(RegExp(r'\bPC\b', caseSensitive: false), '确反康 ');
    res = res.replaceAll(RegExp(r'\bCH\b', caseSensitive: false), '打断康 ');
    res = res.replaceAll(RegExp(r'\bDR\b', caseSensitive: false), '绿冲 ');
    res = res.replaceAll(RegExp(r'\bDASH\b', caseSensitive: false), '前冲 ');
    res = res.replaceAll(RegExp(r'\bDI\b', caseSensitive: false), '斗气迸发 ');

    // Supers
    res = res.replaceAll(RegExp(r'\b236236P\b', caseSensitive: false), '真空波动/SA1');
    res = res.replaceAll(RegExp(r'\b214214P\b', caseSensitive: false), '真空超杀/SA2');
    res = res.replaceAll(RegExp(r'\b236236K\b', caseSensitive: false), '终极超杀/SA3');
    res = res.replaceAll(RegExp(r'\b214214K\b', caseSensitive: false), '终极超杀/SA3');

    // Specials
    res = res.replaceAll(RegExp(r'\b236PP\b', caseSensitive: false), 'OD波动拳');
    res = res.replaceAll(RegExp(r'\b236KK\b', caseSensitive: false), 'OD前冲腿');
    res = res.replaceAll(RegExp(r'\b623PP\b', caseSensitive: false), 'OD升龙拳');
    res = res.replaceAll(RegExp(r'\b623KK\b', caseSensitive: false), 'OD升龙腿');
    res = res.replaceAll(RegExp(r'\b214PP\b', caseSensitive: false), 'OD波掌击');
    res = res.replaceAll(RegExp(r'\b214KK\b', caseSensitive: false), 'OD龙卷旋风');

    res = res.replaceAll(RegExp(r'\b236P\b', caseSensitive: false), '波动拳');
    res = res.replaceAll(RegExp(r'\b236HP\b', caseSensitive: false), '重波动拳');
    res = res.replaceAll(RegExp(r'\b236MP\b', caseSensitive: false), '中波动拳');
    res = res.replaceAll(RegExp(r'\b236LP\b', caseSensitive: false), '轻波动拳');

    res = res.replaceAll(RegExp(r'\b623P\b', caseSensitive: false), '升龙拳');
    res = res.replaceAll(RegExp(r'\b623HP\b', caseSensitive: false), '重升龙拳');
    res = res.replaceAll(RegExp(r'\b623MP\b', caseSensitive: false), '中升龙拳');
    res = res.replaceAll(RegExp(r'\b623LP\b', caseSensitive: false), '轻升龙拳');

    res = res.replaceAll(RegExp(r'\b214K\b', caseSensitive: false), '龙卷旋风腿');
    res = res.replaceAll(RegExp(r'\b214HK\b', caseSensitive: false), '重龙卷腿');
    res = res.replaceAll(RegExp(r'\b214MK\b', caseSensitive: false), '中龙卷腿');
    res = res.replaceAll(RegExp(r'\b214LK\b', caseSensitive: false), '轻龙卷腿');

    res = res.replaceAll(RegExp(r'\b214P\b', caseSensitive: false), '波掌击');
    res = res.replaceAll(RegExp(r'\b214HP\b', caseSensitive: false), '重波掌击');
    res = res.replaceAll(RegExp(r'\b214MP\b', caseSensitive: false), '中波掌击');
    res = res.replaceAll(RegExp(r'\b214LP\b', caseSensitive: false), '轻波掌击');

    res = res.replaceAll(RegExp(r'\b236K\b', caseSensitive: false), '上段踢');
    res = res.replaceAll(RegExp(r'\b236HK\b', caseSensitive: false), '重大踢');
    res = res.replaceAll(RegExp(r'\b236MK\b', caseSensitive: false), '中大踢');
    res = res.replaceAll(RegExp(r'\b236LK\b', caseSensitive: false), '轻大踢');

    // Normals & Uniques
    res = res.replaceAll(RegExp(r'\b5LP\b', caseSensitive: false), '站轻拳');
    res = res.replaceAll(RegExp(r'\b5MP\b', caseSensitive: false), '站中拳');
    res = res.replaceAll(RegExp(r'\b5HP\b', caseSensitive: false), '站重拳');
    res = res.replaceAll(RegExp(r'\b2LP\b', caseSensitive: false), '蹲轻拳');
    res = res.replaceAll(RegExp(r'\b2MP\b', caseSensitive: false), '蹲中拳');
    res = res.replaceAll(RegExp(r'\b2HP\b', caseSensitive: false), '蹲重拳');

    res = res.replaceAll(RegExp(r'\b5LK\b', caseSensitive: false), '站轻腿');
    res = res.replaceAll(RegExp(r'\b5MK\b', caseSensitive: false), '站中腿');
    res = res.replaceAll(RegExp(r'\b5HK\b', caseSensitive: false), '站重腿');
    res = res.replaceAll(RegExp(r'\b2LK\b', caseSensitive: false), '蹲轻腿');
    res = res.replaceAll(RegExp(r'\b2MK\b', caseSensitive: false), '蹲中腿');
    res = res.replaceAll(RegExp(r'\b2HK\b', caseSensitive: false), '蹲重腿(扫堂)');

    res = res.replaceAll(RegExp(r'\b6MP\b', caseSensitive: false), '前中拳(锁骨)');
    res = res.replaceAll(RegExp(r'\b6HP\b', caseSensitive: false), '前重拳(腹击)');
    res = res.replaceAll(RegExp(r'\b6HK\b', caseSensitive: false), '前重腿');
    res = res.replaceAll(RegExp(r'\b4HP\b', caseSensitive: false), '后重拳');
    res = res.replaceAll(RegExp(r'\b3HK\b', caseSensitive: false), '斜下重腿');

    return res;
  }

  static String translateToModern(String cmd) {
    String res = cmd;
    res = res.replaceAll(RegExp(r'\b5LP\b', caseSensitive: false), '5L');
    res = res.replaceAll(RegExp(r'\b5MP\b', caseSensitive: false), '5M');
    res = res.replaceAll(RegExp(r'\b5HP\b', caseSensitive: false), '5H');
    res = res.replaceAll(RegExp(r'\b2LP\b', caseSensitive: false), '2L');
    res = res.replaceAll(RegExp(r'\b2MP\b', caseSensitive: false), '2M');
    res = res.replaceAll(RegExp(r'\b2HP\b', caseSensitive: false), '2H');

    res = res.replaceAll(RegExp(r'\b5LK\b', caseSensitive: false), '5L');
    res = res.replaceAll(RegExp(r'\b5MK\b', caseSensitive: false), '5M');
    res = res.replaceAll(RegExp(r'\b5HK\b', caseSensitive: false), '5H');
    res = res.replaceAll(RegExp(r'\b2LK\b', caseSensitive: false), '2L');
    res = res.replaceAll(RegExp(r'\b2MK\b', caseSensitive: false), '2M');
    res = res.replaceAll(RegExp(r'\b2HK\b', caseSensitive: false), '2H');

    res = res.replaceAll(RegExp(r'\b236(P|K)\b', caseSensitive: false), 'SP');
    res = res.replaceAll(RegExp(r'\b623(P|K)\b', caseSensitive: false), '6+SP');
    res = res.replaceAll(RegExp(r'\b214(P|K)\b', caseSensitive: false), '4+SP');
    res = res.replaceAll(RegExp(r'\b22(P|K)\b', caseSensitive: false), '2+SP');

    return res;
  }
}
