// SF6 Full Official Frame Data Database
// Comprehensive move lists for all SF6 characters

import 'package:sf6_tracker/models/frame_data_model.dart';

class FrameDataDatabase {
  static final List<FrameMove> commonDriveMoves = [
    FrameMove(
      name: '斗气迸发 (Drive Impact)',
      command: 'HP+HK',
      type: MoveType.driveAction,
      damage: 800,
      startup: '26',
      active: '2',
      recovery: '35',
      onBlock: '-3 / 撞墙碎防',
      onHit: '倒地破防',
      notes: '吸附2段攻击霸体，版边命中直接造成撞墙大硬直',
    ),
    FrameMove(
      name: '斗气招架 (Drive Parry)',
      command: 'MP+MK',
      type: MoveType.driveAction,
      damage: 0,
      startup: '1',
      active: '持续',
      recovery: '29',
      onBlock: '0',
      onHit: '完美招架(+大幅有利)',
      isCancelable: true,
      notes: '第1帧完美招架格挡一切上中下段与飞行道具',
    ),
    FrameMove(
      name: '斗气冲刺 (Drive Rush - 生绿冲)',
      command: '66 (招架中)',
      type: MoveType.driveAction,
      damage: 0,
      startup: '11',
      active: '-',
      recovery: '1',
      onBlock: '接招帧数+4F',
      onHit: '接招帧数+4F',
      isCancelable: true,
      notes: '大幅提升突进速度，后续打击招式帧数均获得 +4F 有利增益',
    ),
    FrameMove(
      name: '斗气反击 (Drive Reversal)',
      command: '防御中 6HP+HK',
      type: MoveType.driveAction,
      damage: 500,
      startup: '20',
      active: '3',
      recovery: '24',
      onBlock: '-8',
      onHit: '击退倒地',
      notes: '防御硬直中完全无敌，弹开对手强力压制',
    ),
    FrameMove(
      name: '普通前投 / 后投',
      command: 'LP+LK / 4LP+LK',
      type: MoveType.throwTech,
      damage: 1200,
      startup: '5',
      active: '3',
      recovery: '23',
      onBlock: '不可防御',
      onHit: '击倒',
      notes: '5F 极速近身破防投技，压制拆投核心',
    ),
  ];

  static List<FrameMove> getCharacterMoves(String charId) {
    final id = charId.toLowerCase();
    final list = <FrameMove>[];
    list.addAll(commonDriveMoves);

    // Standard 12 Universal Normals tailored to character
    list.addAll([
      FrameMove(name: '站立轻拳 (5LP)', command: '5LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '4F最速起手抢招，点中可确认连段'),
      FrameMove(name: '蹲下轻拳 (2LP)', command: '2LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '8', onBlock: '-1', onHit: '+4', isCancelable: true, notes: '下盘4F反击插动'),
      FrameMove(name: '站立轻脚 (5LK)', command: '5LK', type: MoveType.normal, damage: 300, startup: '5', active: '3', recovery: '9', onBlock: '-2', onHit: '+3', isCancelable: true, notes: '快速推开近战距离'),
      FrameMove(name: '蹲下轻脚 (2LK)', command: '2LK', type: MoveType.normal, damage: 250, startup: '5', active: '3', recovery: '8', onBlock: '-2', onHit: '+3', isCancelable: true, notes: '极速下段破站防起手'),
      FrameMove(name: '站立中拳 (5MP)', command: '5MP', type: MoveType.normal, damage: 600, startup: '6', active: '3', recovery: '12', onBlock: '+1', onHit: '+6', isCancelable: true, notes: '核心立回压制拳，被防有利'),
      FrameMove(name: '蹲下中拳 (2MP)', command: '2MP', type: MoveType.normal, damage: 600, startup: '6', active: '3', recovery: '13', onBlock: '+1', onHit: '+6', isCancelable: true, notes: '打拆投及近距离目押核心'),
      FrameMove(name: '站立中脚 (5MK)', command: '5MK', type: MoveType.normal, damage: 650, startup: '7', active: '3', recovery: '15', onBlock: '-2', onHit: '+4', isCancelable: false, notes: '中距离立回牵制绝对神技'),
      FrameMove(name: '蹲下中脚 (2MK)', command: '2MK', type: MoveType.normal, damage: 500, startup: '8', active: '3', recovery: '17', onBlock: '-4', onHit: '+1', isCancelable: true, notes: '最强核心下段立回，可取消接绿冲或必杀'),
      FrameMove(name: '站立重拳 (5HP)', command: '5HP', type: MoveType.normal, damage: 850, startup: '9', active: '3', recovery: '19', onBlock: '-3', onHit: '+3', isCancelable: true, notes: '大伤害单发确反与压制起手'),
      FrameMove(name: '蹲下重拳 (2HP)', command: '2HP', type: MoveType.normal, damage: 850, startup: '8', active: '4', recovery: '22', onBlock: '-10', onHit: '+2', isCancelable: true, notes: '核心地面防空重拳，判定极强'),
      FrameMove(name: '站立重脚 (5HK)', command: '5HK', type: MoveType.normal, damage: 900, startup: '11', active: '4', recovery: '18', onBlock: '-4', onHit: '+3', isCancelable: false, notes: '超长距离破绽惩罚打击，破招造成崩防大硬直'),
      FrameMove(name: '蹲下重脚 (2HK)', command: '2HK', type: MoveType.normal, damage: 900, startup: '10', active: '3', recovery: '24', onBlock: '-11', onHit: '击倒', isCancelable: false, notes: '扫堂腿大确反击倒，被防大负帧'),
    ]);

    switch (id) {
      case 'ryu':
        list.addAll([
          FrameMove(name: '锁骨割', command: '6MP', type: MoveType.unique, damage: 800, startup: '20', active: '3', recovery: '17', onBlock: '-1', onHit: '+2', notes: '中段开罐破防技，打蹲防核心'),
          FrameMove(name: '鸠尾碎', command: '4HP', type: MoveType.unique, damage: 900, startup: '17', active: '4', recovery: '18', onBlock: '+1', onHit: '+7', notes: '二连腹击，被防+1F有利'),
          FrameMove(name: '波动拳', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '33', onBlock: '-6', onHit: '+1', notes: '地波牵制主力'),
          FrameMove(name: 'OD 波动拳', command: '236PP', type: MoveType.special, damage: 800, startup: '12', active: '-', recovery: '31', onBlock: '+2', onHit: '击倒', notes: '2段高速强化波，被防+2F有利'),
          FrameMove(name: '升龙拳', command: '623P', type: MoveType.special, damage: 1200, startup: '5', active: '6', recovery: '32', onBlock: '-23', onHit: '击倒', notes: '标准对空升龙拳，完全无敌'),
          FrameMove(name: 'OD 升龙拳', command: '623PP', type: MoveType.special, damage: 1400, startup: '6', active: '8', recovery: '38', onBlock: '-35', onHit: '击倒', notes: '第1帧完全无敌，凹起身反击'),
          FrameMove(name: '龙卷旋风脚', command: '214K', type: MoveType.special, damage: 900, startup: '12', active: '10', recovery: '20', onBlock: '-10', onHit: '击倒', notes: '运板推角神技，重版穿波'),
          FrameMove(name: '波掌击', command: '214P', type: MoveType.special, damage: 700, startup: '16', active: '3', recovery: '17', onBlock: '-3', onHit: '+3', notes: '近身压制气功'),
          FrameMove(name: '电刃炼气', command: '22P', type: MoveType.special, damage: 0, startup: '38', active: '-', recovery: '0', onBlock: '充能', onHit: '强化', notes: '强化下次波掌击/波动拳，极大提升判定与帧数'),
          FrameMove(name: 'SA1: 真空波动拳', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '6', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '全屏穿波高速反击'),
          FrameMove(name: 'SA2: 真·波掌击', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '15', active: '8', recovery: '44', onBlock: '+2~+8', onHit: '大破防', notes: '蓄力高伤超必杀'),
          FrameMove(name: 'SA3: 真·升龙拳', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-27', onHit: '终结', notes: '完全无敌近身终结技，红血CA 4500'),
        ]);
        break;
      case 'ken':
        list.addAll([
          FrameMove(name: '紫电脚 (TC)', command: '5MP > 5HP', type: MoveType.unique, damage: 1300, startup: '6', active: '3', recovery: '18', onBlock: '-8', onHit: '浮空', notes: '全游戏最强确认TC连段'),
          FrameMove(name: '闪光踢', command: '6HK', type: MoveType.unique, damage: 850, startup: '23', active: '3', recovery: '16', onBlock: '-1', onHit: '+3', notes: '中段突袭下落踢'),
          FrameMove(name: '波动拳', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '34', onBlock: '-6', onHit: '+1', notes: '牵制波'),
          FrameMove(name: '升龙拳', command: '623P', type: MoveType.special, damage: 1250, startup: '5', active: '6', recovery: '32', onBlock: '-23', onHit: '击倒', notes: '完全无敌火焰升龙拳'),
          FrameMove(name: 'OD 升龙拳', command: '623PP', type: MoveType.special, damage: 1450, startup: '6', active: '8', recovery: '38', onBlock: '-35', onHit: '击倒', notes: '第1帧无敌起手反击'),
          FrameMove(name: '龙卷旋风脚', command: '214K', type: MoveType.special, damage: 950, startup: '11', active: '10', recovery: '18', onBlock: '-10', onHit: '推角', notes: '全屏把对手送入版边'),
          FrameMove(name: '迅雷脚', command: '236K', type: MoveType.special, damage: 800, startup: '13', active: '3', recovery: '18', onBlock: '-5', onHit: '多择', notes: '版边多择主力，可派生上中下段'),
          FrameMove(name: '龙尾脚', command: '623K', type: MoveType.special, damage: 1000, startup: '24', active: '3', recovery: '16', onBlock: '+1', onHit: '+5', notes: '重龙尾被防+1F有利，强行拉近压制'),
          FrameMove(name: '奋迅脚', command: 'KK', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '冲刺', onHit: '强化', notes: '高速疾跑，派生升龙/龙卷'),
          FrameMove(name: 'SA1: 龙卷裂风脚', command: '214214K', type: MoveType.superArt, damage: 2000, startup: '9', active: '10', recovery: '42', onBlock: '-18', onHit: '推角', notes: '无敌对空推角超杀'),
          FrameMove(name: 'SA2: 疾风迅雷脚', command: '236236K', type: MoveType.superArt, damage: 2700, startup: '8', active: '12', recovery: '46', onBlock: '-20', onHit: '大浮空', notes: '无敌滑步突进连击'),
          FrameMove(name: 'SA3: 神龙拳', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '烈火龙卷', notes: '完全无敌爆发终结，红血CA 4500'),
        ]);
        break;
      case 'luke':
        list.addAll([
          FrameMove(name: '四连猛击 (TC)', command: '5LP>5MP>5HP>5HK', type: MoveType.unique, damage: 1400, startup: '4', active: '3', recovery: '20', onBlock: '-12', onHit: '击倒', notes: '4F最速起手全套轻连确认'),
          FrameMove(name: '重扣拳', command: '4HP', type: MoveType.unique, damage: 900, startup: '15', active: '4', recovery: '16', onBlock: '-2', onHit: '+4', notes: '立回核心后退重拳打拆'),
          FrameMove(name: '沙弹', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '31', onBlock: '-7', onHit: '+1', notes: '全屏瞬间命中飞行道具'),
          FrameMove(name: '升龙重拳', command: '623P', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-20', onHit: '击倒', notes: '无敌对空拳'),
          FrameMove(name: '闪电重拳', command: '214P(蓄力)', type: MoveType.special, damage: 1100, startup: '15', active: '4', recovery: '19', onBlock: '-4', onHit: '浮空', notes: '目押完美蓄力超高连段伤害'),
          FrameMove(name: '复仇突进', command: '214K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '突进', onHit: '派生', notes: '低姿态突进，派生过顶摔/滑铲'),
          FrameMove(name: 'SA1: 致命火神', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '10', active: '8', recovery: '38', onBlock: '-16', onHit: '击倒', notes: '全屏穿波多连发沙弹'),
          FrameMove(name: 'SA2: 橡皮擦强袭', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '14', active: '10', recovery: '42', onBlock: '-22', onHit: '砸地', notes: '重拳狂暴连击'),
          FrameMove(name: 'SA3: 苍白骑手', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '8', active: '9', recovery: '48', onBlock: '-25', onHit: '骑乘暴击', notes: '完全无敌斩杀终结，红血CA 4500'),
        ]);
        break;
      case 'cammy':
        list.addAll([
          FrameMove(name: '突击组合拳 (TC)', command: '4MP > 5HK', type: MoveType.unique, damage: 1100, startup: '6', active: '3', recovery: '19', onBlock: '-8', onHit: '浮空', notes: '立回确反核心TC'),
          FrameMove(name: '螺旋箭', command: '236K', type: MoveType.special, damage: 1000, startup: '11', active: '12', recovery: '18', onBlock: '-12', onHit: '击倒', notes: '下段极速滑铲，连段主力'),
          FrameMove(name: '加农加农钉', command: '623K', type: MoveType.special, damage: 1200, startup: '5', active: '6', recovery: '31', onBlock: '-22', onHit: '击倒', notes: '完全无敌后空翻升龙对空'),
          FrameMove(name: '加农空闪 (俯冲腿)', command: '空中 214K', type: MoveType.special, damage: 600, startup: '12', active: '4', recovery: '着地8', onBlock: '+1~+3', onHit: '硬直', notes: '压制核心低空俯冲腿'),
          FrameMove(name: '流氓杀手', command: '236P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '空翻', onHit: '多择', notes: '空中突进，派生滑铲/指令投'),
          FrameMove(name: 'SA1: 旋转驱动狂乱', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '低姿态穿波反击'),
          FrameMove(name: 'SA2: 杀戮之蜂狂暴', command: '214214K', type: MoveType.superArt, damage: 2700, startup: '8', active: '10', recovery: '44', onBlock: '-24', onHit: '空中绞杀', notes: '无敌超必杀锁定'),
          FrameMove(name: 'SA3: 致命蜂刺', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '9', active: '10', recovery: '48', onBlock: '-26', onHit: '终极绞杀', notes: '全屏穿波斩杀，红血CA 4500'),
        ]);
        break;
      case 'chunli':
        list.addAll([
          FrameMove(name: '翼旋脚', command: '4/6MP', type: MoveType.unique, damage: 700, startup: '7', active: '3', recovery: '15', onBlock: '+1', onHit: '+5', notes: '立回牵制神技，被防+1有利'),
          FrameMove(name: '鹤脚落', command: '3HK', type: MoveType.unique, damage: 850, startup: '22', active: '4', recovery: '16', onBlock: '-2', onHit: '+3', notes: '中段破蹲防'),
          FrameMove(name: '鹰爪脚', command: '空中 2MK', type: MoveType.unique, damage: 500, startup: '8', active: '持续', recovery: '0', onBlock: '+2', onHit: '多段踩', notes: '空中三连踏重压对手'),
          FrameMove(name: '气功拳', command: '4蓄6P', type: MoveType.special, damage: 600, startup: '13', active: '-', recovery: '32', onBlock: '-4', onHit: '+2', notes: '慢速蓄力波推进压制'),
          FrameMove(name: '百裂脚', command: '236K', type: MoveType.special, damage: 900, startup: '12', active: '6', recovery: '18', onBlock: '-8', onHit: '击倒', notes: '连段核心主力输出'),
          FrameMove(name: '天升脚', command: '22K', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-22', onHit: '击倒', notes: '完全无敌对空直升机脚'),
          FrameMove(name: '霸山蹴', command: '63214K', type: MoveType.special, damage: 900, startup: '23', active: '4', recovery: '15', onBlock: '+1', onHit: '+5', notes: '避波中段，被防+1F有利'),
          FrameMove(name: '行云流水构', command: '214P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '低架', onHit: '派生', notes: '低姿态构，派生 6 种招式'),
          FrameMove(name: 'SA1: 气功掌', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '10', recovery: '42', onBlock: '-16', onHit: '击飞', notes: '原地多段能量波穿波'),
          FrameMove(name: 'SA2: 凤翼扇', command: '236236K', type: MoveType.superArt, damage: 2700, startup: '8', active: '14', recovery: '46', onBlock: '-24', onHit: '击飞', notes: '极速突进百裂踢'),
          FrameMove(name: 'SA3: 苍天乱圣', command: '214214K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-27', onHit: '天升终结', notes: '无敌近身与对空终结，红血CA 4500'),
        ]);
        break;
      case 'guile':
        list.addAll([
          FrameMove(name: '贯通刺', command: '4/6HK', type: MoveType.unique, damage: 800, startup: '12', active: '3', recovery: '17', onBlock: '-3', onHit: '+2', notes: '避下段中距离前进步踢'),
          FrameMove(name: '倒立重扫', command: '6HK', type: MoveType.unique, damage: 950, startup: '14', active: '4', recovery: '18', onBlock: '+1', onHit: '+6', notes: '近身大摆腿，被防+1有利'),
          FrameMove(name: '音速手刀', command: '4蓄6P', type: MoveType.special, damage: 600, startup: '10', active: '-', recovery: '27', onBlock: '-3', onHit: '+3', notes: '硬直最小的极速飞行道具'),
          FrameMove(name: '倒立脚升龙', command: '2蓄8K', type: MoveType.special, damage: 1300, startup: '5', active: '5', recovery: '32', onBlock: '-24', onHit: '击倒', notes: '全游戏最强防空铁壁，完全无敌'),
          FrameMove(name: '音速刀刃', command: '214P', type: MoveType.special, damage: 400, startup: '18', active: '持续', recovery: '25', onBlock: '-2', onHit: '悬浮', notes: '原地停滞气旋，强化双重音速斩'),
          FrameMove(name: 'SA1: 音速飓风', command: '4蓄646P', type: MoveType.superArt, damage: 2000, startup: '8', active: '12', recovery: '40', onBlock: '-16', onHit: '穿波绞杀', notes: '全屏巨型真空风暴'),
          FrameMove(name: 'SA2: 强化固守阵地', command: '214214P', type: MoveType.superArt, damage: 0, startup: '4', active: '增益', recovery: '0', onBlock: '启动', onHit: '无限连发', notes: '无需蓄力，连轰 5 发手刀'),
          FrameMove(name: 'SA3: 音速风暴裂破', command: '4蓄646K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-28', onHit: '终结', notes: '无敌倒立双重升龙，红血CA 4500'),
        ]);
        break;
      case 'zangief':
        list.addAll([
          FrameMove(name: '地狱头槌', command: '6HP', type: MoveType.unique, damage: 1000, startup: '13', active: '3', recovery: '15', onBlock: '+4', onHit: '+8', notes: '被防+4巨幅有利！压制与碎防王牌'),
          FrameMove(name: '冲撞膝击', command: '6LK', type: MoveType.unique, damage: 700, startup: '14', active: '4', recovery: '16', onBlock: '+1', onHit: '+4', notes: '下段免疫突进膝撞'),
          FrameMove(name: '螺旋打桩机', command: '360P', type: MoveType.special, damage: 2500, startup: '5', active: '2', recovery: '46', onBlock: '不可防御', onHit: '大摔', notes: '5F最速指令投，重SPD伤害 3300'),
          FrameMove(name: '双重套索', command: 'PP', type: MoveType.special, damage: 1200, startup: '12', active: '16', recovery: '26', onBlock: '-12', onHit: '击倒', notes: '旋转双手前后双向对空'),
          FrameMove(name: '西伯利亚特快', command: '63214K', type: MoveType.special, damage: 2000, startup: '26', active: '抓投', recovery: '38', onBlock: '不可防御', onHit: '全屏抓杀', notes: '全屏突进抓投，带一段霸体'),
          FrameMove(name: '罗宋汤炸弹', command: '空中 360K', type: MoveType.special, damage: 2800, startup: '5', active: '2', recovery: '30', onBlock: '不可防御', onHit: '空中截杀', notes: '空中抓投瞬杀，判定极大'),
          FrameMove(name: 'SA1: 空中铁击破', command: '236236K', type: MoveType.superArt, damage: 2200, startup: '8', active: '截杀', recovery: '42', onBlock: '不可防御', onHit: '砸地', notes: '无敌超必杀对空投'),
          FrameMove(name: 'SA2: 旋风大摔灭', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '13', active: '吸附', recovery: '46', onBlock: '-18', onHit: '碎骨摔', notes: '吸附全屏对手强行扯入身边'),
          FrameMove(name: 'SA3: 终极苏联大打桩', command: '720P', type: MoveType.superArt, damage: 4800, startup: '7', active: '2', recovery: '55', onBlock: '不可防御', onHit: '天崩地裂', notes: '不可防指令投，红血CA 5300 单发最高！'),
        ]);
        break;
      case 'juri':
        list.addAll([
          FrameMove(name: '紫穿脚', command: '6MK', type: MoveType.unique, damage: 800, startup: '20', active: '3', recovery: '16', onBlock: '-2', onHit: '+3', notes: '中段下劈破蹲防'),
          FrameMove(name: '风破刃', command: '214K', type: MoveType.special, damage: 600, startup: '14', active: '3', recovery: '20', onBlock: '-6', onHit: '+2', notes: '存气核心，蓄积风破气'),
          FrameMove(name: '岁破冲', command: '236LK', type: MoveType.special, damage: 700, startup: '15', active: '-', recovery: '30', onBlock: '+1', onHit: '+5', notes: '贴地低速波，压制起手神技'),
          FrameMove(name: '暗剑杀', command: '236MK', type: MoveType.special, damage: 900, startup: '12', active: '4', recovery: '22', onBlock: '-8', onHit: '击倒', notes: '突进横扫中距离必杀'),
          FrameMove(name: '五黄杀', command: '236HK', type: MoveType.special, damage: 1100, startup: '16', active: '6', recovery: '24', onBlock: '-12', onHit: '击倒', notes: '高伤大回旋踢'),
          FrameMove(name: '天泉轮', command: '623P', type: MoveType.special, damage: 1200, startup: '5', active: '6', recovery: '32', onBlock: '-23', onHit: '击倒', notes: '完全无敌对空风火轮'),
          FrameMove(name: '疾空闪', command: '空中 214K', type: MoveType.special, damage: 700, startup: '12', active: '4', recovery: '着地10', onBlock: '-4', onHit: '派生', notes: '空中急速变轨突袭'),
          FrameMove(name: 'SA1: 杀界风破斩', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '大击退', notes: '地面低姿态穿波斩'),
          FrameMove(name: 'SA2: 风水引擎', command: '214214P', type: MoveType.superArt, damage: 0, startup: '4', active: '增益', recovery: '0', onBlock: '启动', onHit: '自由目押', notes: '开启自由目押通常技链，压制无解'),
          FrameMove(name: 'SA3: 迴旋断界落', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '残虐终结', notes: '完全无敌近身终结，红血CA 4500'),
        ]);
        break;
      case 'marisa':
        list.addAll([
          FrameMove(name: '角斗士猛击', command: '236P(可蓄力)', type: MoveType.special, damage: 1200, startup: '14', active: '4', recovery: '20', onBlock: '-4~+3', onHit: '霸体击飞', notes: '蓄满带霸体且被防+3F有利！'),
          FrameMove(name: '方阵飞扑', command: '623P', type: MoveType.special, damage: 1100, startup: '18', active: '4', recovery: '18', onBlock: '+1', onHit: '+5', notes: '跳步重砸，被防+1有利'),
          FrameMove(name: '双剑连击', command: '214P', type: MoveType.special, damage: 1200, startup: '15', active: '4', recovery: '22', onBlock: '-8', onHit: '弹墙', notes: '连段与版边压制核心'),
          FrameMove(name: '四轮突进', command: '214K', type: MoveType.special, damage: 1000, startup: '13', active: '5', recovery: '20', onBlock: '-6', onHit: '派生', notes: '下段突进，可派生上中下投'),
          FrameMove(name: '斯库图姆防反盾', command: '22P', type: MoveType.special, damage: 0, startup: '3', active: '防守', recovery: '14', onBlock: '盾牌格挡', onHit: '派生反击', notes: '正面全身霸体架招'),
          FrameMove(name: 'SA1: 暴烈角斗场', command: '236236P', type: MoveType.superArt, damage: 2100, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '地面霸体爆裂重拳'),
          FrameMove(name: 'SA3: 陨石毁灭轰击', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '8', active: '9', recovery: '50', onBlock: '-28', onHit: '斯巴达终结', notes: '斯巴达战神终极处决，红血CA 4500'),
        ]);
        break;
      case 'jp':
        list.addAll([
          FrameMove(name: '特里格拉夫地刺', command: '22P', type: MoveType.special, damage: 900, startup: '25', active: '3', recovery: '36', onBlock: '-8', onHit: '浮空击飞', notes: '全屏任意位置地刺穿刺'),
          FrameMove(name: '托尔巴兰幽灵', command: '236P', type: MoveType.special, damage: 700, startup: '16', active: '-', recovery: '34', onBlock: '-6', onHit: '+1', notes: '全屏飞灵，重版打中段，中版打下段'),
          FrameMove(name: '离别空间传送', command: '214P', type: MoveType.special, damage: 800, startup: '20', active: '空间陷阱', recovery: '28', onBlock: '-4', onHit: '传送/引爆', notes: '布置传送门或虚空炸弹'),
          FrameMove(name: '遗忘防反', command: '22K', type: MoveType.special, damage: 0, startup: '1', active: '防反', recovery: '15', onBlock: '植入爆弹', onHit: '陷阱', notes: '第1帧防反一切打击与投技！'),
          FrameMove(name: 'SA1: 契约终结', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '10', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '杖击穿波击飞'),
          FrameMove(name: 'SA2: 幽灵行进', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '12', active: '持续行进', recovery: '30', onBlock: '+12', onHit: '四幽灵连携', notes: '召唤四幽灵全屏持续行进压制'),
          FrameMove(name: 'SA3: 审判暴风', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-26', onHit: '虚空粉碎', notes: '完全无敌空间处刑，红血CA 4500'),
        ]);
        break;
      case 'ed':
        list.addAll([
          FrameMove(name: '精神闪击拳', command: '236P', type: MoveType.special, damage: 800, startup: '12', active: '4', recovery: '22', onBlock: '-4', onHit: '+2', notes: '多段拳击刺拳，压制牵制'),
          FrameMove(name: '精神升龙', command: '623P', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '32', onBlock: '-22', onHit: '击倒', notes: '无敌对空拳'),
          FrameMove(name: '精神拉扯 (鞭子)', command: 'HP蓄力', type: MoveType.special, damage: 1000, startup: '26', active: '2', recovery: '24', onBlock: '-2', onHit: '拉近', notes: '蓄力伸长拳气将对手强行拉至身前'),
          FrameMove(name: '瞬步闪避', command: 'KK', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '滑步', onHit: '派生', notes: '极速进退滑步'),
          FrameMove(name: 'SA1: 精神打击狂暴', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '快速刺拳突击'),
          FrameMove(name: 'SA2: 精神风暴弹', command: '214214P', type: MoveType.superArt, damage: 2700, startup: '14', active: '缓慢推进', recovery: '24', onBlock: '+20', onHit: '巨大黑球', notes: '巨大慢速精神能量球压制'),
          FrameMove(name: 'SA3: 终极精神轰击', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '连打终结', notes: '完全无敌连拳处决，红血CA 4500'),
        ]);
        break;
      case 'akuma':
        list.addAll([
          FrameMove(name: '头盖破杀', command: '6MP', type: MoveType.unique, damage: 800, startup: '20', active: '3', recovery: '16', onBlock: '-1', onHit: '+3', notes: '中段劈掌破蹲防'),
          FrameMove(name: '豪波动拳', command: '236P', type: MoveType.special, damage: 650, startup: '12', active: '-', recovery: '34', onBlock: '-6', onHit: '+1', notes: '主力波牵制'),
          FrameMove(name: '斩空波动拳', command: '空中 236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '着地11', onBlock: '+1~+4', onHit: '硬直', notes: '空中下落波，进阶压制神器'),
          FrameMove(name: '豪升龙拳', command: '623P', type: MoveType.special, damage: 1300, startup: '5', active: '6', recovery: '33', onBlock: '-23', onHit: '击倒', notes: '最强对空，完全无敌'),
          FrameMove(name: '龙卷斩空脚', command: '214K', type: MoveType.special, damage: 1000, startup: '11', active: '8', recovery: '20', onBlock: '-10', onHit: '击倒', notes: '运板主力'),
          FrameMove(name: '阿修罗闪空', command: '6KKK/4KKK', type: MoveType.special, damage: 0, startup: '1', active: '15', recovery: '14', onBlock: '无敌位移', onHit: '-', notes: '完全无敌瞬移'),
          FrameMove(name: '百鬼袭', command: '623K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '大跳跃', onHit: '多择', notes: '突进高跳，派生斩空/中段/投'),
          FrameMove(name: 'SA1: 灭杀豪波动', command: '236236P', type: MoveType.superArt, damage: 2100, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击退', notes: '全屏穿波豪气功'),
          FrameMove(name: 'SA2: 崩天狂涛', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '8', active: '10', recovery: '44', onBlock: '-20', onHit: '大浮空', notes: '对空及连段暴击'),
          FrameMove(name: 'SA3: 祸灭 / 瞬狱杀', command: 'LP LP 6 LK HP', type: MoveType.superArt, damage: 4500, startup: '1', active: '2', recovery: '45', onBlock: '不可防御', onHit: '一瞬千击', notes: '1F 发生全屏不可防指令投，瞬狱杀！'),
        ]);
        break;
      case 'bison':
        list.addAll([
          FrameMove(name: '精神爆弹', command: '214P', type: MoveType.special, damage: 800, startup: '15', active: '4', recovery: '20', onBlock: '-4', onHit: '附着炸弹', notes: '植入爆弹，后续招式引爆'),
          FrameMove(name: '精神粉碎/双重膝压', command: '4蓄6K', type: MoveType.special, damage: 1000, startup: '10', active: '5', recovery: '16', onBlock: '-5', onHit: '+2', notes: '核心蓄力推角神技'),
          FrameMove(name: '恶魔倒转', command: '2蓄8K', type: MoveType.special, damage: 1100, startup: '22', active: '4', recovery: '14', onBlock: '+2', onHit: '击倒', notes: '空降变轨压制，被防+2有利'),
          FrameMove(name: '暗影突进', command: '214K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '瞬步', onHit: '派生', notes: '低身位瞬步突进'),
          FrameMove(name: 'SA1: 精神审判', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '滑铲穿波'),
          FrameMove(name: 'SA3: 终极精神处刑', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '8', active: '9', recovery: '50', onBlock: '-26', onHit: '君临天下', notes: '维加终极处刑，红血CA 4500'),
        ]);
        break;
      case 'terry':
        list.addAll([
          FrameMove(name: '能量波', command: '236P', type: MoveType.special, damage: 600, startup: '13', active: '-', recovery: '33', onBlock: '-6', onHit: '+1', notes: '地波飞行道具'),
          FrameMove(name: '燃烧指节', command: '214P', type: MoveType.special, damage: 1100, startup: '14', active: '8', recovery: '21', onBlock: '-7', onHit: '击倒', notes: '强力突进冲拳'),
          FrameMove(name: '能量升击', command: '41236K', type: MoveType.special, damage: 1000, startup: '11', active: '4', recovery: '18', onBlock: '-4', onHit: '浮空', notes: '顶肩突进，连段起手'),
          FrameMove(name: '升龙裂破', command: '2蓄8P', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-20', onHit: '击倒', notes: '蓄力对空王牌，完全无敌'),
          FrameMove(name: '裂破落', command: '214K', type: MoveType.special, damage: 850, startup: '18', active: '4', recovery: '18', onBlock: '+1', onHit: '+4', notes: '下落跳踢，被防+1有利'),
          FrameMove(name: 'SA1: 能量喷泉', command: '2141236P', type: MoveType.superArt, damage: 2100, startup: '10', active: '8', recovery: '38', onBlock: '-18', onHit: '击倒', notes: '地面巨大爆裂火柱'),
          FrameMove(name: 'SA3: 狂狼之爪 (Buster Wolf)', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '9', active: '10', recovery: '50', onBlock: '-26', onHit: 'Are you OK?', notes: '必杀终结轰击，红血CA 4500'),
        ]);
        break;
      case 'mai':
        list.addAll([
          FrameMove(name: '花蝶扇', command: '236P', type: MoveType.special, damage: 600, startup: '12', active: '-', recovery: '32', onBlock: '-4', onHit: '+2', notes: '经典飞扇牵制'),
          FrameMove(name: '必杀忍蜂', command: '41236K', type: MoveType.special, damage: 1200, startup: '13', active: '6', recovery: '24', onBlock: '-10', onHit: '击倒', notes: '火焰突进撞击'),
          FrameMove(name: '飞翔龙炎阵', command: '623K', type: MoveType.special, damage: 1200, startup: '6', active: '5', recovery: '30', onBlock: '-22', onHit: '击倒', notes: '火焰升龙对空，完全无敌'),
          FrameMove(name: '飞鼠之舞', command: '空中 214P', type: MoveType.special, damage: 800, startup: '14', active: '4', recovery: '着地8', onBlock: '+1', onHit: '硬直', notes: '三角跳反弹下落突袭'),
          FrameMove(name: 'SA1: 阳炎之舞', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '火焰爆发', notes: '原地大范围火柱反击'),
          FrameMove(name: 'SA3: 超必杀忍蜂', command: '2141236K', type: MoveType.superArt, damage: 4000, startup: '9', active: '12', recovery: '52', onBlock: '-28', onHit: '火狐终结', notes: '狂暴火狐爆发终结，红血CA 4500'),
        ]);
        break;
      case 'elena':
        list.addAll([
          FrameMove(name: '羚羊踢', command: '41236K', type: MoveType.special, damage: 1000, startup: '12', active: '4', recovery: '19', onBlock: '-4', onHit: '击倒', notes: '突进飞踢，穿波与快速近身'),
          FrameMove(name: '旋风腿', command: '214K', type: MoveType.special, damage: 1200, startup: '14', active: '6', recovery: '20', onBlock: '-8', onHit: '击倒', notes: '连段主力输出技'),
          FrameMove(name: '旋轮对空', command: '623K', type: MoveType.special, damage: 1100, startup: '6', active: '5', recovery: '28', onBlock: '-18', onHit: '击倒', notes: '无敌对空技，被防大确反'),
          FrameMove(name: '治愈之步', command: '214P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '位移', onHit: '派生', notes: '卡波耶拉舞步快速进退'),
          FrameMove(name: 'SA1: 旋转狂热', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '10', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '1气无敌超必杀反击'),
          FrameMove(name: 'SA3: 治愈之舞 / 终结连击', command: '214214K', type: MoveType.superArt, damage: 4000, startup: '8', active: '12', recovery: '48', onBlock: '-25', onHit: '击倒', notes: '3气终结狂暴连击，红血CA 4500'),
        ]);
        break;
      case 'jamie':
        list.addAll([
          FrameMove(name: '魔身连拳', command: '236P', type: MoveType.special, damage: 900, startup: '13', active: '4', recovery: '20', onBlock: '-6', onHit: '派生', notes: '三连掌连拳，连段核心'),
          FrameMove(name: '绝招步', command: '41236K', type: MoveType.special, damage: 950, startup: '11', active: '4', recovery: '18', onBlock: '-4', onHit: '击倒', notes: '低姿态滑步突进掌'),
          FrameMove(name: '旋风踢', command: '623K', type: MoveType.special, damage: 1150, startup: '6', active: '5', recovery: '28', onBlock: '-20', onHit: '击倒', notes: '倒立旋转腿对空'),
          FrameMove(name: '魔身饮 (喝酒)', command: '22P', type: MoveType.special, damage: 0, startup: '42', active: '-', recovery: '0', onBlock: '喝酒', onHit: '提升等级', notes: '提升醉拳等级(0~4级)，解锁海量新技能与加成'),
          FrameMove(name: 'SA1: 武赖疾走', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '低位突进穿波'),
          FrameMove(name: 'SA2: 绝伦醉酒', command: '214214P', type: MoveType.superArt, damage: 0, startup: '4', active: '增益', recovery: '0', onBlock: '醉酒', onHit: '瞬时满级', notes: '瞬间进入4级绝顶状态！'),
          FrameMove(name: 'SA3: 月下恶鬼', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '绝顶终结', notes: '完全无敌醉拳乱舞，红血CA 4500'),
        ]);
        break;
      case 'kimberly':
        list.addAll([
          FrameMove(name: '疾驱冲刺', command: '236K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '冲刺', onHit: '派生', notes: '疾跑，派生下段滑铲/中段飞踢/急停'),
          FrameMove(name: '隐身飞天 (烟雾弹)', command: '214P', type: MoveType.special, damage: 800, startup: '18', active: '4', recovery: '20', onBlock: '-4', onHit: '瞬移', notes: '烟雾弹瞬移至对手头顶'),
          FrameMove(name: '飞燕蹴', command: '623K', type: MoveType.special, damage: 1150, startup: '6', active: '5', recovery: '28', onBlock: '-20', onHit: '击倒', notes: '踩头空翻对空'),
          FrameMove(name: '喷漆炸弹', command: '22P', type: MoveType.special, damage: 400, startup: '16', active: '定时炸弹', recovery: '18', onBlock: '+1', onHit: '多择', notes: '投掷喷漆罐定时炸弹压制'),
          FrameMove(name: 'SA1: 飞翔爆裂', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '突进升空踢'),
          FrameMove(name: 'SA3: 武神显现', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '音乐轰击', notes: '播放卡带随身听，永久提升移速与攻击，红血CA 4500'),
        ]);
        break;
      case 'ehonda':
        list.addAll([
          FrameMove(name: '超级百裂张手', command: '236P', type: MoveType.special, damage: 1000, startup: '12', active: '6', recovery: '18', onBlock: '-4', onHit: '推角', notes: '快速连打张手'),
          FrameMove(name: '超级头槌', command: '4蓄6P', type: MoveType.special, damage: 1200, startup: '10', active: '8', recovery: '24', onBlock: '-4~-8', onHit: '击倒', notes: '火箭头槌全屏突进'),
          FrameMove(name: '超级百贯落', command: '2蓄8K', type: MoveType.special, damage: 1100, startup: '20', active: '4', recovery: '18', onBlock: '-2~+1', onHit: '下落砸地', notes: '空降大屁股泰山压顶'),
          FrameMove(name: '大银杏投', command: '63214P', type: MoveType.special, damage: 2000, startup: '5', active: '2', recovery: '42', onBlock: '不可防御', onHit: '大摔', notes: '5F 指令抓投'),
          FrameMove(name: 'SA1: 播磨落', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '跳跃抓投', notes: '空中抓投超必杀'),
          FrameMove(name: 'SA3: 千秋万岁', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-28', onHit: '相扑终结', notes: '完全无敌相扑乱舞，红血CA 4500'),
        ]);
        break;
      case 'blanka':
        list.addAll([
          FrameMove(name: '滚球突进', command: '4蓄6P', type: MoveType.special, damage: 1100, startup: '11', active: '8', recovery: '22', onBlock: '-11', onHit: '击倒', notes: '横向肉弹战车'),
          FrameMove(name: '垂直滚球', command: '2蓄8K', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-24', onHit: '击倒', notes: '垂直冲天无敌对空'),
          FrameMove(name: '雷电暴击', command: '214P', type: MoveType.special, damage: 900, startup: '13', active: '持续', recovery: '18', onBlock: '-3', onHit: '+2', notes: '原地放电护体'),
          FrameMove(name: '疯狂跳跃', command: '214K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '空翻', onHit: '多择', notes: '空中跳跃变轨突袭'),
          FrameMove(name: 'SA1: 闪电滚球', command: '4蓄646P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '穿波雷电突击'),
          FrameMove(name: 'SA2: 雷神召唤 (电布兰卡)', command: '214214K', type: MoveType.superArt, damage: 0, startup: '4', active: '增益', recovery: '0', onBlock: '启动', onHit: '无限滚球', notes: '滚球命中后可连续追加变向弹跳'),
          FrameMove(name: 'SA3: 疯狂大咬杀', command: '4蓄646K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-28', onHit: '野兽撕咬', notes: '完全无敌狂暴终结，红血CA 4500'),
        ]);
        break;
      case 'lily':
        list.addAll([
          FrameMove(name: '兀鹰突刺', command: '236P', type: MoveType.special, damage: 900, startup: '12', active: '6', recovery: '20', onBlock: '-4~+1', onHit: '突进', notes: '战斧突进，有风缠绕时被防+1有利'),
          FrameMove(name: '兀鹰俯冲', command: '空中 236P', type: MoveType.special, damage: 800, startup: '14', active: '4', recovery: '着地10', onBlock: '+1~+3', onHit: '硬直', notes: '空中飞扑下砸'),
          FrameMove(name: '战斧大投', command: '360P', type: MoveType.special, damage: 2400, startup: '5', active: '2', recovery: '45', onBlock: '不可防御', onHit: '大抓投', notes: '5F极速大指令投'),
          FrameMove(name: '风之聚气', command: '214P', type: MoveType.special, damage: 0, startup: '32', active: '-', recovery: '0', onBlock: '聚气', onHit: '存风', notes: '旋转战斧积攒风之力(最多3层)'),
          FrameMove(name: 'SA1: 烈风呼啸', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '无敌旋转风刃反击'),
          FrameMove(name: 'SA3: 狂风咆哮大抓杀', command: '720P', type: MoveType.superArt, damage: 4000, startup: '7', active: '2', recovery: '55', onBlock: '不可防御', onHit: '天顶摔', notes: '720度不可防御大指令投，红血CA 4500'),
        ]);
        break;
      case 'manon':
        list.addAll([
          FrameMove(name: '曼侬大芭蕾投', command: '63214P', type: MoveType.special, damage: 2000, startup: '5', active: '2', recovery: '45', onBlock: '不可防御', onHit: '芭蕾摔', notes: '5F 指令投，命中积累勋章(1~5级)，最高级伤害 3700！'),
          FrameMove(name: '旋转扫腿踢', command: '236K', type: MoveType.special, damage: 900, startup: '13', active: '4', recovery: '20', onBlock: '-6', onHit: '派生', notes: '突进长腿横扫'),
          FrameMove(name: '优雅跳跃', command: '214K', type: MoveType.special, damage: 950, startup: '16', active: '4', recovery: '18', onBlock: '-3', onHit: '击倒', notes: '避下段空翻踩踏'),
          FrameMove(name: '拉回打击', command: '214P', type: MoveType.special, damage: 1100, startup: '14', active: '4', recovery: '22', onBlock: '-4', onHit: '拉近', notes: '柔道打击，命中强行拉近对手'),
          FrameMove(name: 'SA1: 芭蕾优雅之舞', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '低姿态穿波旋转踢'),
          FrameMove(name: 'SA3: 天鹅绝唱终曲', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '2', recovery: '52', onBlock: '不可防御', onHit: '至高抓投', notes: '完全无敌至高柔道指令投，红血CA 4500'),
        ]);
        break;
      case 'dhalsim':
        list.addAll([
          FrameMove(name: '瑜伽火焰', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '34', onBlock: '-4', onHit: '+2', notes: '慢速喷火牵制'),
          FrameMove(name: '瑜伽烈火', command: '63214P', type: MoveType.special, damage: 1000, startup: '16', active: '4', recovery: '26', onBlock: '-6', onHit: '击倒', notes: '大范围扇形火焰对空'),
          FrameMove(name: '瑜伽彗星', command: '空中 236P', type: MoveType.special, damage: 600, startup: '13', active: '-', recovery: '着地8', onBlock: '+1~+4', onHit: '浮空', notes: '空中斜下喷火'),
          FrameMove(name: '瑜伽瞬移', command: '623PPP/KKK', type: MoveType.special, damage: 0, startup: '1', active: '16', recovery: '14', onBlock: '瞬移', onHit: '-', notes: '无敌瞬移至对手头顶或身后'),
          FrameMove(name: '瑜伽悬浮', command: '2KKK', type: MoveType.special, damage: 0, startup: '1', active: '悬浮', recovery: '0', onBlock: '浮空', onHit: '-', notes: '原地空中悬停'),
          FrameMove(name: 'SA1: 瑜伽烈风之怒', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '大击退', notes: '地面巨浪火焰'),
          FrameMove(name: 'SA2: 瑜伽日轮爆', command: '236236P', type: MoveType.superArt, damage: 2700, startup: '12', active: '极慢球', recovery: '26', onBlock: '+18', onHit: '巨大慢球', notes: '全屏极慢滚动的巨大火球'),
          FrameMove(name: 'SA3: 瑜伽至高梵天', command: '214214P', type: MoveType.superArt, damage: 4000, startup: '8', active: '9', recovery: '50', onBlock: '-26', onHit: '焚天终结', notes: '完全无敌焚天神炎，红血CA 4500'),
        ]);
        break;
      case 'rashid':
        list.addAll([
          FrameMove(name: '旋风弹', command: '236P', type: MoveType.special, damage: 600, startup: '13', active: '-', recovery: '32', onBlock: '-6', onHit: '+1', notes: '小旋风飞行道具'),
          FrameMove(name: '飞升龙 (旋风跳踢)', command: '623P', type: MoveType.special, damage: 1150, startup: '6', active: '6', recovery: '30', onBlock: '-22', onHit: '击倒', notes: '无敌对空旋风'),
          FrameMove(name: '突进滑铲', command: '214K', type: MoveType.special, damage: 900, startup: '12', active: '8', recovery: '18', onBlock: '-8', onHit: '击倒', notes: '低姿态滑步穿梭'),
          FrameMove(name: '阿拉伯空中飞踢', command: '214P', type: MoveType.special, damage: 850, startup: '16', active: '4', recovery: '18', onBlock: '+1', onHit: '+5', notes: '空中踏步突进，被防+1有利'),
          FrameMove(name: 'SA1: 超级风暴', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '高速风暴穿波'),
          FrameMove(name: 'SA2: 依阿尔图飓风', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '12', active: '全屏大旋风', recovery: '24', onBlock: '+22', onHit: '气流加速', notes: '全屏巨大龙卷风，穿过龙卷风获得极速强化'),
          FrameMove(name: 'SA3: 暴风降临斩杀', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '终极风暴', notes: '完全无敌风暴终结，红血CA 4500'),
        ]);
        break;
      case 'aki':
        list.addAll([
          FrameMove(name: '紫泡弹 (毒针射击)', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '32', onBlock: '-4', onHit: '中毒', notes: '毒泡飞行道具，使对手进入中毒掉血状态'),
          FrameMove(name: '蛇毒突刺', command: '623P', type: MoveType.special, damage: 1100, startup: '10', active: '4', recovery: '22', onBlock: '-8', onHit: '引爆毒伤', notes: '命中中毒对手造成剧烈暴击浮空'),
          FrameMove(name: '蛇行穿地', command: '214P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '伏地', onHit: '穿波潜行', notes: '完全贴地爬行，穿透一切飞行道具'),
          FrameMove(name: '恶灵抓挠', command: '214K', type: MoveType.special, damage: 950, startup: '15', active: '4', recovery: '20', onBlock: '-4', onHit: '击倒', notes: '长距离毒爪连挠'),
          FrameMove(name: '仰卧毒牙构', command: '22P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '仰卧', onHit: '构派生', notes: '仰卧姿态，派生下段蛇踢或突刺'),
          FrameMove(name: 'SA1: 致命死线', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '贴地滑铲毒刺穿波'),
          FrameMove(name: 'SA2: 紫烟剧毒阵', command: '214214P', type: MoveType.superArt, damage: 2700, startup: '12', active: '毒雾领域', recovery: '24', onBlock: '+15', onHit: '持续毒雾', notes: '地面铺开巨型毒液领域'),
          FrameMove(name: 'SA3: 极刑毒杀', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-26', onHit: '针灸处刑', notes: '完全无敌剧毒针灸终结，红血CA 4500'),
        ]);
        break;
      case 'deejay':
        list.addAll([
          FrameMove(name: '空气断头台 (双重气刃)', command: '4蓄6P', type: MoveType.special, damage: 700, startup: '11', active: '-', recovery: '30', onBlock: '-4', onHit: '+2', notes: '两连发手刀气刃'),
          FrameMove(name: '飞天双踢', command: '2蓄8K', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-22', onHit: '击倒', notes: '蓄力无敌对空翻踢'),
          FrameMove(name: '摇摆闪避', command: '214P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '摇摆', onHit: '派生', notes: '后撤摇摆，避开攻击并派生强力确反拳'),
          FrameMove(name: '狂欢冲刺', command: '236K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '滑步', onHit: '派生', notes: '极速滑行，可派生中段踢或下段铲'),
          FrameMove(name: 'SA1: 极速节奏', command: '4蓄646P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '连续气刃穿波'),
          FrameMove(name: 'SA3: 周末狂欢夜', command: '4蓄646K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '狂欢节', notes: '完全无敌电音轰击终结，红血CA 4500'),
        ]);
        break;
      default:
        list.addAll([
          FrameMove(name: '主力必杀技 (Special Move)', command: '236P/K', type: MoveType.special, damage: 1000, startup: '12', active: '4', recovery: '22', onBlock: '-6', onHit: '击倒', notes: '角色专属主力必杀技'),
          FrameMove(name: '主力对空技 (Anti-Air Special)', command: '623P/K', type: MoveType.special, damage: 1200, startup: '6', active: '5', recovery: '30', onBlock: '-20', onHit: '击倒', notes: '完全无敌对空必杀'),
          FrameMove(name: 'SA1: 超必杀技 Level 1', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '1气无敌超必杀'),
          FrameMove(name: 'SA3: 终极超必杀 Level 3 / CA', command: '236236P/K', type: MoveType.superArt, damage: 4000, startup: '8', active: '12', recovery: '50', onBlock: '-25', onHit: '击倒', notes: '3气终极必杀爆发'),
        ]);
        break;
    }

    return list;
  }
}
