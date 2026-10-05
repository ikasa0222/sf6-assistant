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
      case 'dee-jay':
        return 'dee-jay';
      case 'bison':
      case 'mbison':
      case 'm-bison':
        return 'm-bison';
      case 'gouki':
      case 'akuma':
        return 'akuma';
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
    final cmd = move.command.toUpperCase().replaceAll(' ', '').trim();
    final name = move.name.toLowerCase().trim();

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
      case 'J.LP':
      case '8LP':
        return '$charSlug-j-lp.gif';
      case 'J.MP':
      case '8MP':
        return '$charSlug-j-mp.gif';
      case 'J.HP':
      case '8HP':
        return '$charSlug-j-hp.gif';
      case 'J.LK':
      case '8LK':
        return '$charSlug-j-lk.gif';
      case 'J.MK':
      case '8MK':
        return '$charSlug-j-mk.gif';
      case 'J.HK':
      case '8HK':
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
      case '3HP':
        return '$charSlug-df+hp.gif';
    }

    // Terry
    if (charSlug == 'terry') {
      if (name.contains('燃烧指节') || cmd.contains('214P') || name.contains('burn knuckle') || name.contains('burnknuckle')) {
        return 'terry-burnknuckle-hp.gif';
      }
      if (name.contains('能量波') || cmd.contains('236P') || name.contains('power wave') || name.contains('powerwave')) {
        return 'terry-powerwave-hp.gif';
      }
      if (name.contains('升起齿轮') || cmd.contains('623P') || name.contains('rising tackle') || name.contains('risingtackle')) {
        return 'terry-risingtackle-hp.gif';
      }
      if (name.contains('裂破') || cmd.contains('214K') || name.contains('crack shoot') || name.contains('crackshoot')) {
        return 'terry-crackshoot-hk.gif';
      }
      if (name.contains('喷泉') || name.contains('power geyser') || name.contains('powergeyser')) {
        return 'terry-powergeyser.gif';
      }
    }

    // Ryu
    if (charSlug == 'ryu') {
      if (name.contains('足刀') || cmd.contains('236K') || name.contains('jodan')) {
        return 'ryu-jodan-hk.gif';
      }
      if (name.contains('波掌') || cmd.contains('214P') || name.contains('hashogeki')) {
        return 'ryu-hashogeki-hp.gif';
      }
      if (name.contains('升龙') || cmd.contains('623P') || cmd.contains('623')) {
        return 'ryu-shoryuken-hp.gif';
      }
      if (name.contains('波动') || cmd == '236P' || cmd == '236PP') {
        return 'ryu-hadoken-hp.gif';
      }
      if (name.contains('龙卷') || cmd == '214K' || cmd == '214KK') {
        return 'ryu-tatsumaki-hk.gif';
      }
    }

    // Ken
    if (charSlug == 'ken') {
      if (name.contains('迅雷') || cmd.contains('236K') || name.contains('jinraikyaku') || name.contains('jinraiki')) {
        return 'ken-jinraikyaku-hk.gif';
      }
      if (name.contains('龙尾') || cmd.contains('623K')) {
        return 'ken-dragonlashkick-hk.gif';
      }
      if (name.contains('升龙') || cmd.contains('623P') || cmd.contains('623')) {
        return 'ken-shoryuken-hp.gif';
      }
      if (name.contains('波动') || cmd == '236P' || cmd == '236PP') {
        return 'ken-hadoken-hp.gif';
      }
      if (name.contains('龙卷') || cmd == '214K' || cmd == '214KK') {
        return 'ken-tatsumaki-hk.gif';
      }
    }

    // Chun-Li
    if (charSlug == 'chun-li') {
      if (name.contains('气功') || cmd.contains('4蓄6P') || cmd.contains('46P') || name.contains('kikoken')) {
        return 'chun-li-kikoken-hp.gif';
      }
      if (name.contains('鹤脚') || name.contains('旋风') || cmd.contains('2蓄8K') || cmd.contains('28K') || name.contains('spinning bird') || name.contains('spinningbird')) {
        return 'chun-li-spinningbirdkick-hk.gif';
      }
      if (name.contains('百裂') || cmd.contains('236K') || name.contains('lightning legs')) {
        return 'chun-li-lightninglegs-hk.gif';
      }
      if (name.contains('天升') || cmd.contains('22K') || name.contains('tenshokyaku')) {
        return 'chun-li-tenshokyaku-hk.gif';
      }
      if (name.contains('霸山') || name.contains('hazanshu')) {
        return 'chun-li-hazanshu-hk.gif';
      }
    }

    // Akuma
    if (charSlug == 'akuma') {
      if (name.contains('豪波动') || cmd == '236P' || cmd == '236PP' || name.contains('gohadoken')) {
        return 'akuma-gohadoken-hp.gif';
      }
      if (name.contains('豪升龙') || cmd.contains('623P') || name.contains('goshoryu')) {
        return 'akuma-goshoryu-hp.gif';
      }
      if (name.contains('百鬼') || cmd.contains('623K') || name.contains('hyakkishu')) {
        return 'akuma-hyakkishu-hp.gif';
      }
      if (name.contains('龙卷') || cmd == '214K' || cmd == '214KK') {
        return 'akuma-tatsumakigokaku-hk.gif';
      }
      if (name.contains('金刚') || cmd.contains('214P') || name.contains('kongoshokaku')) {
        return 'akuma-kongoshokaku-hp.gif';
      }
    }

    // Luke
    if (charSlug == 'luke') {
      if (name.contains('沙弹') || cmd.contains('236P') || name.contains('sandblaster')) {
        return 'luke-sandblaster-hp.gif';
      }
      if (name.contains('闪电重拳') || cmd.contains('214P') || name.contains('flash knuckle')) {
        return 'luke-flashknuckle-hp.gif';
      }
      if (name.contains('升龙') || cmd.contains('623P') || name.contains('rising uppercut')) {
        return 'luke-risingupper-hp.gif';
      }
    }

    // Cammy
    if (charSlug == 'cammy') {
      if (name.contains('螺旋箭') || cmd.contains('236K') || name.contains('spiral arrow')) {
        return 'cammy-spiralarrow-hk.gif';
      }
      if (name.contains('加农') || cmd.contains('623K') || name.contains('cannon spike')) {
        return 'cammy-cannonspike-hk.gif';
      }
      if (name.contains('流氓') || cmd.contains('236P') || name.contains('hooligan')) {
        return 'cammy-hooligancombination.gif';
      }
      if (name.contains('疾风') || cmd.contains('214P') || name.contains('spin knuckle')) {
        return 'cammy-spin-knuckle-hp.gif';
      }
    }

    // Guile
    if (charSlug == 'guile') {
      if (name.contains('手刀') || name.contains('音速波') || cmd.contains('4蓄6P') || cmd.contains('46P') || name.contains('sonic boom')) {
        return 'guile-sonicboom.gif';
      }
      if (name.contains('脚刀') || name.contains('倒勾') || cmd.contains('2蓄8K') || cmd.contains('28K') || name.contains('flash kick') || name.contains('flashkick')) {
        return 'guile-flashkick.gif';
      }
      if (name.contains('利刃') || cmd.contains('214P') || name.contains('sonic blade')) {
        return 'guile-sonicblade-hp.gif';
      }
    }

    // Zangief
    if (charSlug == 'zangief') {
      if (name.contains('打桩') || name.contains('spd') || cmd.contains('360')) {
        return 'zangief-spd-hp.gif';
      }
      if (name.contains('金臂勾') || name.contains('双重') || cmd.contains('PPP') || name.contains('lariat')) {
        return 'zangief-doublelariat.gif';
      }
      if (name.contains('快车') || cmd.contains('63214K') || name.contains('siberian express')) {
        return 'zangief-siberianexpress-hk.gif';
      }
    }

    // Fallback for generic specials with clear naming
    if (name.contains('升龙') || cmd.contains('623P')) {
      return '$charSlug-shoryuken-hp.gif';
    }
    if (name.contains('波动') || cmd == '236P' || cmd == '236PP') {
      return '$charSlug-hadoken-hp.gif';
    }
    if (name.contains('龙卷') || cmd == '214K' || cmd == '214KK') {
      return '$charSlug-tatsumaki-hk.gif';
    }

    return null;
  }
}
