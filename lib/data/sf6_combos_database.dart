// SF6 Combo Database
// Built-in combo recipes and loader from Supercombo GG dataset

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sf6_tracker/models/combo_recipe.dart';

class Sf6CombosDatabase {
  static final Map<String, List<ComboRecipe>> _cache = {};

  static Future<void> init() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/sf6_combos.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      data.forEach((charId, list) {
        if (list is List) {
          _cache[charId.toLowerCase()] = list.map((e) => ComboRecipe.fromJson(e as Map<String, dynamic>)).toList();
        }
      });
    } catch (_) {
      // Fallback to built-in presets if json not yet populated or failed to load
    }
  }

  static List<ComboRecipe> getCombosForCharacter(String charId) {
    final key = charId.toLowerCase();
    if (_cache.containsKey(key) && _cache[key]!.isNotEmpty) {
      return _cache[key]!;
    }
    return _getBuiltinCombos(key);
  }

  static List<ComboRecipe> _getBuiltinCombos(String charId) {
    switch (charId) {
      case 'ryu':
        return [
          const ComboRecipe(
            id: 'ryu_1',
            characterId: 'ryu',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HK, dash, 2HP > 623HP',
            position: 'Anywhere',
            damage: '3000',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '无气最强确反起手！对手大升龙/无敌技被防后，5HK造成破绽大崩防硬直，前冲后2HP目押重升龙，稳定3000伤害。',
          ),
          const ComboRecipe(
            id: 'ryu_2',
            characterId: 'ryu',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HK, dash, 2HP > 236KK, 4HK > 623HP',
            position: 'Midscreen',
            damage: '3430',
            driveGauge: '2',
            superGauge: '0',
            difficulty: 'Medium',
            notes: '确反升龙进阶高伤：OD驴踢浮空后接4HK追打，落地前重升龙拳终结。',
          ),
          const ComboRecipe(
            id: 'ryu_3',
            characterId: 'ryu',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5MP, 5HP > 623HP > 236236K',
            position: 'Anywhere',
            damage: '5120',
            driveGauge: '0',
            superGauge: '3',
            difficulty: 'Easy',
            notes: '确反斩杀连：5MP破招确认5HP，取消重升龙拳并在第1段带入真·升龙拳 (SA3/CA)，伤害突破5000+。',
          ),
          const ComboRecipe(
            id: 'ryu_4',
            characterId: 'ryu',
            starterType: 'Drive Impact',
            comboSequence: 'DI, 5HK, 2MK > 214MK',
            position: 'Anywhere',
            damage: '2360',
            driveGauge: '1',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '斗气迸发击中崩防后的稳定民工输出连，推角运板。',
          ),
          const ComboRecipe(
            id: 'ryu_5',
            characterId: 'ryu',
            starterType: 'Drive Impact',
            comboSequence: 'DI (版边撞墙), 2HP > 214KK, 623HP',
            position: 'Corner',
            damage: '2820',
            driveGauge: '2',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '版边迸发撞墙碎防民工连：2HP确认OD龙卷风，落地前重升龙截杀。',
          ),
          const ComboRecipe(
            id: 'ryu_6',
            characterId: 'ryu',
            starterType: 'Normal Hit',
            comboSequence: '2MK > 236MK',
            position: 'Anywhere',
            damage: '1460',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Very Easy',
            notes: '隆经典立回下中脚预输入确认驴踢，中距离牵制绝对核心。',
          ),
          const ComboRecipe(
            id: 'ryu_7',
            characterId: 'ryu',
            starterType: 'Normal Hit',
            comboSequence: '2LK, 2LP, 5LP > 623HP',
            position: 'Anywhere',
            damage: '1490',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '极速下段4F插动起手点三下确认升龙，防近身压制抢招神技。',
          ),
          const ComboRecipe(
            id: 'ryu_8',
            characterId: 'ryu',
            starterType: 'Drive Rush',
            comboSequence: 'DR 5MP, 4HP > 236MK > 236236K',
            position: 'Anywhere',
            damage: '4380',
            driveGauge: '1',
            superGauge: '3',
            difficulty: 'Medium',
            notes: '生绿冲5MP被防+5F有利，命中可从容目押4HP两段腹击，取消驴踢并带入SA3。',
          ),
        ];

      case 'ken':
        return [
          const ComboRecipe(
            id: 'ken_1',
            characterId: 'ken',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HP > DR, 2HP > 5MP > 5HP > 奋迅脚 > 623HP',
            position: 'Anywhere',
            damage: '3480',
            driveGauge: '3',
            superGauge: '0',
            difficulty: 'Medium',
            notes: '肯无敌技确反高伤运板连：5HP破招取消绿冲2HP，接紫电脚TC并疾跑升龙，全屏送入版边。',
          ),
          const ComboRecipe(
            id: 'ken_2',
            characterId: 'ken',
            starterType: 'Normal Hit',
            comboSequence: '5MP > 5HP > 奋迅脚 > 龙尾脚',
            position: 'Anywhere',
            damage: '2400',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '肯核心紫电脚TC确认：无需消耗斗气，全屏把对手推入版边且获得有利起攻压制！',
          ),
          const ComboRecipe(
            id: 'ken_3',
            characterId: 'ken',
            starterType: 'Drive Impact',
            comboSequence: 'DI (撞墙), 2HP > 623HP > 236236P',
            position: 'Corner',
            damage: '4620',
            driveGauge: '1',
            superGauge: '3',
            difficulty: 'Easy',
            notes: '版边迸发撞墙碎防斩杀：重升龙取消神龙拳 (SA3)，伤害拉满。',
          ),
          const ComboRecipe(
            id: 'ken_4',
            characterId: 'ken',
            starterType: 'Normal Hit',
            comboSequence: '2MK > DR, 2LP, 2HP > 奋迅脚 > 龙尾脚',
            position: 'Anywhere',
            damage: '2280',
            driveGauge: '3',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '下中脚取消绿冲核心立回进板连段。',
          ),
        ];

      case 'luke':
        return [
          const ComboRecipe(
            id: 'luke_1',
            characterId: 'luke',
            starterType: 'Punish Counter',
            comboSequence: 'PC 2HP > 214P(完美蓄力), 214P(轻), 623HP',
            position: 'Anywhere',
            damage: '3320',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Medium',
            notes: '卢克招牌无气目押完美蓄力拳高伤连，不耗斗气稳定3320伤害！',
          ),
          const ComboRecipe(
            id: 'luke_2',
            characterId: 'luke',
            starterType: 'Normal Hit',
            comboSequence: '2MK > DR, 2MP, 4HP > 214P(完美蓄力), 623HP',
            position: 'Anywhere',
            damage: '2980',
            driveGauge: '3',
            superGauge: '0',
            difficulty: 'Medium',
            notes: '下中脚绿冲推进确认4HP完美电击拳。',
          ),
          const ComboRecipe(
            id: 'luke_3',
            characterId: 'luke',
            starterType: 'Drive Impact',
            comboSequence: 'DI, 4HP > 214P(完美蓄力), 623HP > 236236K',
            position: 'Corner',
            damage: '4880',
            driveGauge: '1',
            superGauge: '3',
            difficulty: 'Medium',
            notes: '版边崩防斩杀：苍白骑手SA3终结。',
          ),
        ];

      case 'cammy':
        return [
          const ComboRecipe(
            id: 'cammy_1',
            characterId: 'cammy',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HP > DR, 4HP > 4MP > 5HK > 623HK',
            position: 'Anywhere',
            damage: '3420',
            driveGauge: '3',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '嘉米大确反起手：5HP破招接绿冲4HP，取消TC并加农加农钉终结。',
          ),
          const ComboRecipe(
            id: 'cammy_2',
            characterId: 'cammy',
            starterType: 'Normal Hit',
            comboSequence: '2MK > 236HK',
            position: 'Anywhere',
            damage: '1500',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Very Easy',
            notes: '经典下中腿立回确认重螺旋箭，直接击倒进身位压制。',
          ),
          const ComboRecipe(
            id: 'cammy_3',
            characterId: 'cammy',
            starterType: 'Drive Rush',
            comboSequence: 'DR 2MK, 2MP > 236HK > 236236P',
            position: 'Anywhere',
            damage: '4250',
            driveGauge: '1',
            superGauge: '3',
            difficulty: 'Easy',
            notes: '极速生绿冲下中脚偷下盘，接2MP与螺旋箭取消SA3致命蜂刺。',
          ),
        ];

      case 'akuma':
        return [
          const ComboRecipe(
            id: 'akuma_1',
            characterId: 'akuma',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HK, dash, 2HP > 623HP > 214214P',
            position: 'Anywhere',
            damage: '4200',
            driveGauge: '0',
            superGauge: '2',
            difficulty: 'Easy',
            notes: '豪鬼大确反民工连：5HK造成崩防大硬直，前冲2HP接重升龙取消SA2崩天狂涛。',
          ),
          const ComboRecipe(
            id: 'akuma_2',
            characterId: 'akuma',
            starterType: 'Drive Impact',
            comboSequence: 'DI (撞墙), 2HP > 236KK, 623HP',
            position: 'Corner',
            damage: '3150',
            driveGauge: '2',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '版边迸发撞墙：OD波浮空后重升龙截杀。',
          ),
          const ComboRecipe(
            id: 'akuma_3',
            characterId: 'akuma',
            starterType: 'Normal Hit',
            comboSequence: '5MP, 2MP > 236HP > 236236P',
            position: 'Anywhere',
            damage: '3680',
            driveGauge: '0',
            superGauge: '1',
            difficulty: 'Easy',
            notes: '5MP有利拳近距离目押2MP，取消重波带入SA1穿波。',
          ),
        ];

      case 'bison':
        return [
          const ComboRecipe(
            id: 'bison_1',
            characterId: 'bison',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HK > 4蓄6HK > 214P',
            position: 'Anywhere',
            damage: '2980',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '维加确反民工连：5HK破招接膝压并引爆精神炸弹。',
          ),
          const ComboRecipe(
            id: 'bison_2',
            characterId: 'bison',
            starterType: 'Drive Impact',
            comboSequence: 'DI, 5HP > 4蓄6KK, 2蓄8KK',
            position: 'Corner',
            damage: '3650',
            driveGauge: '4',
            superGauge: '0',
            difficulty: 'Medium',
            notes: '版边OD双重膝压浮空，接恶魔倒转压制。',
          ),
        ];

      case 'terry':
        return [
          const ComboRecipe(
            id: 'terry_1',
            characterId: 'terry',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HP > 214HP > 236236P',
            position: 'Anywhere',
            damage: '4750',
            driveGauge: '0',
            superGauge: '3',
            difficulty: 'Easy',
            notes: '特瑞大确反斩杀连：5HP破招直接取消燃烧指节，带入Buster Wolf狂狼之爪 (SA3)。',
          ),
          const ComboRecipe(
            id: 'terry_2',
            characterId: 'terry',
            starterType: 'Normal Hit',
            comboSequence: '2MK > 41236HK > 214HK',
            position: 'Anywhere',
            damage: '2350',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '经典下中腿立回确认能量升击与裂破落。',
          ),
        ];

      case 'chunli':
        return [
          const ComboRecipe(
            id: 'chunli_1',
            characterId: 'chunli',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HP > 行云流水构 > 构MK > 236KK, 22HK',
            position: 'Anywhere',
            damage: '3280',
            driveGauge: '2',
            superGauge: '0',
            difficulty: 'Medium',
            notes: '春丽招牌构连段：5HP破招切入行云流水构，派生中踢接OD百裂脚与重天升脚对空。',
          ),
          const ComboRecipe(
            id: 'chunli_2',
            characterId: 'chunli',
            starterType: 'Normal Hit',
            comboSequence: '2MK > 4蓄6MP',
            position: 'Anywhere',
            damage: '1200',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '春丽最强下段牵制：蹲中腿预输入气功拳。',
          ),
        ];

      case 'guile':
        return [
          const ComboRecipe(
            id: 'guile_1',
            characterId: 'guile',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HK > 4蓄6HP > 4蓄646P',
            position: 'Anywhere',
            damage: '3880',
            driveGauge: '0',
            superGauge: '1',
            difficulty: 'Easy',
            notes: '古烈重脚确反手刀带入音速飓风SA1。',
          ),
          const ComboRecipe(
            id: 'guile_2',
            characterId: 'guile',
            starterType: 'Normal Hit',
            comboSequence: '2MP, 2MP > 2蓄8HK',
            position: 'Anywhere',
            damage: '2420',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '双蹲中拳目押脚刀，经典铁壁反击。',
          ),
        ];

      case 'zangief':
        return [
          const ComboRecipe(
            id: 'zangief_1',
            characterId: 'zangief',
            starterType: 'Punish Counter',
            comboSequence: 'PC 6HP, 2MP > PP',
            position: 'Anywhere',
            damage: '2650',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '地狱头槌破招造成巨幅有利，目押2MP取消双重套索。',
          ),
          const ComboRecipe(
            id: 'zangief_2',
            characterId: 'zangief',
            starterType: 'Drive Impact',
            comboSequence: 'DI (撞墙), 360HP',
            position: 'Corner',
            damage: '3300',
            driveGauge: '1',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '版边迸发碎防，对手下落瞬间输入重螺旋打桩机(SPD)瞬杀3300血！',
          ),
        ];

      case 'juri':
        return [
          const ComboRecipe(
            id: 'juri_1',
            characterId: 'juri',
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HP > DR, 2HP > 214HK, 623HP',
            position: 'Anywhere',
            damage: '3350',
            driveGauge: '3',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '韩蛛俐确反5HP接绿冲2HP，存风破气并重升龙风火轮终结。',
          ),
          const ComboRecipe(
            id: 'juri_2',
            characterId: 'juri',
            starterType: 'Normal Hit',
            comboSequence: '2MK > 236MK',
            position: 'Anywhere',
            damage: '1580',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Very Easy',
            notes: '核心下中腿突进暗剑杀立回。',
          ),
        ];

      default:
        return [
          ComboRecipe(
            id: '${charId}_1',
            characterId: charId,
            starterType: 'Punish Counter',
            comboSequence: 'PC 5HP > 623P > 236236P',
            position: 'Anywhere',
            damage: '4200',
            driveGauge: '0',
            superGauge: '3',
            difficulty: 'Easy',
            notes: '角色标准确反大招终结连段。',
          ),
          ComboRecipe(
            id: '${charId}_2',
            characterId: charId,
            starterType: 'Normal Hit',
            comboSequence: '2MK > 236P',
            position: 'Anywhere',
            damage: '1350',
            driveGauge: '0',
            superGauge: '0',
            difficulty: 'Very Easy',
            notes: '地面核心下中脚立回牵制确认必杀技。',
          ),
          ComboRecipe(
            id: '${charId}_3',
            characterId: charId,
            starterType: 'Drive Impact',
            comboSequence: 'DI (撞墙), 2HP > 623P',
            position: 'Corner',
            damage: '2800',
            driveGauge: '1',
            superGauge: '0',
            difficulty: 'Easy',
            notes: '版边迸发撞墙碎防民工连。',
          ),
        ];
    }
  }
}
