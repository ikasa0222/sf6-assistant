import 'package:sf6_tracker/models/frame_data_model.dart';

class Sf6MoveMediaHelper {
  static const String _ufdBaseUrl = 'https://ultimateframedata.com/sf6/hitboxes';

  /// Standardize character slug used by UltimateFrameData
  static String getUfdCharacterSlug(String characterId) {
    final id = characterId.toLowerCase().trim();
    switch (id) {
      case 'chunli':
        return 'chun-li';
      case 'ehonda':
        return 'e-honda';
      case 'deejay':
        return 'dee-jay';
      case 'bison':
      case 'mbison':
        return 'm-bison';
      default:
        return id;
    }
  }

  /// Get the hitbox GIF URL on UltimateFrameData
  static String? getHitboxGifUrl(String characterId, FrameMove move) {
    final charSlug = getUfdCharacterSlug(characterId);
    final moveFile = _resolveMoveFilename(charSlug, move);
    if (moveFile == null) return null;
    return '$_ufdBaseUrl/$charSlug/$moveFile';
  }

  /// Alias for getHitboxGifUrl
  static String? getMoveGifUrl(String characterId, FrameMove move) =>
      getHitboxGifUrl(characterId, move);

  static String? _resolveMoveFilename(String charSlug, FrameMove move) {
    final cmd = move.command.trim();
    final name = move.name.toLowerCase();

    // Universal Normals
    switch (cmd) {
      case '5LP':
        return '$charSlug-st-lp.gif';
      case '5MP':
        return '$charSlug-st-mp.gif';
      case '5HP':
        return '$charSlug-st-hp.gif';
      case '5LK':
        return '$charSlug-st-lk.gif';
      case '5MK':
        return '$charSlug-st-mk.gif';
      case '5HK':
        return '$charSlug-st-hk.gif';
      case '2LP':
        return '$charSlug-cr-lp.gif';
      case '2MP':
        return '$charSlug-cr-mp.gif';
      case '2HP':
        return '$charSlug-cr-hp.gif';
      case '2LK':
        return '$charSlug-cr-lk.gif';
      case '2MK':
        return '$charSlug-cr-mk.gif';
      case '2HK':
        return '$charSlug-cr-hk.gif';
      case 'j.LP':
        return '$charSlug-j-lp.gif';
      case 'j.MP':
        return '$charSlug-j-mp.gif';
      case 'j.HP':
        return '$charSlug-j-hp.gif';
      case 'j.LK':
        return '$charSlug-j-lk.gif';
      case 'j.MK':
        return '$charSlug-j-mk.gif';
      case 'j.HK':
        return '$charSlug-j-hk.gif';
      case '6MP':
        return '$charSlug-f+mp.gif';
      case '6HP':
        return '$charSlug-f+hp.gif';
      case '4HP':
        return '$charSlug-b+hp.gif';
      case '6MK':
        return '$charSlug-f+mk.gif';
      case '6HK':
        return '$charSlug-f+hk.gif';
      case '4HK':
        return '$charSlug-b+hk.gif';
      case '3HK':
        return '$charSlug-df+hk.gif';
    }

    // Special moves by command keywords
    if (name.contains('升龙') || cmd.contains('623')) {
      return '$charSlug-shoryuken-hp.gif';
    }
    if (name.contains('波动') || cmd == '236P' || cmd == '236PP') {
      return '$charSlug-hadoken-hp.gif';
    }
    if (name.contains('龙卷') || cmd == '214K' || cmd == '214KK') {
      return '$charSlug-tatsumaki-hk.gif';
    }
    if (name.contains('螺旋箭') || (charSlug == 'cammy' && cmd.contains('236K'))) {
      return 'cammy-spiralarrow-hk.gif';
    }
    if (name.contains('加农') || (charSlug == 'cammy' && cmd.contains('623K'))) {
      return 'cammy-cannonspike-hk.gif';
    }
    if (name.contains('手刀') || (charSlug == 'guile' && cmd.contains('4蓄6P'))) {
      return 'guile-sonicboom.gif';
    }
    if (name.contains('打桩') || name.contains('spd') || cmd.contains('360P')) {
      return 'zangief-spd-hp.gif';
    }
    if (name.contains('百裂') || (charSlug == 'chun-li' && cmd.contains('236K'))) {
      return 'chun-li-lightninglegs-hk.gif';
    }
    if (name.contains('沙弹') || (charSlug == 'luke' && cmd.contains('236P'))) {
      return 'luke-sandblaster-hp.gif';
    }
    if (name.contains('闪电重拳') || (charSlug == 'luke' && cmd.contains('214P'))) {
      return 'luke-flashknuckle-hp.gif';
    }

    return null;
  }
}
