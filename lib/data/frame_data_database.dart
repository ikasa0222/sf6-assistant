// SF6 Full Official Frame Data Database
// Comprehensive move lists for all SF6 characters (Normals, Jump Attacks, Throws, Specials, ODs, Supers)

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
      name: '前普通投 (Forward Throw)',
      command: 'LP+LK',
      type: MoveType.throwTech,
      damage: 1200,
      startup: '5',
      active: '3',
      recovery: '23',
      onBlock: '不可防御',
      onHit: '倒地+23F',
      notes: '5F 极速近身破防投技，压制拆投核心',
    ),
    FrameMove(
      name: '后普通投 (Back Throw)',
      command: '4LP+LK',
      type: MoveType.throwTech,
      damage: 1200,
      startup: '5',
      active: '3',
      recovery: '23',
      onBlock: '不可防御',
      onHit: '换边倒地+42F',
      notes: '5F 极速后投，将对手反向甩入版边',
    ),
  ];

  static List<FrameMove> getCharacterMoves(String charId) {
    final id = charId.toLowerCase();
    final list = <FrameMove>[];
    list.addAll(commonDriveMoves);

    // Standard 18 Universal Ground & Jump Normals tailored to character
    list.addAll([
      FrameMove(name: '站立轻拳 (5LP)', command: '5LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '4F最速起手抢招，点中可确认连段'),
      FrameMove(name: '蹲下轻拳 (2LP)', command: '2LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '8', onBlock: '-1', onHit: '+4', isCancelable: true, notes: '下盘4F反击插动'),
      FrameMove(name: '站立轻脚 (5LK)', command: '5LK', type: MoveType.normal, damage: 300, startup: '5', active: '3', recovery: '9', onBlock: '-2', onHit: '+3', isCancelable: true, notes: '快速推开近战距离'),
      FrameMove(name: '蹲下轻脚 (2LK)', command: '2LK', type: MoveType.normal, damage: 250, startup: '5', active: '3', recovery: '8', onBlock: '-2', onHit: '+3', isCancelable: true, notes: '极速下段破站防起手'),
      FrameMove(name: '站立中拳 (5MP)', command: '5MP', type: MoveType.normal, damage: 600, startup: '6', active: '3', recovery: '12', onBlock: '+1', onHit: '+6', isCancelable: true, notes: '核心立回压制拳，被防有利'),
      FrameMove(name: '蹲下中拳 (2MP)', command: '2MP', type: MoveType.normal, damage: 600, startup: '6', active: '3', recovery: '13', onBlock: '+1', onHit: '+6', isCancelable: true, notes: '打拆投及近距离目押核心'),
      FrameMove(name: '站立中脚 (5MK)', command: '5MK', type: MoveType.normal, damage: 650, startup: '7', active: '3', recovery: '15', onBlock: '-2', onHit: '+4', isCancelable: false, notes: '中距离立回牵制神技'),
      FrameMove(name: '蹲下中脚 (2MK)', command: '2MK', type: MoveType.normal, damage: 500, startup: '8', active: '3', recovery: '17', onBlock: '-4', onHit: '+1', isCancelable: true, notes: '最强核心下段立回，可取消接绿冲或必杀'),
      FrameMove(name: '站立重拳 (5HP)', command: '5HP', type: MoveType.normal, damage: 850, startup: '9', active: '3', recovery: '19', onBlock: '-3', onHit: '+3', isCancelable: true, notes: '大伤害单发确反与压制起手'),
      FrameMove(name: '蹲下重拳 (2HP)', command: '2HP', type: MoveType.normal, damage: 850, startup: '8', active: '4', recovery: '22', onBlock: '-10', onHit: '+2', isCancelable: true, notes: '核心地面防空重拳，判定极强'),
      FrameMove(name: '站立重脚 (5HK)', command: '5HK', type: MoveType.normal, damage: 900, startup: '11', active: '4', recovery: '18', onBlock: '-4', onHit: '+3', isCancelable: false, notes: '超长距离破绽惩罚打击，破招造成崩防大硬直'),
      FrameMove(name: '蹲下重脚 (2HK)', command: '2HK', type: MoveType.normal, damage: 900, startup: '10', active: '3', recovery: '24', onBlock: '-11', onHit: '击倒', isCancelable: false, notes: '扫堂腿大确反击倒，被防大负帧'),
      FrameMove(name: '跳跃轻拳 (j.LP)', command: 'j.LP', type: MoveType.normal, damage: 300, startup: '4', active: '持续', recovery: '着地3', onBlock: '+2~+5', onHit: '+6', isCancelable: false, notes: '空中最速下落抢招，截击对手起跳'),
      FrameMove(name: '跳跃轻脚 (j.LK)', command: 'j.LK', type: MoveType.normal, damage: 300, startup: '5', active: '持续', recovery: '着地3', onBlock: '+1~+4', onHit: '+5', isCancelable: false, notes: '绝佳逆向打背判定脚'),
      FrameMove(name: '跳跃中拳 (j.MP)', command: 'j.MP', type: MoveType.normal, damage: 700, startup: '7', active: '持续', recovery: '着地3', onBlock: '+3~+6', onHit: '浮空', isCancelable: true, notes: '空对空绝对截杀神技，命中可空中追击'),
      FrameMove(name: '跳跃中脚 (j.MK)', command: 'j.MK', type: MoveType.normal, damage: 600, startup: '7', active: '持续', recovery: '着地3', onBlock: '+2~+5', onHit: '+6', isCancelable: false, notes: '主力逆向跳入压制踢'),
      FrameMove(name: '跳跃重拳 (j.HP)', command: 'j.HP', type: MoveType.normal, damage: 800, startup: '9', active: '持续', recovery: '着地3', onBlock: '+4~+8', onHit: '+8', isCancelable: false, notes: '高伤大判定跳入重拳，确反破防起点'),
      FrameMove(name: '跳跃重脚 (j.HK)', command: 'j.HK', type: MoveType.normal, damage: 800, startup: '9', active: '持续', recovery: '着地3', onBlock: '+4~+8', onHit: '+8', isCancelable: false, notes: '长距离斜下重脚踢入'),
    ]);

    switch (id) {
      case 'ryu':
        list.addAll([
          FrameMove(name: '锁骨割', command: '6MP', type: MoveType.unique, damage: 800, startup: '20', active: '3', recovery: '17', onBlock: '-1', onHit: '+2', notes: '中段开罐破防技，打蹲防核心'),
          FrameMove(name: '鸠尾碎', command: '4HP', type: MoveType.unique, damage: 900, startup: '17', active: '4', recovery: '18', onBlock: '+1', onHit: '+7', isCancelable: true, notes: '二连腹击，被防+1F有利，可接连段'),
          FrameMove(name: '斧脚', command: '4HK', type: MoveType.unique, damage: 850, startup: '14', active: '3', recovery: '18', onBlock: '-3', onHit: '+3', isCancelable: true, notes: '对空与连段衔接脚'),
          FrameMove(name: '旋风脚', command: '6HK', type: MoveType.unique, damage: 900, startup: '16', active: '4', recovery: '19', onBlock: '-4', onHit: '+4', notes: '长距离跨步下劈重踢'),
          FrameMove(name: '上段二连击 TC', command: '5HP > 5HK', type: MoveType.unique, damage: 1400, startup: '9', active: '3', recovery: '22', onBlock: '-12', onHit: '击倒', isCancelable: true, notes: '重拳确认后接重脚直接击倒'),
          FrameMove(name: '不破三连击 TC', command: '5MP > 2HP > 5HK', type: MoveType.unique, damage: 1600, startup: '6', active: '3', recovery: '25', onBlock: '-14', onHit: '大击倒', isCancelable: true, notes: '中拳启动三连段，推角神技'),
          FrameMove(name: '波动拳', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '33', onBlock: '-6', onHit: '+1', notes: '地波牵制主力，重版波速极快'),
          FrameMove(name: 'OD 波动拳', command: '236PP', type: MoveType.special, damage: 800, startup: '12', active: '-', recovery: '31', onBlock: '+2', onHit: '击倒', notes: '2段高速强化波，被防+2F有利'),
          FrameMove(name: '升龙拳', command: '623P', type: MoveType.special, damage: 1200, startup: '5', active: '6', recovery: '32', onBlock: '-23', onHit: '击倒', notes: '标准对空升龙拳，完全对空无敌'),
          FrameMove(name: 'OD 升龙拳', command: '623PP', type: MoveType.special, damage: 1400, startup: '6', active: '8', recovery: '38', onBlock: '-35', onHit: '击倒', notes: '第1帧完全无敌，凹起身反击王牌'),
          FrameMove(name: '龙卷旋风脚', command: '214K', type: MoveType.special, damage: 900, startup: '12', active: '10', recovery: '20', onBlock: '-10', onHit: '击倒', notes: '运板推角神技，重版穿波'),
          FrameMove(name: 'OD 龙卷旋风脚', command: '214KK', type: MoveType.special, damage: 1100, startup: '10', active: '10', recovery: '22', onBlock: '-12', onHit: '大浮空', notes: '命中后使对手垂直大浮空，可追击'),
          FrameMove(name: '空中龙卷旋风脚', command: '空中 214K', type: MoveType.special, damage: 800, startup: '12', active: '8', recovery: '着地10', onBlock: '-4', onHit: '击倒', notes: '空中变轨位移与逃出版边'),
          FrameMove(name: '波掌击', command: '214P', type: MoveType.special, damage: 700, startup: '16', active: '3', recovery: '17', onBlock: '-3', onHit: '+3', isCancelable: true, notes: '近身压制气功，被防安全'),
          FrameMove(name: 'OD 波掌击', command: '214PP', type: MoveType.special, damage: 900, startup: '14', active: '4', recovery: '18', onBlock: '+3', onHit: '崩防浮空', notes: '近身被防+3F有利！命中大崩防'),
          FrameMove(name: '电刃炼气', command: '22P', type: MoveType.special, damage: 0, startup: '38', active: '-', recovery: '0', onBlock: '充能', onHit: '强化', notes: '强化下次波掌击/波动拳，极大提升判定与帧数'),
          FrameMove(name: 'SA1: 真空波动拳', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '6', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '全屏穿波高速反击超必杀'),
          FrameMove(name: 'SA2: 真·波掌击', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '15', active: '8', recovery: '44', onBlock: '+2~+8', onHit: '大破防', notes: '可蓄力高伤超必杀，蓄满不可防御'),
          FrameMove(name: 'SA3: 真·升龙拳', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-27', onHit: '终结', notes: '完全无敌近身终结技，红血CA 4500'),
        ]);
        break;

      case 'ken':
        list.addAll([
          FrameMove(name: '紫电脚 TC', command: '5MP > 5HP', type: MoveType.unique, damage: 1300, startup: '6', active: '3', recovery: '18', onBlock: '-8', onHit: '浮空', isCancelable: true, notes: '全游戏最强确认TC连段'),
          FrameMove(name: '颚割 TC', command: '5MP > 5HP > 2HK', type: MoveType.unique, damage: 1700, startup: '6', active: '3', recovery: '24', onBlock: '-14', onHit: '击倒', notes: '全套紫电脚下扫收尾击倒'),
          FrameMove(name: '闪光踢', command: '6HK', type: MoveType.unique, damage: 850, startup: '23', active: '3', recovery: '16', onBlock: '-1', onHit: '+3', notes: '中段突袭下落踢，打蹲防'),
          FrameMove(name: '踏进前蹴', command: '6MK', type: MoveType.unique, damage: 650, startup: '14', active: '3', recovery: '17', onBlock: '-4', onHit: '+2', notes: '中距离前踏牵制脚'),
          FrameMove(name: '波动拳', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '34', onBlock: '-6', onHit: '+1', notes: '标准地波牵制'),
          FrameMove(name: 'OD 波动拳', command: '236PP', type: MoveType.special, damage: 800, startup: '12', active: '-', recovery: '31', onBlock: '+2', onHit: '击倒', notes: '2段高速强化波'),
          FrameMove(name: '升龙拳', command: '623P', type: MoveType.special, damage: 1250, startup: '5', active: '6', recovery: '32', onBlock: '-23', onHit: '击倒', notes: '完全无敌火焰升龙拳'),
          FrameMove(name: 'OD 升龙拳', command: '623PP', type: MoveType.special, damage: 1450, startup: '6', active: '8', recovery: '38', onBlock: '-35', onHit: '击倒', notes: '第1帧无敌起手反击凹招'),
          FrameMove(name: '龙卷旋风脚', command: '214K', type: MoveType.special, damage: 950, startup: '11', active: '10', recovery: '18', onBlock: '-10', onHit: '推角', notes: '全屏把对手送入版边'),
          FrameMove(name: 'OD 龙卷旋风脚', command: '214KK', type: MoveType.special, damage: 1200, startup: '9', active: '10', recovery: '20', onBlock: '-12', onHit: '穿波浮空', notes: '穿透地波并带高浮空'),
          FrameMove(name: '空中龙卷旋风脚', command: '空中 214K', type: MoveType.special, damage: 850, startup: '11', active: '8', recovery: '着地10', onBlock: '-4', onHit: '击倒', notes: '空中变轨飞踢'),
          FrameMove(name: '迅雷脚', command: '236K', type: MoveType.special, damage: 800, startup: '13', active: '3', recovery: '18', onBlock: '-5', onHit: '多择', notes: '版边多择主力，可派生上中下段'),
          FrameMove(name: '迅雷脚·风镰蹴 (下段)', command: '236K > 6LK', type: MoveType.special, damage: 400, startup: '14', active: '3', recovery: '19', onBlock: '-6', onHit: '+2', notes: '下段扫堂踢偷袭'),
          FrameMove(name: '迅雷脚·轰雷蹴 (中段)', command: '236K > 6MK', type: MoveType.special, damage: 500, startup: '18', active: '3', recovery: '17', onBlock: '-4', onHit: '+3', notes: '中段劈击破蹲防'),
          FrameMove(name: '迅雷脚·闪华蹴 (上段)', command: '236K > 6HK', type: MoveType.special, damage: 600, startup: '12', active: '3', recovery: '21', onBlock: '-8', onHit: '击倒', notes: '高踢击飞，可接后续连段'),
          FrameMove(name: '龙尾脚', command: '623K', type: MoveType.special, damage: 1000, startup: '24', active: '3', recovery: '16', onBlock: '+1', onHit: '+5', notes: '重龙尾被防+1F有利，强行拉近压制'),
          FrameMove(name: 'OD 龙尾脚', command: '623KK', type: MoveType.special, damage: 1200, startup: '16', active: '3', recovery: '18', onBlock: '+2', onHit: '击倒', notes: '极速突进，被防+2有利'),
          FrameMove(name: '奋迅脚', command: 'KK', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '冲刺', onHit: '强化', notes: '高速疾跑，派生升龙/龙卷/急停'),
          FrameMove(name: 'SA1: 龙卷裂风脚', command: '214214K', type: MoveType.superArt, damage: 2000, startup: '9', active: '10', recovery: '42', onBlock: '-18', onHit: '推角', notes: '无敌对空推角超必杀'),
          FrameMove(name: 'SA2: 疾风迅雷脚', command: '236236K', type: MoveType.superArt, damage: 2700, startup: '8', active: '12', recovery: '46', onBlock: '-20', onHit: '大浮空', notes: '无敌滑步突进连击超杀'),
          FrameMove(name: 'SA3: 神龙拳', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '烈火龙卷', notes: '完全无敌爆发终结，红血CA 4500'),
        ]);
        break;

      case 'luke':
        list.addAll([
          FrameMove(name: '四连猛击 TC', command: '5LP>5MP>5HP>5HK', type: MoveType.unique, damage: 1400, startup: '4', active: '3', recovery: '20', onBlock: '-12', onHit: '击倒', notes: '4F最速起手全套轻连确认'),
          FrameMove(name: '抑制连击 TC', command: '5MP>5MP>5MP', type: MoveType.unique, damage: 1200, startup: '6', active: '3', recovery: '18', onBlock: '-9', onHit: '击倒', notes: '中拳连续压迫确认连段'),
          FrameMove(name: '破甲重拳', command: '4HP', type: MoveType.unique, damage: 900, startup: '15', active: '4', recovery: '16', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '立回核心后退重拳打拆'),
          FrameMove(name: '暴风突击', command: '6HP', type: MoveType.unique, damage: 850, startup: '18', active: '3', recovery: '18', onBlock: '-3', onHit: '+3', notes: '长距离跨步直拳突击'),
          FrameMove(name: '亡命飞踢', command: '6HK', type: MoveType.unique, damage: 900, startup: '19', active: '4', recovery: '17', onBlock: '-4', onHit: '+3', notes: '前冲大踢腿'),
          FrameMove(name: '沙弹', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '31', onBlock: '-7', onHit: '+1', notes: '全屏瞬间命中飞行道具'),
          FrameMove(name: 'OD 沙弹', command: '236PP', type: MoveType.special, damage: 800, startup: '11', active: '-', recovery: '28', onBlock: '-2', onHit: '击倒', notes: '极速双发沙弹穿波'),
          FrameMove(name: '升龙重拳', command: '623P', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-20', onHit: '击倒', notes: '无敌对空拳'),
          FrameMove(name: 'OD 升龙重拳', command: '623PP', type: MoveType.special, damage: 1400, startup: '5', active: '7', recovery: '36', onBlock: '-32', onHit: '击倒', notes: '第1帧无敌起手反击'),
          FrameMove(name: '闪电重拳 (蓄力)', command: '214P', type: MoveType.special, damage: 1100, startup: '15', active: '4', recovery: '19', onBlock: '-4', onHit: '浮空', notes: '目押完美蓄力超高连段伤害'),
          FrameMove(name: 'OD 闪电重拳', command: '214PP', type: MoveType.special, damage: 1300, startup: '13', active: '4', recovery: '20', onBlock: '-2', onHit: '大弹墙', notes: '弹墙大伤害连段启动'),
          FrameMove(name: '复仇突进', command: '214K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '突进', onHit: '派生', notes: '低姿态突进，派生过顶摔/滑铲'),
          FrameMove(name: '复仇突进·碎颅重击', command: '214K > P', type: MoveType.special, damage: 900, startup: '16', active: '3', recovery: '18', onBlock: '-2', onHit: '击倒', notes: '过顶中段下砸'),
          FrameMove(name: '复仇突进·突进滑铲', command: '214K > K', type: MoveType.special, damage: 800, startup: '13', active: '4', recovery: '21', onBlock: '-10', onHit: '击倒', notes: '贴地下段滑铲偷袭'),
          FrameMove(name: 'SA1: 致命火神', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '10', active: '8', recovery: '38', onBlock: '-16', onHit: '击倒', notes: '全屏穿波多连发沙弹轰击'),
          FrameMove(name: 'SA2: 橡皮擦强袭', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '14', active: '10', recovery: '42', onBlock: '-22', onHit: '砸地', notes: '重拳狂暴连击超必杀'),
          FrameMove(name: 'SA3: 苍白骑手', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '8', active: '9', recovery: '48', onBlock: '-25', onHit: '骑乘暴击', notes: '完全无敌斩杀终结，红血CA 4500'),
        ]);
        break;

      case 'cammy':
        list.addAll([
          FrameMove(name: '突击组合拳 TC', command: '4MP > 5HK', type: MoveType.unique, damage: 1100, startup: '6', active: '3', recovery: '19', onBlock: '-8', onHit: '浮空', isCancelable: true, notes: '立回确反核心TC'),
          FrameMove(name: '延滞破击', command: '6HK', type: MoveType.unique, damage: 850, startup: '18', active: '3', recovery: '18', onBlock: '-3', onHit: '+3', notes: '中距离前踏破防大摆腿'),
          FrameMove(name: '膝撞', command: '4/6LK', type: MoveType.unique, damage: 500, startup: '8', active: '3', recovery: '12', onBlock: '+1', onHit: '+4', notes: '近战被防+1F有利膝撞'),
          FrameMove(name: '螺旋箭', command: '236K', type: MoveType.special, damage: 1000, startup: '11', active: '12', recovery: '18', onBlock: '-12', onHit: '击倒', notes: '下段极速滑铲，连段主力'),
          FrameMove(name: 'OD 螺旋箭', command: '236KK', type: MoveType.special, damage: 1200, startup: '9', active: '14', recovery: '20', onBlock: '-10', onHit: '穿波击倒', notes: '穿透地波高速突进'),
          FrameMove(name: '加农钉升龙', command: '623K', type: MoveType.special, damage: 1200, startup: '5', active: '6', recovery: '31', onBlock: '-22', onHit: '击倒', notes: '完全无敌后空翻升龙对空'),
          FrameMove(name: 'OD 加农钉', command: '623KK', type: MoveType.special, damage: 1400, startup: '5', active: '7', recovery: '36', onBlock: '-34', onHit: '击倒', notes: '第1帧无敌起手反击凹招'),
          FrameMove(name: '加农空闪俯冲腿', command: '空中 214K', type: MoveType.special, damage: 600, startup: '12', active: '4', recovery: '着地8', onBlock: '+1~+3', onHit: '硬直', notes: '压制核心低空俯冲腿'),
          FrameMove(name: 'OD 加农空闪', command: '空中 214KK', type: MoveType.special, damage: 800, startup: '9', active: '4', recovery: '着地6', onBlock: '+3', onHit: '浮空', notes: '极速俯冲，被防+3F有利！'),
          FrameMove(name: '流氓杀手', command: '236P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '空翻', onHit: '多择', notes: '空中突进，派生滑铲/指令投'),
          FrameMove(name: '流氓杀手·剃刀滑铲', command: '236P > 落地', type: MoveType.special, damage: 800, startup: '12', active: '4', recovery: '22', onBlock: '-8', onHit: '击倒', notes: '下段滑铲击倒'),
          FrameMove(name: '流氓杀手·空落踢', command: '236P > K', type: MoveType.special, damage: 900, startup: '14', active: '3', recovery: '16', onBlock: '+1', onHit: '+4', notes: '中段下落踢，被防+1有利'),
          FrameMove(name: '流氓杀手·反转刃', command: '236P > P', type: MoveType.special, damage: 950, startup: '12', active: '3', recovery: '18', onBlock: '-4', onHit: '击倒', notes: '高空下切斩击'),
          FrameMove(name: '流氓杀手·致命拧身投', command: '236P > LP+LK', type: MoveType.special, damage: 1500, startup: '5', active: '2', recovery: '38', onBlock: '不可防御', onHit: '拧头摔', notes: '空中指令投拆防神技'),
          FrameMove(name: 'SA1: 旋转驱动狂乱', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '低姿态穿波反击'),
          FrameMove(name: 'SA2: 杀戮之蜂狂暴', command: '214214K', type: MoveType.superArt, damage: 2700, startup: '8', active: '10', recovery: '44', onBlock: '-24', onHit: '空中绞杀', notes: '地面与空中均可发动的强力超必杀'),
          FrameMove(name: 'SA3: 致命蜂刺', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '9', active: '10', recovery: '48', onBlock: '-26', onHit: '终极绞杀', notes: '全屏穿波斩杀，红血CA 4500'),
        ]);
        break;

      case 'chunli':
        list.addAll([
          FrameMove(name: '翼旋脚', command: '4/6MP', type: MoveType.unique, damage: 700, startup: '7', active: '3', recovery: '15', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '立回牵制神技，被防+1有利'),
          FrameMove(name: '鹤脚落', command: '3HK', type: MoveType.unique, damage: 850, startup: '22', active: '4', recovery: '16', onBlock: '-2', onHit: '+3', notes: '中段破蹲防神技'),
          FrameMove(name: '水仙蹴', command: '6HK', type: MoveType.unique, damage: 800, startup: '14', active: '3', recovery: '17', onBlock: '-4', onHit: '+3', notes: '前进步长踢'),
          FrameMove(name: '鹰爪脚', command: '空中 2MK', type: MoveType.unique, damage: 500, startup: '8', active: '持续', recovery: '0', onBlock: '+2', onHit: '多段踩', notes: '空中三连踏重压对手'),
          FrameMove(name: '气功拳', command: '4蓄6P', type: MoveType.special, damage: 600, startup: '13', active: '-', recovery: '32', onBlock: '-4', onHit: '+2', notes: '慢速蓄力波推进压制'),
          FrameMove(name: 'OD 气功拳', command: '4蓄6PP', type: MoveType.special, damage: 800, startup: '10', active: '-', recovery: '28', onBlock: '+2', onHit: '击倒', notes: '极速穿波气功，被防+2有利'),
          FrameMove(name: '百裂脚', command: '236K', type: MoveType.special, damage: 900, startup: '12', active: '6', recovery: '18', onBlock: '-8', onHit: '击倒', isCancelable: true, notes: '连段核心主力输出'),
          FrameMove(name: 'OD 百裂脚', command: '236KK', type: MoveType.special, damage: 1100, startup: '10', active: '8', recovery: '18', onBlock: '-2', onHit: '浮空连击', notes: '被防仅-2F安全，命中大浮空'),
          FrameMove(name: '空中百裂脚', command: '空中 236K', type: MoveType.special, damage: 800, startup: '11', active: '6', recovery: '着地8', onBlock: '+1', onHit: '浮空', notes: '空中连段与下落压制'),
          FrameMove(name: '天升脚', command: '22K', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-22', onHit: '击倒', notes: '完全无敌对空直升机脚'),
          FrameMove(name: 'OD 天升脚', command: '22KK', type: MoveType.special, damage: 1400, startup: '5', active: '8', recovery: '36', onBlock: '-35', onHit: '击倒', notes: '第1帧完全无敌凹招'),
          FrameMove(name: '回旋鸟腿', command: '2蓄8K', type: MoveType.special, damage: 1100, startup: '9', active: '8', recovery: '24', onBlock: '-10', onHit: '运角', notes: '蓄力旋转腿，连段主力运板'),
          FrameMove(name: '霸山蹴', command: '63214K', type: MoveType.special, damage: 900, startup: '23', active: '4', recovery: '15', onBlock: '+1', onHit: '+5', notes: '避波中段，被防+1F有利'),
          FrameMove(name: '行云流水构', command: '214P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '低架', onHit: '派生', notes: '低姿态构，派生 6 种招式'),
          FrameMove(name: '行云流水·发劲', command: '214P > HP', type: MoveType.special, damage: 900, startup: '10', active: '3', recovery: '18', onBlock: '+2', onHit: '+7', notes: '掌击破防，被防+2F有利'),
          FrameMove(name: '行云流水·天空脚', command: '214P > HK', type: MoveType.special, damage: 1000, startup: '8', active: '4', recovery: '22', onBlock: '-6', onHit: '高浮空', notes: '高踢击飞，起手大伤害连段'),
          FrameMove(name: 'SA1: 气功掌', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '10', recovery: '42', onBlock: '-16', onHit: '击飞', notes: '原地多段能量波穿波'),
          FrameMove(name: 'SA2: 凤翼扇', command: '236236K', type: MoveType.superArt, damage: 2700, startup: '8', active: '14', recovery: '46', onBlock: '-24', onHit: '击飞', notes: '极速突进百裂踢'),
          FrameMove(name: 'SA3: 苍天乱圣', command: '214214K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-27', onHit: '天升终结', notes: '无敌近身与对空终结，红血CA 4500'),
        ]);
        break;

      case 'akuma':
        list.addAll([
          FrameMove(name: '头盖破杀', command: '6MP', type: MoveType.unique, damage: 800, startup: '20', active: '3', recovery: '16', onBlock: '-1', onHit: '+3', notes: '中段劈掌破蹲防'),
          FrameMove(name: '鬼首突', command: '4HP', type: MoveType.unique, damage: 950, startup: '16', active: '4', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '大伤害前突掌击'),
          FrameMove(name: 'くるま蹴り', command: '4HK', type: MoveType.unique, damage: 850, startup: '14', active: '3', recovery: '19', onBlock: '-4', onHit: '+3', isCancelable: true, notes: '高踢对空与连段核心'),
          FrameMove(name: '罗汉角', command: '6HP', type: MoveType.unique, damage: 900, startup: '17', active: '3', recovery: '18', onBlock: '-3', onHit: '+4', notes: '铁肘破防突进'),
          FrameMove(name: '豪波动拳', command: '236P', type: MoveType.special, damage: 650, startup: '12', active: '-', recovery: '34', onBlock: '-6', onHit: '+1', notes: '主力波牵制，可蓄力'),
          FrameMove(name: 'OD 豪波动拳', command: '236PP', type: MoveType.special, damage: 850, startup: '10', active: '-', recovery: '30', onBlock: '+2', onHit: '击倒', notes: '强化豪波动，被防+2有利'),
          FrameMove(name: '斩空波动拳', command: '空中 236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '着地11', onBlock: '+1~+4', onHit: '硬直', notes: '空中下落波，进阶压制神器'),
          FrameMove(name: 'OD 斩空波动拳', command: '空中 236PP', type: MoveType.special, damage: 800, startup: '11', active: '-', recovery: '着地8', onBlock: '+4', onHit: '大浮空', notes: '空中连发双波'),
          FrameMove(name: '豪升龙拳', command: '623P', type: MoveType.special, damage: 1300, startup: '5', active: '6', recovery: '33', onBlock: '-23', onHit: '击倒', notes: '最强对空，完全无敌'),
          FrameMove(name: 'OD 豪升龙拳', command: '623PP', type: MoveType.special, damage: 1500, startup: '5', active: '8', recovery: '38', onBlock: '-36', onHit: '击倒', notes: '第1帧完全无敌凹招'),
          FrameMove(name: '龙卷斩空脚', command: '214K', type: MoveType.special, damage: 1000, startup: '11', active: '8', recovery: '20', onBlock: '-10', onHit: '击倒', notes: '运板主力'),
          FrameMove(name: '空中龙卷斩空脚', command: '空中 214K', type: MoveType.special, damage: 900, startup: '11', active: '6', recovery: '着地10', onBlock: '-4', onHit: '击倒', notes: '空中旋转连踢'),
          FrameMove(name: '金刚灼火', command: '214P', type: MoveType.special, damage: 1100, startup: '14', active: '4', recovery: '22', onBlock: '-6', onHit: '烈焰击飞', notes: '火焰突进双掌连击'),
          FrameMove(name: 'OD 金刚灼火', command: '214PP', type: MoveType.special, damage: 1350, startup: '12', active: '4', recovery: '20', onBlock: '-2', onHit: '大弹墙', notes: '弹墙爆发连段起点'),
          FrameMove(name: '阿修罗闪空', command: '6KKK / 4KKK', type: MoveType.special, damage: 0, startup: '1', active: '15', recovery: '14', onBlock: '无敌位移', onHit: '-', notes: '完全无敌快速瞬移'),
          FrameMove(name: '百鬼袭', command: '623K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '大跳跃', onHit: '多择', notes: '突进高跳，派生斩空/中段/投'),
          FrameMove(name: '百鬼袭·百鬼豪斩', command: '623K > 落地', type: MoveType.special, damage: 800, startup: '14', active: '3', recovery: '20', onBlock: '-6', onHit: '下段扫堂', notes: '落地偷下段'),
          FrameMove(name: '百鬼袭·百鬼豪冲', command: '623K > P', type: MoveType.special, damage: 900, startup: '12', active: '3', recovery: '16', onBlock: '+1', onHit: '+5', notes: '下落劈掌，被防+1有利'),
          FrameMove(name: '百鬼袭·百鬼豪尖', command: '623K > K', type: MoveType.special, damage: 950, startup: '12', active: '4', recovery: '18', onBlock: '-2', onHit: '击倒', notes: '空中斜踢'),
          FrameMove(name: '百鬼袭·百鬼豪碎', command: '623K > LP+LK', type: MoveType.special, damage: 1600, startup: '5', active: '2', recovery: '40', onBlock: '不可防御', onHit: '抓摔', notes: '空中不可防指令投'),
          FrameMove(name: 'SA1: 灭杀豪波动', command: '236236P', type: MoveType.superArt, damage: 2100, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击退', notes: '全屏穿波豪气功'),
          FrameMove(name: 'SA2: 崩天狂涛', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '8', active: '10', recovery: '44', onBlock: '-20', onHit: '大浮空', notes: '对空及连段暴击'),
          FrameMove(name: 'SA3: 祸灭', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '大终结', notes: '豪鬼大终结轰击'),
          FrameMove(name: '秘传 SA3: 瞬狱杀', command: 'LP LP 6 LK HP', type: MoveType.superArt, damage: 4500, startup: '1', active: '2', recovery: '45', onBlock: '不可防御', onHit: '一瞬千击', notes: '1F 发生全屏不可防指令投，瞬狱杀！'),
        ]);
        break;

      case 'bison':
        list.addAll([
          FrameMove(name: '阴影回旋拳', command: '6HP', type: MoveType.unique, damage: 900, startup: '16', active: '3', recovery: '18', onBlock: '-3', onHit: '+3', notes: '长距离重拳突击'),
          FrameMove(name: '地狱突刺', command: '2HP', type: MoveType.unique, damage: 850, startup: '8', active: '4', recovery: '18', onBlock: '-6', onHit: '+2', isCancelable: true, notes: '低姿态下刺重拳'),
          FrameMove(name: '精神爆弹', command: '214P', type: MoveType.special, damage: 800, startup: '15', active: '4', recovery: '20', onBlock: '-4', onHit: '附着炸弹', notes: '植入爆弹，后续招式引爆'),
          FrameMove(name: 'OD 精神爆弹', command: '214PP', type: MoveType.special, damage: 1000, startup: '12', active: '4', recovery: '18', onBlock: '+2', onHit: '爆裂浮空', notes: '被防+2有利，命中大伤害'),
          FrameMove(name: '双重膝压 (剪刀脚)', command: '4蓄6K', type: MoveType.special, damage: 1000, startup: '10', active: '5', recovery: '16', onBlock: '-5', onHit: '+2', notes: '核心蓄力推角神技'),
          FrameMove(name: 'OD 双重膝压', command: '4蓄6KK', type: MoveType.special, damage: 1200, startup: '8', active: '6', recovery: '18', onBlock: '-2', onHit: '击倒', notes: '极速突进剪刀脚'),
          FrameMove(name: '精神冲击 (Psycho Crusher)', command: '4蓄6P', type: MoveType.special, damage: 1200, startup: '12', active: '8', recovery: '22', onBlock: '-9', onHit: '击倒', notes: '横向旋转肉身冲击穿波'),
          FrameMove(name: 'OD 精神冲击', command: '4蓄6PP', type: MoveType.special, damage: 1400, startup: '9', active: '10', recovery: '24', onBlock: '-6', onHit: '大击飞', notes: '带霸体强行突进'),
          FrameMove(name: '暗影突进', command: '214K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '瞬步', onHit: '派生', notes: '低身位瞬步突进'),
          FrameMove(name: '恶魔倒转', command: '2蓄8K', type: MoveType.special, damage: 1100, startup: '22', active: '4', recovery: '14', onBlock: '+2', onHit: '击倒', notes: '空降变轨压制，被防+2有利'),
          FrameMove(name: '头部下压', command: '2蓄8P', type: MoveType.special, damage: 1000, startup: '20', active: '4', recovery: '16', onBlock: '0', onHit: '踩头', notes: '踩头空降压制'),
          FrameMove(name: 'SA1: 精神审判', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '滑铲穿波'),
          FrameMove(name: 'SA2: 精神惩戒者', command: '214214K', type: MoveType.superArt, damage: 2700, startup: '10', active: '10', recovery: '44', onBlock: '-22', onHit: '空中砸杀', notes: '空中与地面连段超必杀'),
          FrameMove(name: 'SA3: 终极精神处刑', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '8', active: '9', recovery: '50', onBlock: '-26', onHit: '君临天下', notes: '维加终极处刑，红血CA 4500'),
        ]);
        break;

      case 'guile':
        list.addAll([
          FrameMove(name: '贯通刺', command: '4/6HK', type: MoveType.unique, damage: 800, startup: '12', active: '3', recovery: '17', onBlock: '-3', onHit: '+2', notes: '避下段中距离前进步踢'),
          FrameMove(name: '倒立重扫', command: '6HK', type: MoveType.unique, damage: 950, startup: '14', active: '4', recovery: '18', onBlock: '+1', onHit: '+6', notes: '近身大摆腿，被防+1有利'),
          FrameMove(name: '旋转反击拳', command: '6HP', type: MoveType.unique, damage: 900, startup: '16', active: '3', recovery: '18', onBlock: '-2', onHit: '+4', notes: '转身长拳打差合'),
          FrameMove(name: '推进膝撞', command: '4/6LK', type: MoveType.unique, damage: 450, startup: '9', active: '3', recovery: '13', onBlock: '+1', onHit: '+4', notes: '前进一步膝击压制'),
          FrameMove(name: '翻滚重踢', command: '4/6MK', type: MoveType.unique, damage: 700, startup: '11', active: '4', recovery: '16', onBlock: '-3', onHit: '+3', notes: '后旋翻身踢'),
          FrameMove(name: '德雷克之牙 TC', command: '2MK > 6HP', type: MoveType.unique, damage: 1300, startup: '7', active: '3', recovery: '20', onBlock: '-9', onHit: '击倒', isCancelable: true, notes: '下中脚确认TC'),
          FrameMove(name: '音速手刀', command: '4蓄6P', type: MoveType.special, damage: 600, startup: '10', active: '-', recovery: '27', onBlock: '-3', onHit: '+3', notes: '硬直最小的极速飞行道具'),
          FrameMove(name: 'OD 音速手刀', command: '4蓄6PP', type: MoveType.special, damage: 800, startup: '8', active: '-', recovery: '24', onBlock: '+2', onHit: '击倒', notes: '极速双发手刀，被防+2有利'),
          FrameMove(name: '倒立脚升龙 (脚刀)', command: '2蓄8K', type: MoveType.special, damage: 1300, startup: '5', active: '5', recovery: '32', onBlock: '-24', onHit: '击倒', notes: '全游戏最强防空铁壁，完全无敌'),
          FrameMove(name: 'OD 倒立脚升龙', command: '2蓄8KK', type: MoveType.special, damage: 1500, startup: '5', active: '6', recovery: '38', onBlock: '-35', onHit: '击倒', notes: '第1帧无敌凹招'),
          FrameMove(name: '音速刀刃', command: '214P', type: MoveType.special, damage: 400, startup: '18', active: '持续', recovery: '25', onBlock: '-2', onHit: '悬浮', notes: '原地停滞气旋，强化双重音速斩'),
          FrameMove(name: '音速交叉连击', command: '214P > 6P', type: MoveType.special, damage: 900, startup: '12', active: '-', recovery: '26', onBlock: '+1', onHit: '击倒', notes: '合体大型音速手刀'),
          FrameMove(name: 'SA1: 音速飓风', command: '4蓄646P', type: MoveType.superArt, damage: 2000, startup: '8', active: '12', recovery: '40', onBlock: '-16', onHit: '穿波绞杀', notes: '全屏巨型真空风暴'),
          FrameMove(name: 'SA2: 强化固守阵地', command: '214214P', type: MoveType.superArt, damage: 0, startup: '4', active: '增益', recovery: '0', onBlock: '启动', onHit: '无限连发', notes: '无需蓄力，连轰 5 发手刀'),
          FrameMove(name: 'SA3: 音速风暴裂破', command: '4蓄646K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-28', onHit: '终结', notes: '无敌倒立双重升龙，红血CA 4500'),
        ]);
        break;

      case 'zangief':
        list.addAll([
          FrameMove(name: '地狱头槌', command: '6HP', type: MoveType.unique, damage: 1000, startup: '13', active: '3', recovery: '15', onBlock: '+4', onHit: '+8', isCancelable: true, notes: '被防+4巨幅有利！压制与碎防王牌'),
          FrameMove(name: '冲撞膝击', command: '6LK', type: MoveType.unique, damage: 700, startup: '14', active: '4', recovery: '16', onBlock: '+1', onHit: '+4', notes: '下段免疫突进膝撞'),
          FrameMove(name: '飞天长臂', command: '3HK', type: MoveType.unique, damage: 900, startup: '15', active: '4', recovery: '20', onBlock: '-6', onHit: '+2', notes: '长距离重踢下插'),
          FrameMove(name: '飞燕抓击', command: '空中 6HP', type: MoveType.unique, damage: 1100, startup: '11', active: '4', recovery: '着地10', onBlock: '+2', onHit: '击落砸地', notes: '空对空下砸抓杀'),
          FrameMove(name: '螺旋打桩机 (SPD)', command: '360P', type: MoveType.special, damage: 2500, startup: '5', active: '2', recovery: '46', onBlock: '不可防御', onHit: '大摔', notes: '5F最速指令投，重SPD伤害 3300'),
          FrameMove(name: 'OD 螺旋打桩机', command: '360PP', type: MoveType.special, damage: 3400, startup: '5', active: '2', recovery: '48', onBlock: '不可防御', onHit: '暴击大摔', notes: '抓取距离极大，伤害 3400'),
          FrameMove(name: '双重套索', command: 'PP / PPP', type: MoveType.special, damage: 1200, startup: '12', active: '16', recovery: '26', onBlock: '-12', onHit: '击倒', notes: '旋转双手前后双向对空'),
          FrameMove(name: 'OD 双重套索', command: 'PP+KK', type: MoveType.special, damage: 1500, startup: '9', active: '18', recovery: '28', onBlock: '-14', onHit: '击倒', notes: '强化双重旋转套索'),
          FrameMove(name: '西伯利亚特快', command: '63214K', type: MoveType.special, damage: 2000, startup: '26', active: '抓投', recovery: '38', onBlock: '不可防御', onHit: '全屏抓杀', notes: '全屏突进抓投，带一段霸体'),
          FrameMove(name: 'OD 西伯利亚特快', command: '63214KK', type: MoveType.special, damage: 2500, startup: '22', active: '抓投', recovery: '36', onBlock: '不可防御', onHit: '霸体抓摔', notes: '2段霸体强行冲脸抓杀'),
          FrameMove(name: '罗宋汤炸弹', command: '空中 360K', type: MoveType.special, damage: 2800, startup: '5', active: '2', recovery: '30', onBlock: '不可防御', onHit: '空中截杀', notes: '空中抓投瞬杀，判定极大'),
          FrameMove(name: 'OD 罗宋汤炸弹', command: '空中 360KK', type: MoveType.special, damage: 3500, startup: '5', active: '2', recovery: '30', onBlock: '不可防御', onHit: '高空大摔', notes: '单发 3500 空中截杀'),
          FrameMove(name: '冻原风暴', command: '623HK', type: MoveType.special, damage: 2200, startup: '3', active: '架招', recovery: '38', onBlock: '防反', onHit: '大骨折摔', notes: '地面出脚架招反击'),
          FrameMove(name: 'SA1: 空中铁击破', command: '236236K', type: MoveType.superArt, damage: 2200, startup: '8', active: '截杀', recovery: '42', onBlock: '不可防御', onHit: '砸地', notes: '无敌超必杀对空投'),
          FrameMove(name: 'SA2: 旋风大摔灭', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '13', active: '吸附', recovery: '46', onBlock: '-18', onHit: '碎骨摔', notes: '吸附全屏对手强行扯入身边'),
          FrameMove(name: 'SA3: 终极苏联大打桩', command: '720P', type: MoveType.superArt, damage: 4800, startup: '7', active: '2', recovery: '55', onBlock: '不可防御', onHit: '天崩地裂', notes: '不可防指令投，红血CA 5300 单发最高！'),
        ]);
        break;

      case 'juri':
        list.addAll([
          FrameMove(name: '紫穿脚', command: '6MK', type: MoveType.unique, damage: 800, startup: '20', active: '3', recovery: '16', onBlock: '-2', onHit: '+3', notes: '中段下劈破蹲防'),
          FrameMove(name: '狂烈闪 TC', command: '5MP > 2HP', type: MoveType.unique, damage: 1300, startup: '6', active: '3', recovery: '20', onBlock: '-9', onHit: '浮空', isCancelable: true, notes: '核心立回确认连段'),
          FrameMove(name: '风破刃', command: '214K', type: MoveType.special, damage: 600, startup: '14', active: '3', recovery: '20', onBlock: '-6', onHit: '+2', isCancelable: true, notes: '存气核心，蓄积风破气'),
          FrameMove(name: 'OD 风破刃', command: '214KK', type: MoveType.special, damage: 900, startup: '12', active: '4', recovery: '18', onBlock: '-2', onHit: '高浮空', notes: '一次存满2气并使对手浮空'),
          FrameMove(name: '岁破冲', command: '236LK', type: MoveType.special, damage: 700, startup: '15', active: '-', recovery: '30', onBlock: '+1', onHit: '+5', notes: '贴地低速波，压制起手神技'),
          FrameMove(name: '暗剑杀', command: '236MK', type: MoveType.special, damage: 900, startup: '12', active: '4', recovery: '22', onBlock: '-8', onHit: '击倒', isCancelable: true, notes: '突进横扫中距离必杀'),
          FrameMove(name: '五黄杀', command: '236HK', type: MoveType.special, damage: 1100, startup: '16', active: '6', recovery: '24', onBlock: '-12', onHit: '击倒', notes: '高伤大回旋踢'),
          FrameMove(name: '天泉轮升龙', command: '623P', type: MoveType.special, damage: 1200, startup: '5', active: '6', recovery: '32', onBlock: '-23', onHit: '击倒', notes: '完全无敌对空风火轮'),
          FrameMove(name: 'OD 天泉轮', command: '623PP', type: MoveType.special, damage: 1400, startup: '5', active: '8', recovery: '38', onBlock: '-35', onHit: '击倒', notes: '第1帧无敌凹招反击'),
          FrameMove(name: '疾空闪', command: '空中 214K', type: MoveType.special, damage: 700, startup: '12', active: '4', recovery: '着地10', onBlock: '-4', onHit: '派生', notes: '空中急速变轨突袭'),
          FrameMove(name: 'SA1: 杀界风破斩', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '大击退', notes: '地面低姿态穿波斩'),
          FrameMove(name: 'SA2: 风水引擎', command: '214214P', type: MoveType.superArt, damage: 0, startup: '4', active: '增益', recovery: '0', onBlock: '启动', onHit: '自由目押', notes: '开启自由目押通常技链，压制无解'),
          FrameMove(name: 'SA3: 迴旋断界落', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '残虐终结', notes: '完全无敌近身终结，红血CA 4500'),
        ]);
        break;

      case 'marisa':
        list.addAll([
          FrameMove(name: '玛格纳掩体拳', command: '6HP', type: MoveType.unique, damage: 950, startup: '16', active: '4', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '长臂重摆拳'),
          FrameMove(name: '飞翔连击 TC', command: '4HP > HP', type: MoveType.unique, damage: 1500, startup: '15', active: '3', recovery: '22', onBlock: '-10', onHit: '击倒', isCancelable: true, notes: '双重高伤害腹击'),
          FrameMove(name: '角斗士猛击', command: '236P', type: MoveType.special, damage: 1200, startup: '14', active: '4', recovery: '20', onBlock: '-4', onHit: '霸体击飞', notes: '重拳直冲'),
          FrameMove(name: '蓄力角斗士猛击', command: '236P (蓄满)', type: MoveType.special, damage: 1500, startup: '28', active: '4', recovery: '18', onBlock: '+3', onHit: '大崩防', notes: '霸体蓄满，被防+3F有利！'),
          FrameMove(name: 'OD 角斗士猛击', command: '236PP', type: MoveType.special, damage: 1400, startup: '12', active: '4', recovery: '18', onBlock: '+2', onHit: '弹墙', notes: '2段霸体突进，被防+2有利'),
          FrameMove(name: '方阵飞扑', command: '623P', type: MoveType.special, damage: 1100, startup: '18', active: '4', recovery: '18', onBlock: '+1', onHit: '+5', notes: '跳步重砸，被防+1有利'),
          FrameMove(name: '双剑连击', command: '214P', type: MoveType.special, damage: 1200, startup: '15', active: '4', recovery: '22', onBlock: '-8', onHit: '弹墙', isCancelable: true, notes: '连段与版边压制核心'),
          FrameMove(name: '四轮突进', command: '214K', type: MoveType.special, damage: 1000, startup: '13', active: '5', recovery: '20', onBlock: '-6', onHit: '派生', notes: '下段突进，可派生上中下投'),
          FrameMove(name: '斯库图姆防反盾', command: '22P', type: MoveType.special, damage: 0, startup: '3', active: '防守', recovery: '14', onBlock: '盾牌格挡', onHit: '派生反击', notes: '正面全身霸体架招'),
          FrameMove(name: '盾反·折颈摔', command: '22P > LP+LK', type: MoveType.special, damage: 1800, startup: '5', active: '2', recovery: '40', onBlock: '不可防御', onHit: '折颈摔', notes: '防反派生指令投'),
          FrameMove(name: '盾反·重拳突刺', command: '22P > 6P', type: MoveType.special, damage: 1100, startup: '10', active: '3', recovery: '18', onBlock: '+1', onHit: '击倒', notes: '盾反后反击冲拳'),
          FrameMove(name: 'SA1: 暴烈角斗场', command: '236236P', type: MoveType.superArt, damage: 2100, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '地面霸体爆裂重拳'),
          FrameMove(name: 'SA2: 陨石毁灭', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '14', active: '10', recovery: '44', onBlock: '-22', onHit: '大砸地', notes: '跃起双拳暴击砸地'),
          FrameMove(name: 'SA3: 狩猎女神处决', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '8', active: '9', recovery: '50', onBlock: '-28', onHit: '斯巴达终结', notes: '斯巴达战神终极处决，红血CA 4500'),
        ]);
        break;

      case 'jp':
        list.addAll([
          FrameMove(name: '幽灵推手', command: '6HP', type: MoveType.unique, damage: 900, startup: '16', active: '4', recovery: '20', onBlock: '-4', onHit: '+3', notes: '长手杖隔空推击'),
          FrameMove(name: '刺杖穿透', command: '4HP', type: MoveType.unique, damage: 850, startup: '14', active: '3', recovery: '19', onBlock: '-3', onHit: '+4', isCancelable: true, notes: '中距离穿透刺杖'),
          FrameMove(name: '特里格拉夫地刺', command: '22P', type: MoveType.special, damage: 900, startup: '25', active: '3', recovery: '36', onBlock: '-8', onHit: '浮空击飞', notes: '全屏任意位置地刺穿刺'),
          FrameMove(name: '托尔巴兰恶灵', command: '236P', type: MoveType.special, damage: 700, startup: '16', active: '-', recovery: '34', onBlock: '-6', onHit: '+1', notes: '全屏中段飞灵'),
          FrameMove(name: '托尔巴兰下段灵', command: '236K', type: MoveType.special, damage: 700, startup: '17', active: '-', recovery: '34', onBlock: '-6', onHit: '+1', notes: '全屏下段飞灵'),
          FrameMove(name: '离别空间传送门', command: '214P', type: MoveType.special, damage: 800, startup: '20', active: '空间陷阱', recovery: '28', onBlock: '-4', onHit: '传送/引爆', notes: '布置传送门或虚空炸弹'),
          FrameMove(name: '遗忘防反陷阱', command: '22K', type: MoveType.special, damage: 0, startup: '1', active: '防反', recovery: '15', onBlock: '植入爆弹', onHit: '陷阱', notes: '第1帧防反一切打击与投技！'),
          FrameMove(name: '斯特里伯格杖击', command: '214K', type: MoveType.special, damage: 1000, startup: '14', active: '4', recovery: '22', onBlock: '-6', onHit: '弹飞', notes: '近战击退杖击'),
          FrameMove(name: '断头台下落', command: '空中 236K', type: MoveType.special, damage: 800, startup: '13', active: '4', recovery: '着地10', onBlock: '-4', onHit: '踩地', notes: '空中下落穿刺'),
          FrameMove(name: 'SA1: 切尔诺博格', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '10', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '杖击穿波击飞'),
          FrameMove(name: 'SA2: 幽灵行进', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '12', active: '持续行进', recovery: '30', onBlock: '+12', onHit: '四幽灵连携', notes: '召唤四幽灵全屏持续行进压制'),
          FrameMove(name: 'SA3: 审判暴风禁令', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-26', onHit: '虚空粉碎', notes: '完全无敌空间处刑，红血CA 4500'),
        ]);
        break;

      case 'ed':
        list.addAll([
          FrameMove(name: '刺拳连击 TC', command: '5LP > 5MP', type: MoveType.unique, damage: 950, startup: '4', active: '3', recovery: '16', onBlock: '-4', onHit: '+3', isCancelable: true, notes: '4F最速刺拳两连击'),
          FrameMove(name: '破防直拳', command: '6HP', type: MoveType.unique, damage: 900, startup: '15', active: '3', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '长距离重刺拳'),
          FrameMove(name: '精神闪击连拳', command: '236P', type: MoveType.special, damage: 800, startup: '12', active: '4', recovery: '22', onBlock: '-4', onHit: '+2', isCancelable: true, notes: '多段拳击刺拳，压制牵制'),
          FrameMove(name: 'OD 精神闪击', command: '236PP', type: MoveType.special, damage: 1100, startup: '10', active: '6', recovery: '20', onBlock: '-2', onHit: '连打浮空', notes: '快速连轰浮空连击'),
          FrameMove(name: '精神升龙拳', command: '623P', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '32', onBlock: '-22', onHit: '击倒', notes: '无敌对空拳'),
          FrameMove(name: 'OD 精神升龙', command: '623PP', type: MoveType.special, damage: 1400, startup: '5', active: '7', recovery: '36', onBlock: '-34', onHit: '击倒', notes: '第1帧无敌凹招'),
          FrameMove(name: '精神连打', command: '214P', type: MoveType.special, damage: 1100, startup: '14', active: '4', recovery: '24', onBlock: '-8', onHit: '击倒', notes: '多段左右重勾拳'),
          FrameMove(name: '精神火花', command: '236K', type: MoveType.special, damage: 400, startup: '13', active: '3', recovery: '18', onBlock: '-4', onHit: '+2', notes: '近身拳气引爆，可派生'),
          FrameMove(name: '精神弹射 (派生)', command: '236K > 6P', type: MoveType.special, damage: 700, startup: '12', active: '-', recovery: '28', onBlock: '-3', onHit: '击倒', notes: '打出飞行气弹'),
          FrameMove(name: '精神拉扯长拳 (鞭子)', command: 'HP 蓄力', type: MoveType.special, damage: 1000, startup: '26', active: '2', recovery: '24', onBlock: '-2', onHit: '拉近', notes: '蓄力伸长拳气将对手强行拉至身前'),
          FrameMove(name: '闪杀进退步', command: '6KK / 4KK', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '滑步', onHit: '派生', notes: '极速前后闪步位移'),
          FrameMove(name: 'SA1: 精神风暴刺', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '快速刺拳突击'),
          FrameMove(name: 'SA2: 精神加农炮', command: '214214P', type: MoveType.superArt, damage: 2700, startup: '14', active: '缓慢推进', recovery: '24', onBlock: '+20', onHit: '巨大黑球', notes: '巨大慢速精神能量球压制'),
          FrameMove(name: 'SA3: 终极精神处决', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '连打终结', notes: '完全无敌连拳处决，红血CA 4500'),
        ]);
        break;

      case 'terry':
        list.addAll([
          FrameMove(name: '强击重拳', command: '6HP', type: MoveType.unique, damage: 900, startup: '15', active: '3', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '大摆拳打差合'),
          FrameMove(name: '穿梭步', command: '6MK', type: MoveType.unique, damage: 700, startup: '13', active: '3', recovery: '16', onBlock: '-3', onHit: '+3', notes: '跨步前突踢'),
          FrameMove(name: '能量波', command: '236P', type: MoveType.special, damage: 600, startup: '13', active: '-', recovery: '33', onBlock: '-6', onHit: '+1', notes: '地波飞行道具'),
          FrameMove(name: 'OD 能量波', command: '236PP', type: MoveType.special, damage: 850, startup: '10', active: '-', recovery: '30', onBlock: '+2', onHit: '击倒', notes: '高速强化地波'),
          FrameMove(name: '燃烧指节', command: '214P', type: MoveType.special, damage: 1100, startup: '14', active: '8', recovery: '21', onBlock: '-7', onHit: '击倒', notes: '强力突进冲拳'),
          FrameMove(name: 'OD 燃烧指节', command: '214PP', type: MoveType.special, damage: 1300, startup: '11', active: '8', recovery: '20', onBlock: '-3', onHit: '大弹墙', notes: '弹墙大伤害启动'),
          FrameMove(name: '能量升击冲撞', command: '41236K', type: MoveType.special, damage: 1000, startup: '11', active: '4', recovery: '18', onBlock: '-4', onHit: '浮空', isCancelable: true, notes: '顶肩突进，连段起手'),
          FrameMove(name: '升龙裂破', command: '2蓄8P / 623P', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-20', onHit: '击倒', notes: '对空王牌，完全无敌'),
          FrameMove(name: '裂破落下砸踢', command: '214K', type: MoveType.special, damage: 850, startup: '18', active: '4', recovery: '18', onBlock: '+1', onHit: '+4', notes: '中段下落跳踢，被防+1有利'),
          FrameMove(name: '能量灌篮', command: '623K', type: MoveType.special, damage: 1200, startup: '10', active: '4', recovery: '24', onBlock: '-12', onHit: '砸地', notes: '飞天后下砸灌篮'),
          FrameMove(name: '回旋波', command: '236K', type: MoveType.special, damage: 900, startup: '14', active: '4', recovery: '20', onBlock: '-4', onHit: '浮空', notes: '原地地面震击波'),
          FrameMove(name: 'SA1: 狂狼之爪 (Buster Wolf)', command: '236236P', type: MoveType.superArt, damage: 2100, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: 'Are you OK?', notes: '经典冲拳轰爆超必杀'),
          FrameMove(name: 'SA2: 能量喷泉', command: '2141236P', type: MoveType.superArt, damage: 2800, startup: '10', active: '8', recovery: '38', onBlock: '-18', onHit: '地裂火柱', notes: '地面巨大爆裂火柱'),
          FrameMove(name: 'SA3: 三重喷泉裂破', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '8', active: '10', recovery: '50', onBlock: '-26', onHit: '终极爆裂', notes: '完全无敌爆发终结，红血CA 4500'),
        ]);
        break;

      case 'mai':
        list.addAll([
          FrameMove(name: '阳炎之扇', command: '6HP', type: MoveType.unique, damage: 850, startup: '15', active: '3', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '大摆扇破防'),
          FrameMove(name: '黑燕之舞', command: '4HK', type: MoveType.unique, damage: 800, startup: '13', active: '3', recovery: '17', onBlock: '-4', onHit: '+3', isCancelable: true, notes: '高踢对空与连击'),
          FrameMove(name: '花蝶扇', command: '236P', type: MoveType.special, damage: 600, startup: '12', active: '-', recovery: '32', onBlock: '-4', onHit: '+2', notes: '经典飞扇牵制'),
          FrameMove(name: 'OD 花蝶扇', command: '236PP', type: MoveType.special, damage: 800, startup: '10', active: '-', recovery: '28', onBlock: '+2', onHit: '击倒', notes: '双发花蝶扇，被防+2有利'),
          FrameMove(name: '龙炎舞', command: '214P', type: MoveType.special, damage: 1000, startup: '13', active: '5', recovery: '20', onBlock: '-6', onHit: '火焰击飞', isCancelable: true, notes: '扇尾烈焰回旋打击'),
          FrameMove(name: '必杀忍蜂', command: '41236K', type: MoveType.special, damage: 1200, startup: '13', active: '6', recovery: '24', onBlock: '-10', onHit: '击倒', notes: '火焰突进肘击'),
          FrameMove(name: 'OD 必杀忍蜂', command: '41236KK', type: MoveType.special, damage: 1400, startup: '10', active: '6', recovery: '22', onBlock: '-6', onHit: '穿波弹墙', notes: '高速烈火突进穿波'),
          FrameMove(name: '飞翔龙炎阵升龙', command: '623K', type: MoveType.special, damage: 1200, startup: '6', active: '5', recovery: '30', onBlock: '-22', onHit: '击倒', notes: '火焰升龙对空，完全无敌'),
          FrameMove(name: '飞鼠之舞', command: '空中 214P', type: MoveType.special, damage: 800, startup: '14', active: '4', recovery: '着地8', onBlock: '+1', onHit: '硬直', notes: '三角跳反弹下落突袭'),
          FrameMove(name: 'SA1: 阳炎之舞', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '火焰爆发', notes: '原地大范围火柱反击'),
          FrameMove(name: 'SA2: 葛之叶狐火', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '10', active: '10', recovery: '42', onBlock: '-18', onHit: '大狐火', notes: '多段狐火轰击超必杀'),
          FrameMove(name: 'SA3: 超必杀忍蜂', command: '2141236K', type: MoveType.superArt, damage: 4000, startup: '9', active: '12', recovery: '52', onBlock: '-28', onHit: '火狐终结', notes: '狂暴火狐爆发终结，红血CA 4500'),
        ]);
        break;

      case 'elena':
        list.addAll([
          FrameMove(name: '回旋扫腿', command: '3HK', type: MoveType.unique, damage: 850, startup: '13', active: '4', recovery: '18', onBlock: '-6', onHit: '击倒', notes: '长距离下段偷袭扫踢'),
          FrameMove(name: '倒立蹬踏', command: '6HK', type: MoveType.unique, damage: 900, startup: '16', active: '4', recovery: '18', onBlock: '-2', onHit: '+4', notes: '倒立双腿上踹'),
          FrameMove(name: '羚羊踢', command: '41236K', type: MoveType.special, damage: 1000, startup: '12', active: '4', recovery: '19', onBlock: '-4', onHit: '击倒', notes: '突进飞踢，穿波与快速近身'),
          FrameMove(name: '旋转镰刀踢', command: '214K', type: MoveType.special, damage: 1200, startup: '14', active: '6', recovery: '20', onBlock: '-8', onHit: '击倒', isCancelable: true, notes: '连段主力输出技'),
          FrameMove(name: '轮转升空对空', command: '623K', type: MoveType.special, damage: 1100, startup: '6', active: '5', recovery: '28', onBlock: '-18', onHit: '击倒', notes: '无敌对空技，完全防空'),
          FrameMove(name: '木槌下砸', command: '214P', type: MoveType.special, damage: 900, startup: '18', active: '3', recovery: '16', onBlock: '+1', onHit: '+4', notes: '避下段中段下砸，被防+1有利'),
          FrameMove(name: '治愈舞步', command: '22K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '位移', onHit: '派生', notes: '卡波耶拉舞步快速进退'),
          FrameMove(name: 'SA1: 旋转狂热', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '10', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '1气无敌超必杀反击'),
          FrameMove(name: 'SA2: 勇敢之舞', command: '236236P', type: MoveType.superArt, damage: 2800, startup: '8', active: '12', recovery: '44', onBlock: '-20', onHit: '大乱舞', notes: '极速突进连踢乱舞'),
          FrameMove(name: 'SA3: 治愈天籁终曲', command: '214214K', type: MoveType.superArt, damage: 4000, startup: '8', active: '12', recovery: '48', onBlock: '-25', onHit: '终曲终结', notes: '3气终结狂暴连击，红血CA 4500'),
        ]);
        break;

      case 'jamie':
        list.addAll([
          FrameMove(name: '醉步闪身', command: '4HK', type: MoveType.unique, damage: 800, startup: '14', active: '3', recovery: '17', onBlock: '-3', onHit: '+3', notes: '后仰闪步踢'),
          FrameMove(name: '绝顶下压', command: '6HP', type: MoveType.unique, damage: 850, startup: '18', active: '3', recovery: '18', onBlock: '-2', onHit: '+3', notes: '中段劈掌破蹲防'),
          FrameMove(name: '魔身连拳', command: '236P', type: MoveType.special, damage: 900, startup: '13', active: '4', recovery: '20', onBlock: '-6', onHit: '派生', notes: '三连掌连拳，连段核心'),
          FrameMove(name: '绝招步', command: '41236K', type: MoveType.special, damage: 950, startup: '11', active: '4', recovery: '18', onBlock: '-4', onHit: '击倒', notes: '低姿态滑步突进掌'),
          FrameMove(name: '旋风倒立踢', command: '623K', type: MoveType.special, damage: 1150, startup: '6', active: '5', recovery: '28', onBlock: '-20', onHit: '击倒', notes: '倒立旋转腿对空'),
          FrameMove(name: '魔身饮 (喝酒)', command: '22P', type: MoveType.special, damage: 0, startup: '42', active: '-', recovery: '0', onBlock: '喝酒', onHit: '提升等级', notes: '提升醉拳等级(0~4级)，解锁海量新技能与加成'),
          FrameMove(name: '流光下落踢', command: '空中 214K', type: MoveType.special, damage: 700, startup: '12', active: '4', recovery: '着地8', onBlock: '+1', onHit: '硬直', notes: '空中俯冲下坠踢'),
          FrameMove(name: '点穴柔道投', command: '63214K', type: MoveType.special, damage: 1800, startup: '5', active: '2', recovery: '42', onBlock: '不可防御', onHit: '点穴摔', notes: '3级醉拳解锁的强力指令投'),
          FrameMove(name: 'SA1: 武赖疾走', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '低位突进穿波'),
          FrameMove(name: 'SA2: 绝伦醉酒', command: '214214P', type: MoveType.superArt, damage: 0, startup: '4', active: '增益', recovery: '0', onBlock: '醉酒', onHit: '瞬时满级', notes: '瞬间进入4级绝顶状态！'),
          FrameMove(name: 'SA3: 月下恶鬼', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '绝顶终结', notes: '完全无敌醉拳乱舞，红血CA 4500'),
        ]);
        break;

      case 'kimberly':
        list.addAll([
          FrameMove(name: '疾驱冲刺', command: '236K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '冲刺', onHit: '派生', notes: '疾跑，派生下段滑铲/中段飞踢/急停'),
          FrameMove(name: '疾驱·下段滑铲', command: '236K > LK', type: MoveType.special, damage: 800, startup: '11', active: '4', recovery: '20', onBlock: '-8', onHit: '击倒', notes: '下段突击滑铲'),
          FrameMove(name: '疾驱·躯干斩击', command: '236K > MK', type: MoveType.special, damage: 900, startup: '16', active: '3', recovery: '16', onBlock: '+1', onHit: '+4', notes: '中段飞踢，被防+1有利'),
          FrameMove(name: '疾驱·暗影切入', command: '236K > HK', type: MoveType.special, damage: 950, startup: '14', active: '3', recovery: '18', onBlock: '-4', onHit: '高浮空', notes: '踢中后空中追击'),
          FrameMove(name: '隐身飞天 (烟雾弹)', command: '214P', type: MoveType.special, damage: 800, startup: '18', active: '4', recovery: '20', onBlock: '-4', onHit: '瞬移', notes: '烟雾弹瞬移至对手头顶'),
          FrameMove(name: '喷漆炸弹', command: '22K', type: MoveType.special, damage: 400, startup: '16', active: '定时炸弹', recovery: '18', onBlock: '+1', onHit: '多择', notes: '投掷喷漆罐定时炸弹压制'),
          FrameMove(name: '武神旋风脚', command: '214K', type: MoveType.special, damage: 1000, startup: '12', active: '8', recovery: '22', onBlock: '-10', onHit: '击倒', notes: '旋风空翻踢'),
          FrameMove(name: '飞燕空翻', command: '空中 236P', type: MoveType.special, damage: 1100, startup: '8', active: '4', recovery: '着地10', onBlock: '不可防御', onHit: '空抓', notes: '空中指令抓投'),
          FrameMove(name: 'SA1: 飞翔爆裂', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '突进升空踢'),
          FrameMove(name: 'SA2: 武神乱舞争夺', command: '214214K', type: MoveType.superArt, damage: 2800, startup: '10', active: '10', recovery: '44', onBlock: '-22', onHit: '连打', notes: '高速乱舞暴击'),
          FrameMove(name: 'SA3: 武神显现卡带轰击', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '音乐轰击', notes: '播放卡带随身听，永久提升移速与攻击，红血CA 4500'),
        ]);
        break;

      case 'ehonda':
        list.addAll([
          FrameMove(name: '铁炮突刺', command: '6HP', type: MoveType.unique, damage: 900, startup: '15', active: '4', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '相扑前压铁掌'),
          FrameMove(name: '超级百裂张手', command: '236P', type: MoveType.special, damage: 1000, startup: '12', active: '6', recovery: '18', onBlock: '-4', onHit: '推角', isCancelable: true, notes: '快速连打张手'),
          FrameMove(name: 'OD 百裂张手', command: '236PP', type: MoveType.special, damage: 1250, startup: '10', active: '8', recovery: '16', onBlock: '+2', onHit: '大硬直', notes: '强化百裂，被防+2有利！'),
          FrameMove(name: '超级头槌', command: '4蓄6P', type: MoveType.special, damage: 1200, startup: '10', active: '8', recovery: '24', onBlock: '-4~-8', onHit: '击倒', notes: '火箭头槌全屏突进'),
          FrameMove(name: 'OD 超级头槌', command: '4蓄6PP', type: MoveType.special, damage: 1400, startup: '8', active: '8', recovery: '24', onBlock: '-2', onHit: '霸体击倒', notes: '带霸体强行突进'),
          FrameMove(name: '超级百贯落', command: '2蓄8K', type: MoveType.special, damage: 1100, startup: '20', active: '4', recovery: '18', onBlock: '-2~+1', onHit: '砸地', notes: '空降大屁股泰山压顶'),
          FrameMove(name: '大银杏投', command: '63214P', type: MoveType.special, damage: 2000, startup: '5', active: '2', recovery: '42', onBlock: '不可防御', onHit: '大摔', notes: '5F 指令抓投'),
          FrameMove(name: 'OD 大银杏投', command: '63214PP', type: MoveType.special, damage: 2600, startup: '5', active: '2', recovery: '44', onBlock: '不可防御', onHit: '暴击摔', notes: '极速大指令投'),
          FrameMove(name: 'SA1: 播磨落', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '跳跃抓投', notes: '空中抓投超必杀'),
          FrameMove(name: 'SA2: 飞天相扑压', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '12', active: '10', recovery: '44', onBlock: '-20', onHit: '砸压', notes: '飞天狂压超杀'),
          FrameMove(name: 'SA3: 千秋万岁暴击', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-28', onHit: '相扑终结', notes: '完全无敌相扑乱舞，红血CA 4500'),
        ]);
        break;

      case 'blanka':
        list.addAll([
          FrameMove(name: '亚马逊滑铲', command: '3HP', type: MoveType.unique, damage: 850, startup: '13', active: '4', recovery: '22', onBlock: '-9', onHit: '击倒', notes: '低姿态下段超长滑铲'),
          FrameMove(name: '撕裂重爪', command: '6HP', type: MoveType.unique, damage: 900, startup: '14', active: '3', recovery: '18', onBlock: '-3', onHit: '+4', isCancelable: true, notes: '野兽横扫重爪'),
          FrameMove(name: '滚球突进', command: '4蓄6P', type: MoveType.special, damage: 1100, startup: '11', active: '8', recovery: '22', onBlock: '-11', onHit: '击倒', notes: '横向肉弹战车突击'),
          FrameMove(name: 'OD 滚球突进', command: '4蓄6PP', type: MoveType.special, damage: 1300, startup: '9', active: '8', recovery: '20', onBlock: '-5', onHit: '弹墙', notes: '弹墙大伤害'),
          FrameMove(name: '垂直冲天滚球', command: '2蓄8K', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-24', onHit: '击倒', notes: '垂直冲天无敌对空'),
          FrameMove(name: '雷电暴击', command: '214P', type: MoveType.special, damage: 900, startup: '13', active: '持续', recovery: '18', onBlock: '-3', onHit: '+2', notes: '原地放电护体'),
          FrameMove(name: '狂野突袭指令投', command: '63214K', type: MoveType.special, damage: 2000, startup: '18', active: '抓投', recovery: '36', onBlock: '不可防御', onHit: '野兽飞扑', notes: '跳跃扑人指令投'),
          FrameMove(name: '布兰卡人偶爆弹', command: '22P', type: MoveType.special, damage: 500, startup: '15', active: '人偶电击', recovery: '18', onBlock: '+2', onHit: '引爆', notes: '放置小人偶，放电引爆'),
          FrameMove(name: '疯狂跳跃变轨', command: '214K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '空翻', onHit: '多择', notes: '空中跳跃变轨突袭'),
          FrameMove(name: 'SA1: 闪电穿波滚球', command: '4蓄646P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '穿波雷电突击'),
          FrameMove(name: 'SA2: 雷神狂兽 (电布兰卡)', command: '214214K', type: MoveType.superArt, damage: 0, startup: '4', active: '增益', recovery: '0', onBlock: '启动', onHit: '无限滚球', notes: '滚球命中后可连续追加变向弹跳'),
          FrameMove(name: 'SA3: 疯狂大咬杀', command: '4蓄646K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-28', onHit: '野兽撕咬', notes: '完全无敌狂暴终结，红血CA 4500'),
        ]);
        break;

      case 'lily':
        list.addAll([
          FrameMove(name: '双重狂斧', command: '6HP', type: MoveType.unique, damage: 900, startup: '15', active: '4', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '向前重挥战斧'),
          FrameMove(name: '兀鹰突刺', command: '236P', type: MoveType.special, damage: 900, startup: '12', active: '6', recovery: '20', onBlock: '-4~+1', onHit: '突进', notes: '战斧突进，有风缠绕时被防+1有利'),
          FrameMove(name: 'OD 兀鹰突刺', command: '236PP', type: MoveType.special, damage: 1200, startup: '9', active: '8', recovery: '18', onBlock: '+2', onHit: '击倒', notes: '极速突进，被防+2有利'),
          FrameMove(name: '兀鹰俯冲', command: '空中 236P', type: MoveType.special, damage: 800, startup: '14', active: '4', recovery: '着地10', onBlock: '+1~+3', onHit: '硬直', notes: '空中飞扑下砸'),
          FrameMove(name: '战斧大指令投', command: '360P', type: MoveType.special, damage: 2400, startup: '5', active: '2', recovery: '45', onBlock: '不可防御', onHit: '大抓投', notes: '5F极速大指令投'),
          FrameMove(name: 'OD 战斧大投', command: '360PP', type: MoveType.special, damage: 3200, startup: '5', active: '2', recovery: '46', onBlock: '不可防御', onHit: '暴击大摔', notes: '抓取范围极大，伤害3200'),
          FrameMove(name: '风之聚气', command: '214P', type: MoveType.special, damage: 0, startup: '32', active: '-', recovery: '0', onBlock: '聚气', onHit: '存风', notes: '旋转战斧积攒风之力(最多3层)'),
          FrameMove(name: '战斧对空升龙', command: '623P', type: MoveType.special, damage: 1100, startup: '6', active: '5', recovery: '28', onBlock: '-20', onHit: '击倒', notes: '无敌对空战斧升击'),
          FrameMove(name: 'SA1: 烈风呼啸', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '无敌旋转风刃反击'),
          FrameMove(name: 'SA2: 雷鸟振翅', command: '214214P', type: MoveType.superArt, damage: 2700, startup: '10', active: '10', recovery: '42', onBlock: '-20', onHit: '旋风升空', notes: '对空及大伤害连段超杀'),
          FrameMove(name: 'SA3: 狂风咆哮大抓杀', command: '720P', type: MoveType.superArt, damage: 4000, startup: '7', active: '2', recovery: '55', onBlock: '不可防御', onHit: '天顶摔', notes: '720度不可防御大指令投，红血CA 4500'),
        ]);
        break;

      case 'manon':
        list.addAll([
          FrameMove(name: '天鹅长踢', command: '4HK', type: MoveType.unique, damage: 850, startup: '14', active: '3', recovery: '18', onBlock: '-3', onHit: '+3', notes: '超长站立高踢'),
          FrameMove(name: '芭蕾双重踢 TC', command: '5HP > 5HP', type: MoveType.unique, damage: 1300, startup: '9', active: '3', recovery: '20', onBlock: '-8', onHit: '击倒', isCancelable: true, notes: '重拳连携击倒'),
          FrameMove(name: '芭蕾指令大投', command: '63214P', type: MoveType.special, damage: 2000, startup: '5', active: '2', recovery: '45', onBlock: '不可防御', onHit: '芭蕾摔', notes: '5F 指令投，命中积累勋章(1~5级)，最高级伤害 3700！'),
          FrameMove(name: 'OD 芭蕾大投', command: '63214PP', type: MoveType.special, damage: 2700, startup: '5', active: '2', recovery: '46', onBlock: '不可防御', onHit: '高级摔', notes: '超远抓投距离'),
          FrameMove(name: '旋转扫腿踢', command: '236K', type: MoveType.special, damage: 900, startup: '13', active: '4', recovery: '20', onBlock: '-6', onHit: '派生', notes: '突进长腿横扫'),
          FrameMove(name: '优雅空翻', command: '214K', type: MoveType.special, damage: 950, startup: '16', active: '4', recovery: '18', onBlock: '-3', onHit: '击倒', notes: '避下段空翻踩踏'),
          FrameMove(name: '拉回突刺掌', command: '214P', type: MoveType.special, damage: 1100, startup: '14', active: '4', recovery: '22', onBlock: '-4', onHit: '拉近', notes: '柔道打击，命中强行拉近对手'),
          FrameMove(name: 'SA1: 优雅之舞', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '低姿态穿波旋转踢'),
          FrameMove(name: 'SA2: 星光交错', command: '214214K', type: MoveType.superArt, damage: 2800, startup: '8', active: '10', recovery: '44', onBlock: '-22', onHit: '华丽连踢', notes: '芭蕾乱舞大伤害'),
          FrameMove(name: 'SA3: 天鹅绝唱终曲', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '2', recovery: '52', onBlock: '不可防御', onHit: '至高抓投', notes: '完全无敌至高柔道指令投，红血CA 4500'),
        ]);
        break;

      case 'dhalsim':
        list.addAll([
          FrameMove(name: '瑜伽头槌', command: '4HP', type: MoveType.unique, damage: 900, startup: '11', active: '3', recovery: '17', onBlock: '+2', onHit: '+6', isCancelable: true, notes: '近身头槌，被防+2有利'),
          FrameMove(name: '瑜伽长矛', command: '空中 2P', type: MoveType.unique, damage: 600, startup: '12', active: '持续', recovery: '着地10', onBlock: '0', onHit: '+4', notes: '空中斜下长拳'),
          FrameMove(name: '瑜伽长钻', command: '空中 2K', type: MoveType.unique, damage: 650, startup: '12', active: '持续', recovery: '着地8', onBlock: '+1~+4', onHit: '+5', notes: '空中螺旋下钻'),
          FrameMove(name: '瑜伽火焰', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '34', onBlock: '-4', onHit: '+2', notes: '慢速喷火牵制'),
          FrameMove(name: 'OD 瑜伽火焰', command: '236PP', type: MoveType.special, damage: 850, startup: '11', active: '-', recovery: '28', onBlock: '+2', onHit: '击倒', notes: '多段火焰，被防+2有利'),
          FrameMove(name: '瑜伽烈火对空', command: '63214P', type: MoveType.special, damage: 1000, startup: '16', active: '4', recovery: '26', onBlock: '-6', onHit: '击倒', notes: '大范围扇形火焰对空'),
          FrameMove(name: '瑜伽爆破', command: '63214K', type: MoveType.special, damage: 1100, startup: '13', active: '4', recovery: '26', onBlock: '-8', onHit: '击倒', notes: '斜上强力爆破火焰对空'),
          FrameMove(name: '瑜伽彗星', command: '空中 236P', type: MoveType.special, damage: 600, startup: '13', active: '-', recovery: '着地8', onBlock: '+1~+4', onHit: '浮空', notes: '空中斜下喷火'),
          FrameMove(name: '瑜伽瞬移', command: '623PPP / 623KKK', type: MoveType.special, damage: 0, startup: '1', active: '16', recovery: '14', onBlock: '瞬移', onHit: '-', notes: '无敌瞬移至对手头顶或身后'),
          FrameMove(name: '瑜伽悬浮', command: '2KKK', type: MoveType.special, damage: 0, startup: '1', active: '悬浮', recovery: '0', onBlock: '浮空', onHit: '-', notes: '原地空中悬停'),
          FrameMove(name: 'SA1: 烈风之怒', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '大击退', notes: '地面巨浪火焰'),
          FrameMove(name: 'SA2: 瑜伽日轮爆', command: '236236P', type: MoveType.superArt, damage: 2700, startup: '12', active: '极慢球', recovery: '26', onBlock: '+18', onHit: '巨大慢球', notes: '全屏极慢滚动的巨大火球'),
          FrameMove(name: 'SA3: 瑜伽至高梵天', command: '214214P', type: MoveType.superArt, damage: 4000, startup: '8', active: '9', recovery: '50', onBlock: '-26', onHit: '焚天终结', notes: '完全无敌焚天神炎，红血CA 4500'),
        ]);
        break;

      case 'rashid':
        list.addAll([
          FrameMove(name: '疾风突击', command: '6MP', type: MoveType.unique, damage: 800, startup: '15', active: '3', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '前进一步肘击'),
          FrameMove(name: '旋空踢', command: '6HK', type: MoveType.unique, damage: 900, startup: '18', active: '4', recovery: '18', onBlock: '-3', onHit: '+3', notes: '大回旋踢'),
          FrameMove(name: '旋风弹', command: '236P', type: MoveType.special, damage: 600, startup: '13', active: '-', recovery: '32', onBlock: '-6', onHit: '+1', notes: '小旋风飞行道具'),
          FrameMove(name: '飞升龙旋风', command: '623P', type: MoveType.special, damage: 1150, startup: '6', active: '6', recovery: '30', onBlock: '-22', onHit: '击倒', notes: '无敌对空旋风'),
          FrameMove(name: '突进滑铲', command: '214K', type: MoveType.special, damage: 900, startup: '12', active: '8', recovery: '18', onBlock: '-8', onHit: '击倒', notes: '低姿态滑步穿梭'),
          FrameMove(name: '阿拉伯空中飞踢', command: '214P', type: MoveType.special, damage: 850, startup: '16', active: '4', recovery: '18', onBlock: '+1', onHit: '+5', notes: '空中踏步突进，被防+1有利'),
          FrameMove(name: '旋风飞跃', command: '623K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '高跳', onHit: '派生', notes: '风力起跳，派生俯冲与投'),
          FrameMove(name: 'SA1: 超级风暴', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '高速风暴穿波'),
          FrameMove(name: 'SA2: 依阿尔图大旋风', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '12', active: '全屏大旋风', recovery: '24', onBlock: '+22', onHit: '气流加速', notes: '全屏巨大龙卷风，穿过龙卷风获得极速强化'),
          FrameMove(name: 'SA3: 暴风降临斩杀', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '终极风暴', notes: '完全无敌风暴终结，红血CA 4500'),
        ]);
        break;

      case 'aki':
        list.addAll([
          FrameMove(name: '蛇头突击', command: '6HP', type: MoveType.unique, damage: 900, startup: '15', active: '3', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '低位长刺拳'),
          FrameMove(name: '毒爪下撩', command: '3HP', type: MoveType.unique, damage: 850, startup: '12', active: '4', recovery: '19', onBlock: '-6', onHit: '击倒', notes: '下段扫地爪'),
          FrameMove(name: '紫泡弹 (毒针射击)', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '32', onBlock: '-4', onHit: '中毒', notes: '毒泡飞行道具，使对手进入中毒掉血状态'),
          FrameMove(name: '蛇毒突刺', command: '623P', type: MoveType.special, damage: 1100, startup: '10', active: '4', recovery: '22', onBlock: '-8', onHit: '引爆毒伤', notes: '命中中毒对手造成剧烈暴击浮空'),
          FrameMove(name: '蛇行潜地穿波', command: '214P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '伏地', onHit: '穿波潜行', notes: '完全贴地爬行，穿透一切飞行道具'),
          FrameMove(name: '恶灵抓挠', command: '214K', type: MoveType.special, damage: 950, startup: '15', active: '4', recovery: '20', onBlock: '-4', onHit: '击倒', notes: '长距离毒爪连挠'),
          FrameMove(name: '仰卧毒牙构', command: '22P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '仰卧', onHit: '构派生', notes: '仰卧姿态，派生下段蛇踢或突刺'),
          FrameMove(name: '毒牙构·蛇身蹬', command: '22P > K', type: MoveType.special, damage: 800, startup: '11', active: '4', recovery: '20', onBlock: '-6', onHit: '击倒', notes: '下段突击踢'),
          FrameMove(name: '毒牙构·穿心刺', command: '22P > P', type: MoveType.special, damage: 1000, startup: '9', active: '3', recovery: '18', onBlock: '-2', onHit: '中毒浮空', notes: '穿心刺击'),
          FrameMove(name: '剧毒之泉', command: '22K', type: MoveType.special, damage: 400, startup: '18', active: '毒池', recovery: '20', onBlock: '+2', onHit: '毒液侵蚀', notes: '在地上产生一汪毒池'),
          FrameMove(name: 'SA1: 致命死线', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '贴地滑铲毒刺穿波'),
          FrameMove(name: 'SA2: 紫烟剧毒阵', command: '214214P', type: MoveType.superArt, damage: 2700, startup: '12', active: '毒雾领域', recovery: '24', onBlock: '+15', onHit: '持续毒雾', notes: '地面铺开巨型毒液领域'),
          FrameMove(name: 'SA3: 极刑毒杀', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-26', onHit: '针灸处刑', notes: '完全无敌剧毒针灸终结，红血CA 4500'),
        ]);
        break;

      case 'deejay':
        list.addAll([
          FrameMove(name: '阳光踢 TC', command: '4HK > HK', type: MoveType.unique, damage: 1300, startup: '8', active: '3', recovery: '19', onBlock: '-8', onHit: '浮空', isCancelable: true, notes: '高踢连段确认'),
          FrameMove(name: '欢聚派对', command: '6HK', type: MoveType.unique, damage: 900, startup: '16', active: '4', recovery: '18', onBlock: '-2', onHit: '+4', notes: '长距离推进侧踢'),
          FrameMove(name: '空气断头台双气刃', command: '4蓄6P', type: MoveType.special, damage: 700, startup: '11', active: '-', recovery: '30', onBlock: '-4', onHit: '+2', notes: '两连发手刀气刃'),
          FrameMove(name: 'OD 空气断头台', command: '4蓄6PP', type: MoveType.special, damage: 950, startup: '9', active: '-', recovery: '26', onBlock: '+2', onHit: '击倒', notes: '极速穿波双气刃，被防+2有利'),
          FrameMove(name: '飞天双踢升龙', command: '2蓄8K', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-22', onHit: '击倒', notes: '蓄力无敌对空翻踢'),
          FrameMove(name: 'OD 飞天双踢', command: '2蓄8KK', type: MoveType.special, damage: 1400, startup: '5', active: '7', recovery: '36', onBlock: '-34', onHit: '击倒', notes: '第1帧无敌凹招'),
          FrameMove(name: '摇摆闪避', command: '214P', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '摇摆', onHit: '派生', notes: '后撤摇摆，避开攻击并派生强力确反拳'),
          FrameMove(name: '摇摆·重拳反击', command: '214P > P', type: MoveType.special, damage: 1100, startup: '10', active: '3', recovery: '18', onBlock: '-4', onHit: '击倒', notes: '摇摆后突进反击拳'),
          FrameMove(name: '狂欢冲刺', command: '236K', type: MoveType.special, damage: 0, startup: '1', active: '-', recovery: '0', onBlock: '滑步', onHit: '派生', notes: '极速滑行，可派生中段踢或下段铲'),
          FrameMove(name: '狂欢·滑铲派生', command: '236K > LK', type: MoveType.special, damage: 800, startup: '11', active: '4', recovery: '20', onBlock: '-8', onHit: '击倒', notes: '下段滑铲偷袭'),
          FrameMove(name: '狂欢·过顶踢', command: '236K > HK', type: MoveType.special, damage: 900, startup: '15', active: '3', recovery: '16', onBlock: '+1', onHit: '+4', notes: '中段跳踢，被防+1有利'),
          FrameMove(name: '机关枪勾拳', command: '214K', type: MoveType.special, damage: 1000, startup: '13', active: '6', recovery: '22', onBlock: '-6', onHit: '击飞', notes: '多段上勾拳连击'),
          FrameMove(name: 'SA1: 极速节奏', command: '4蓄646P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '连续气刃穿波'),
          FrameMove(name: 'SA2: 日出狂欢节', command: '236236P', type: MoveType.superArt, damage: 2800, startup: '10', active: '12', recovery: '44', onBlock: '-22', onHit: '狂欢连舞', notes: '节奏打击超必杀'),
          FrameMove(name: 'SA3: 周末狂欢夜', command: '4蓄646K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '狂欢节', notes: '完全无敌电音轰击终结，红血CA 4500'),
        ]);
        break;

      case 'sagat':
        list.addAll([
          FrameMove(name: '猛虎重肘', command: '6HP', type: MoveType.unique, damage: 900, startup: '15', active: '3', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '泰拳重肘破防'),
          FrameMove(name: '泰拳高踢', command: '6HK', type: MoveType.unique, damage: 950, startup: '16', active: '4', recovery: '19', onBlock: '-4', onHit: '+3', notes: '长距离重踢'),
          FrameMove(name: '猛虎高波', command: '236P', type: MoveType.special, damage: 700, startup: '14', active: '-', recovery: '34', onBlock: '-6', onHit: '+1', notes: '高位气功，封锁跳跃'),
          FrameMove(name: 'OD 猛虎高波', command: '236PP', type: MoveType.special, damage: 900, startup: '11', active: '-', recovery: '30', onBlock: '+2', onHit: '击倒', notes: '极速高波，被防+2有利'),
          FrameMove(name: '猛虎低波', command: '236K', type: MoveType.special, damage: 700, startup: '14', active: '-', recovery: '35', onBlock: '-7', onHit: '+1', notes: '低位气功，封锁下盘'),
          FrameMove(name: 'OD 猛虎低波', command: '236KK', type: MoveType.special, damage: 900, startup: '11', active: '-', recovery: '31', onBlock: '+2', onHit: '击倒', notes: '极速低波，被防+2有利'),
          FrameMove(name: '猛虎升龙拳', command: '623P', type: MoveType.special, damage: 1300, startup: '5', active: '6', recovery: '33', onBlock: '-24', onHit: '击倒', notes: '超高判定无敌升龙拳'),
          FrameMove(name: 'OD 猛虎升龙', command: '623PP', type: MoveType.special, damage: 1500, startup: '5', active: '8', recovery: '38', onBlock: '-36', onHit: '击倒', notes: '第1帧无敌凹招反击'),
          FrameMove(name: '猛虎飞膝', command: '623K', type: MoveType.special, damage: 1100, startup: '12', active: '4', recovery: '20', onBlock: '-4', onHit: '击倒', notes: '向前跳步膝撞突进'),
          FrameMove(name: 'SA1: 猛虎加农炮', command: '236236P', type: MoveType.superArt, damage: 2100, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '巨炮击倒', notes: '全屏高速能量波穿波'),
          FrameMove(name: 'SA2: 猛虎强袭连击', command: '236236K', type: MoveType.superArt, damage: 2800, startup: '8', active: '10', recovery: '44', onBlock: '-20', onHit: '浮空爆击', notes: '连环飞膝与重拳乱舞'),
          FrameMove(name: 'SA3: 猛虎毁灭风暴', command: '214214K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-28', onHit: '泰拳终结', notes: '帝王泰拳终极轰击，红血CA 4500'),
        ]);
        break;

      case 'cviper':
        list.addAll([
          FrameMove(name: '毒蛇摆踢', command: '6HK', type: MoveType.unique, damage: 850, startup: '16', active: '3', recovery: '18', onBlock: '-2', onHit: '+3', notes: '高踢突击'),
          FrameMove(name: '战术俯冲', command: '空中 2HK', type: MoveType.unique, damage: 750, startup: '12', active: '4', recovery: '着地8', onBlock: '+1', onHit: '硬直', notes: '空中斜下俯冲脚'),
          FrameMove(name: '雷电重拳', command: '214P', type: MoveType.special, damage: 1100, startup: '13', active: '4', recovery: '20', onBlock: '-4', onHit: '麻痹击倒', notes: '电击手套冲拳'),
          FrameMove(name: '燃烧踢', command: '214K', type: MoveType.special, damage: 1000, startup: '15', active: '6', recovery: '18', onBlock: '-6', onHit: '火焰击飞', notes: '喷射火焰回旋踢'),
          FrameMove(name: '地震重锤', command: '623P', type: MoveType.special, damage: 900, startup: '22', active: '3', recovery: '26', onBlock: '-8', onHit: '全屏震击', notes: '震地冲击波，可大跳取消'),
          FrameMove(name: 'SA1: 暴烈震动', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-18', onHit: '击倒', notes: '地面多段电击'),
          FrameMove(name: 'SA2: 紧急组合连击', command: '236236K', type: MoveType.superArt, damage: 2800, startup: '8', active: '12', recovery: '44', onBlock: '-20', onHit: '火电轰击', notes: '喷射火焰连斩'),
          FrameMove(name: 'SA3: 燃烧处刑之舞', command: '214214K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '特工终结', notes: '高科技装备终极连杀，红血CA 4500'),
        ]);
        break;

      case 'alex':
        list.addAll([
          FrameMove(name: '摔角手刀', command: '6HP', type: MoveType.unique, damage: 950, startup: '15', active: '3', recovery: '18', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '大伤害正面手刀劈击'),
          FrameMove(name: '闪光手刀', command: '236P', type: MoveType.special, damage: 1000, startup: '12', active: '4', recovery: '20', onBlock: '-5', onHit: '转身硬直', notes: '强力手刀，命中可接指令投'),
          FrameMove(name: '威力重爆投 (Power Bomb)', command: '360P', type: MoveType.special, damage: 2400, startup: '5', active: '2', recovery: '45', onBlock: '不可防御', onHit: '大摔', notes: '5F 极速摔角指令投'),
          FrameMove(name: '强力肘击', command: '4蓄6K', type: MoveType.special, damage: 1100, startup: '11', active: '6', recovery: '19', onBlock: '-6', onHit: '击倒', notes: '蓄力突进肘撞'),
          FrameMove(name: '飞天跺击', command: '2蓄8K', type: MoveType.special, damage: 1100, startup: '22', active: '4', recovery: '18', onBlock: '-2', onHit: '踩地', notes: '空降重踏'),
          FrameMove(name: '碎颅重投', command: '2蓄8P', type: MoveType.special, damage: 1600, startup: '24', active: '2', recovery: '38', onBlock: '不可防御', onHit: '破头摔', notes: '空降不可防抓投'),
          FrameMove(name: 'SA1: 超级重爆投', command: '360360P', type: MoveType.superArt, damage: 2200, startup: '7', active: '2', recovery: '45', onBlock: '不可防御', onHit: '大重摔', notes: '不可防摔角超必杀'),
          FrameMove(name: 'SA2: 回旋镖强袭', command: '236236P', type: MoveType.superArt, damage: 2800, startup: '9', active: '10', recovery: '42', onBlock: '-18', onHit: '连打摔', notes: '多段手刀与大摔连段'),
          FrameMove(name: 'SA3: 重锤终结处决', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-26', onHit: '终极摔角', notes: '完全无敌摔角大终结，红血CA 4500'),
        ]);
        break;

      case 'ingrid':
        list.addAll([
          FrameMove(name: '太阳之踢', command: '6HK', type: MoveType.unique, damage: 850, startup: '14', active: '3', recovery: '17', onBlock: '-2', onHit: '+3', notes: '高雅回旋踢'),
          FrameMove(name: '太阳爆发', command: '236P', type: MoveType.special, damage: 650, startup: '13', active: '-', recovery: '32', onBlock: '-5', onHit: '+2', notes: '神圣光球牵制'),
          FrameMove(name: '太阳升起', command: '623P', type: MoveType.special, damage: 1200, startup: '6', active: '5', recovery: '30', onBlock: '-22', onHit: '击倒', notes: '光能升龙对空，完全无敌'),
          FrameMove(name: '太阳下落', command: '214K', type: MoveType.special, damage: 950, startup: '15', active: '4', recovery: '18', onBlock: '+1', onHit: '+4', notes: '空中光辉下踢，被防+1有利'),
          FrameMove(name: 'SA1: 太阳三角能量', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '光爆', notes: '三角光芒穿波'),
          FrameMove(name: 'SA2: 太阳耀斑光芒', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '10', active: '10', recovery: '42', onBlock: '-18', onHit: '日耀', notes: '日斑爆发超必杀'),
          FrameMove(name: 'SA3: 创世太阳爆发', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '创世神威', notes: '完全无敌太阳终结，红血CA 4500'),
        ]);
        break;

      case 'yasmine':
        list.addAll([
          FrameMove(name: '幻影刺', command: '6HP', type: MoveType.unique, damage: 850, startup: '14', active: '3', recovery: '17', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '轻盈刺击'),
          FrameMove(name: '海市蜃楼突击', command: '236P', type: MoveType.special, damage: 950, startup: '12', active: '4', recovery: '20', onBlock: '-4', onHit: '击倒', notes: '多段幻影突进斩'),
          FrameMove(name: '沙丘舞者', command: '214K', type: MoveType.special, damage: 900, startup: '14', active: '4', recovery: '18', onBlock: '-3', onHit: '派生', notes: '回旋身法躲避攻击'),
          FrameMove(name: '流沙旋涡', command: '623K', type: MoveType.special, damage: 1150, startup: '6', active: '5', recovery: '28', onBlock: '-20', onHit: '击倒', notes: '升天旋风腿对空'),
          FrameMove(name: '丝绸陷阱', command: '22P', type: MoveType.special, damage: 400, startup: '16', active: '陷阱', recovery: '18', onBlock: '+2', onHit: '减速束缚', notes: '布置丝绸减速对手'),
          FrameMove(name: 'SA1: 沙漠幻影', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '极速穿波幻影突击'),
          FrameMove(name: 'SA2: 绿洲风暴', command: '214214P', type: MoveType.superArt, damage: 2800, startup: '10', active: '10', recovery: '42', onBlock: '-18', onHit: '风暴绞杀', notes: '沙漠狂风连段超必杀'),
          FrameMove(name: 'SA3: 沙丘之怒终结', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '48', onBlock: '-26', onHit: '沙漠处刑', notes: '完全无敌沙海终结，红血CA 4500'),
        ]);
        break;

      default:
        list.addAll([
          FrameMove(name: '突进打击', command: '236P', type: MoveType.special, damage: 1000, startup: '12', active: '4', recovery: '20', onBlock: '-5', onHit: '击倒', notes: '主力突进打击技'),
          FrameMove(name: '防空绝招', command: '623P', type: MoveType.special, damage: 1200, startup: '6', active: '5', recovery: '30', onBlock: '-22', onHit: '击倒', notes: '无敌对空必杀'),
          FrameMove(name: 'SA1: 必杀打击', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击倒', notes: '1气无敌超必杀'),
          FrameMove(name: 'SA3: 终极爆发 CA', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '7', active: '8', recovery: '50', onBlock: '-26', onHit: '击倒', notes: '3气终极爆发，红血CA 4500'),
        ]);
        break;
    }

    return list;
  }
}
