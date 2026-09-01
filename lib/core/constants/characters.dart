class Sf6Character {
  final String id;
  final String nameEn;
  final String nameZh;
  final String shortCode;
  final String avatarUrl;
  final String archetype;

  const Sf6Character({
    required this.id,
    required this.nameEn,
    required this.nameZh,
    required this.shortCode,
    required this.avatarUrl,
    required this.archetype,
  });
}

class Sf6Characters {
  static const List<Sf6Character> all = [
    Sf6Character(
      id: 'ryu',
      nameEn: 'Ryu',
      nameZh: '隆',
      shortCode: 'RYU',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/ryu/icon.png',
      archetype: '标准波动升龙型',
    ),
    Sf6Character(
      id: 'ken',
      nameEn: 'Ken',
      nameZh: '肯',
      shortCode: 'KEN',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/ken/icon.png',
      archetype: '近战角推 / 狂攻升龙型',
    ),
    Sf6Character(
      id: 'luke',
      nameEn: 'Luke',
      nameZh: '卢克',
      shortCode: 'LUK',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/luke/icon.png',
      archetype: '全能平衡 / 强力拳击型',
    ),
    Sf6Character(
      id: 'cammy',
      nameEn: 'Cammy',
      nameZh: '嘉米',
      shortCode: 'CAM',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/cammy/icon.png',
      archetype: '高速俯冲 / 压制突进型',
    ),
    Sf6Character(
      id: 'chunli',
      nameEn: 'Chun-Li',
      nameZh: '春丽',
      shortCode: 'CHU',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/chunli/icon.png',
      archetype: '立回牵制 / 构段多择型',
    ),
    Sf6Character(
      id: 'akuma',
      nameEn: 'Akuma',
      nameZh: '豪鬼',
      shortCode: 'GOU',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/akuma/icon.png',
      archetype: '高伤低防 / 纯粹攻势型',
    ),
    Sf6Character(
      id: 'bison',
      nameEn: 'M. Bison',
      nameZh: '维加',
      shortCode: 'BIS',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/bison/icon.png',
      archetype: '蓄力压制 / 爆弹压迫型',
    ),
    Sf6Character(
      id: 'guile',
      nameEn: 'Guile',
      nameZh: '古烈',
      shortCode: 'GUI',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/guile/icon.png',
      archetype: '蓄力波升 / 铁壁防守型',
    ),
    Sf6Character(
      id: 'juri',
      nameEn: 'Juri',
      nameZh: '韩蛛俐',
      shortCode: 'JUR',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/juri/icon.png',
      archetype: '风水蓄力 / 连段突击型',
    ),
    Sf6Character(
      id: 'jp',
      nameEn: 'JP',
      nameZh: 'JP',
      shortCode: 'JP',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/jp/icon.png',
      archetype: '远程地刺 / 空间陷阱型',
    ),
    Sf6Character(
      id: 'ed',
      nameEn: 'Ed',
      nameZh: '爱德',
      shortCode: 'ED',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/ed/icon.png',
      archetype: '刺拳牵制 / 闪避连击型',
    ),
    Sf6Character(
      id: 'rashid',
      nameEn: 'Rashid',
      nameZh: '拉希德',
      shortCode: 'RAS',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/rashid/icon.png',
      archetype: '旋风突进 / 灵活跑打型',
    ),
    Sf6Character(
      id: 'aki',
      nameEn: 'A.K.I.',
      nameZh: '阿鬼',
      shortCode: 'AKI',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/aki/icon.png',
      archetype: '毒素浸染 / 陷阱连打型',
    ),
    Sf6Character(
      id: 'terry',
      nameEn: 'Terry',
      nameZh: '特瑞',
      shortCode: 'TER',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/terry/icon.png',
      archetype: '全能拳脚 / 能量爆发型',
    ),
    Sf6Character(
      id: 'mai',
      nameEn: 'Mai',
      nameZh: '不知火舞',
      shortCode: 'MAI',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/mai/icon.png',
      archetype: '高速火扇 / 空间穿梭型',
    ),
    Sf6Character(
      id: 'elena',
      nameEn: 'Elena',
      nameZh: '艾莲娜',
      shortCode: 'ELE',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/elena/icon.png',
      archetype: '卡波耶拉 / 中下段高低择型',
    ),
    Sf6Character(
      id: 'jamie',
      nameEn: 'Jamie',
      nameZh: '杰米',
      shortCode: 'JAM',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/jamie/icon.png',
      archetype: '醉拳强化 / 连击突进型',
    ),
    Sf6Character(
      id: 'manon',
      nameEn: 'Manon',
      nameZh: '玛侬',
      shortCode: 'MAN',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/manon/icon.png',
      archetype: '芭蕾指令投 / 等级强化型',
    ),
    Sf6Character(
      id: 'kimberly',
      nameEn: 'Kimberly',
      nameZh: '金伯莉',
      shortCode: 'KIM',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/kimberly/icon.png',
      archetype: '疾走喷漆 / 漩涡起攻型',
    ),
    Sf6Character(
      id: 'marisa',
      nameEn: 'Marisa',
      nameZh: '玛丽莎',
      shortCode: 'MAR',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/marisa/icon.png',
      archetype: '霸体刚力 / 巨力重击型',
    ),
    Sf6Character(
      id: 'lily',
      nameEn: 'Lily',
      nameZh: '莉莉',
      shortCode: 'LIL',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/lily/icon.png',
      archetype: '风之存量 / 高速指令投',
    ),
    Sf6Character(
      id: 'deejay',
      nameEn: 'Dee Jay',
      nameZh: '迪·杰',
      shortCode: 'DJ',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/deejay/icon.png',
      archetype: '节奏假动作 / 摇摆多择型',
    ),
    Sf6Character(
      id: 'ehonda',
      nameEn: 'E. Honda',
      nameZh: '本田',
      shortCode: 'HON',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/ehonda/icon.png',
      archetype: '铁头突进 / 相扑百裂型',
    ),
    Sf6Character(
      id: 'blanka',
      nameEn: 'Blanka',
      nameZh: '布兰卡',
      shortCode: 'BLA',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/blanka/icon.png',
      archetype: '电击滚动 / 奇策扰乱型',
    ),
    Sf6Character(
      id: 'zangief',
      nameEn: 'Zangief',
      nameZh: '桑吉尔夫',
      shortCode: 'ZAN',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/zangief/icon.png',
      archetype: '纯粹指令投 / 铁壁压迫型',
    ),
    Sf6Character(
      id: 'dhalsim',
      nameEn: 'Dhalsim',
      nameZh: '达尔西姆',
      shortCode: 'DHA',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/dhalsim/icon.png',
      archetype: '长手火球 / 空间瞬移型',
    ),
    Sf6Character(
      id: 'yasmine',
      nameEn: 'Yasmine',
      nameZh: '亚斯敏',
      shortCode: 'YAS',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/yasmine/icon.png',
      archetype: '灵动身法 / 奇袭快攻型',
    ),
    Sf6Character(
      id: 'sagat',
      nameEn: 'Sagat',
      nameZh: '沙加特',
      shortCode: 'SAG',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/sagat/icon.png',
      archetype: '猛虎高低波 / 泰拳重击型',
    ),
    Sf6Character(
      id: 'cviper',
      nameEn: 'C. Viper',
      nameZh: 'C. 毒蛇',
      shortCode: 'VIP',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/cviper/icon.png',
      archetype: '电击突击 / 喷气取消型',
    ),
    Sf6Character(
      id: 'alex',
      nameEn: 'Alex',
      nameZh: '亚历克斯',
      shortCode: 'ALX',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/alex/icon.png',
      archetype: '摔角指令投 / 强力重击型',
    ),
    Sf6Character(
      id: 'ingrid',
      nameEn: 'Ingrid',
      nameZh: '英格丽德',
      shortCode: 'ING',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/ingrid/icon.png',
      archetype: '太阳能量 / 空间控制型',
    ),
    Sf6Character(
      id: 'random',
      nameEn: 'Random',
      nameZh: '随机',
      shortCode: '?',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/random/icon.png',
      archetype: '全角色随机',
    ),
  ];

  static Sf6Character getById(String id) {
    if (id.trim().isEmpty) return all.first;
    final lower = id.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (lower == 'random' || lower == 'cha' || lower == 'character' || lower == 'unknown' || lower == 'rand' || lower == 'q') {
      return all.firstWhere((c) => c.id == 'random');
    }
    if (lower == 'gouki') return getById('akuma');
    if (lower == 'vega') return getById('bison');
    if (lower == 'honda') return getById('ehonda');
    if (lower == 'chun') return getById('chunli');
    if (lower == 'yasmin' || lower == 'yas' || lower == 'yasmine') {
      return all.firstWhere((c) => c.id == 'yasmine');
    }
    if (lower == 'viper') {
      return all.firstWhere((c) => c.id == 'cviper');
    }

    for (final c in all) {
      if (c.id.replaceAll(RegExp(r'[^a-z0-9]'), '') == lower ||
          c.nameEn.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') == lower ||
          c.nameZh == id ||
          c.shortCode.toLowerCase() == lower) {
        return c;
      }
    }

    return Sf6Character(
      id: lower.isNotEmpty ? lower : 'custom',
      nameEn: id,
      nameZh: id,
      shortCode: id.length >= 3 ? id.substring(0, 3).toUpperCase() : id.toUpperCase(),
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/$lower/icon.png',
      archetype: '格斗家',
    );
  }

  static Sf6Character fromCapcomId(dynamic id) {
    if (id == null) return all.first;
    final s = id.toString().trim().toLowerCase();
    if (s == '0' || s == 'cha' || s == 'random' || s == '253' || s == '254' || s == '255') {
      return getById('random');
    }
    if (id is int || (id is String && int.tryParse(id) != null)) {
      final num = id is int ? id : int.parse(id as String);
      if (num == 0 || num >= 250) return getById('random');
      const capcomMap = {
        1: 'ryu',
        2: 'luke',
        3: 'kimberly',
        4: 'chunli',
        5: 'manon',
        6: 'zangief',
        7: 'jp',
        8: 'dhalsim',
        9: 'cammy',
        10: 'ken',
        11: 'deejay',
        12: 'lily',
        13: 'aki',
        14: 'rashid',
        15: 'blanka',
        16: 'juri',
        17: 'marisa',
        18: 'guile',
        19: 'ed',
        20: 'ehonda',
        21: 'jamie',
        22: 'akuma',
        23: 'sagat',
        24: 'bison',
        25: 'sagat',
        26: 'bison',
        27: 'terry',
        28: 'mai',
        29: 'elena',
        30: 'cviper',
        31: 'alex',
        32: 'ingrid',
        33: 'yasmine',
        34: 'sagat',
      };
      final charId = capcomMap[num];
      if (charId != null) return getById(charId);
      return getById('char_$num');
    }
    return getById(id.toString());
  }
}
