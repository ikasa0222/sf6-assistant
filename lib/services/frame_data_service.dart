import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/core/constants/characters.dart';

class FrameDataService extends ChangeNotifier {
  String _selectedCharacterId = 'elena';
  List<FrameMove> _currentMoves = [];
  bool _isLoading = false;
  String _searchQuery = '';
  MoveType? _selectedCategory;
  bool _filterOnlyPlusOnBlock = false;
  bool _filterOnlyPunishable = false;

  String get selectedCharacterId => _selectedCharacterId;
  List<FrameMove> get currentMoves => _filteredMoves();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  MoveType? get selectedCategory => _selectedCategory;
  bool get filterOnlyPlusOnBlock => _filterOnlyPlusOnBlock;
  bool get filterOnlyPunishable => _filterOnlyPunishable;

  void selectCharacter(String charId) {
    _selectedCharacterId = charId;
    loadFrameDataForCharacter(charId);
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setSelectedCategory(MoveType? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void togglePlusOnBlockFilter() {
    _filterOnlyPlusOnBlock = !_filterOnlyPlusOnBlock;
    if (_filterOnlyPlusOnBlock) _filterOnlyPunishable = false;
    notifyListeners();
  }

  void togglePunishableFilter() {
    _filterOnlyPunishable = !_filterOnlyPunishable;
    if (_filterOnlyPunishable) _filterOnlyPlusOnBlock = false;
    notifyListeners();
  }

  List<FrameMove> _filteredMoves() {
    return _currentMoves.where((m) {
      if (_selectedCategory != null && m.type != _selectedCategory) return false;
      if (_filterOnlyPlusOnBlock && !m.isPlusOnBlock) return false;
      if (_filterOnlyPunishable && !m.isPunishableOnBlock) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return m.name.toLowerCase().contains(q) ||
               m.command.toLowerCase().contains(q) ||
               m.type.displayName.toLowerCase().contains(q) ||
               m.notes.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Future<void> loadFrameDataForCharacter(String characterId) async {
    _isLoading = true;
    notifyListeners();

    _currentMoves = _getCharacterMoves(characterId);

    _isLoading = false;
    notifyListeners();
  }

  static List<FrameMove> _getCharacterMoves(String charId) {
    final id = charId.toLowerCase();
    final moves = <FrameMove>[];

    // 1. Common Drive Mechanics
    moves.addAll([
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
        isCancelable: false,
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
        isCancelable: false,
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
        isCancelable: false,
        notes: '5F 极速近身破防投技，压制拆投核心',
      ),
    ]);

    // 2. Character-Specific Normals, Uniques & Specials
    if (id == 'elena') {
      moves.addAll([
        FrameMove(name: '站立轻脚 (5LK)', command: '5LK', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '4F最速起手抢招'),
        FrameMove(name: '蹲下轻脚 (2LK)', command: '2LK', type: MoveType.normal, damage: 250, startup: '5', active: '3', recovery: '8', onBlock: '-2', onHit: '+3', isCancelable: true, notes: '下段极速突袭'),
        FrameMove(name: '站立中脚 (5MK)', command: '5MK', type: MoveType.normal, damage: 650, startup: '7', active: '3', recovery: '14', onBlock: '-2', onHit: '+4', isCancelable: true, notes: '中距离核心立回牵制神技'),
        FrameMove(name: '蹲下中拳 (2MP)', command: '2MP', type: MoveType.normal, damage: 600, startup: '6', active: '3', recovery: '12', onBlock: '+2', onHit: '+6', isCancelable: true, notes: '被防+2F有利，打拆投与压制核心'),
        FrameMove(name: '蹲下重脚 (2HK - 旋转扫腿)', command: '2HK', type: MoveType.normal, damage: 900, startup: '9', active: '3', recovery: '23', onBlock: '-11', onHit: '击倒', isCancelable: false, notes: '大扫腿击倒，被防大确反'),
        FrameMove(name: '羚羊踢 (Rhino Horn)', command: '41236K', type: MoveType.special, damage: 1000, startup: '12', active: '4', recovery: '19', onBlock: '-4', onHit: '击倒', isCancelable: false, notes: '突进飞踢，穿波与快速近身'),
        FrameMove(name: '治愈光环 / 旋风腿 (Spin Scythe)', command: '214K', type: MoveType.special, damage: 1200, startup: '14', active: '6', recovery: '20', onBlock: '-8', onHit: '击倒', isCancelable: false, notes: '连段核心主力输出技'),
        FrameMove(name: 'Scratch Wheel (对空旋轮)', command: '623K', type: MoveType.special, damage: 1100, startup: '6', active: '5', recovery: '28', onBlock: '-18', onHit: '击倒', isCancelable: false, notes: '无敌对空技，被防大确反'),
        FrameMove(name: 'SA1: 旋转狂热 (Spin Beat)', command: '236236K', type: MoveType.superArt, damage: 2000, startup: '9', active: '10', recovery: '40', onBlock: '-16', onHit: '击倒', isCancelable: false, notes: '1气无敌超必杀反击'),
        FrameMove(name: 'SA3: 治愈之舞 (Brave Dance / Healing)', command: '214214K', type: MoveType.superArt, damage: 4000, startup: '8', active: '12', recovery: '48', onBlock: '-25', onHit: '击倒', isCancelable: false, notes: '3气狂暴连击 / 终结技'),
      ]);
    } else if (id == 'terry') {
      moves.addAll([
        FrameMove(name: '站立轻拳 (5LP)', command: '5LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '4F快速插动'),
        FrameMove(name: '蹲下中脚 (2MK)', command: '2MK', type: MoveType.normal, damage: 550, startup: '7', active: '3', recovery: '17', onBlock: '-4', onHit: '+2', isCancelable: true, notes: '下段立回主力，可接能量波/绿冲'),
        FrameMove(name: '能量波 (Power Wave)', command: '236P', type: MoveType.special, damage: 600, startup: '13', active: '-', recovery: '33', onBlock: '-6', onHit: '+1', isCancelable: false, notes: '地波飞行道具'),
        FrameMove(name: '燃烧指节 (Burn Knuckle)', command: '214P', type: MoveType.special, damage: 1100, startup: '14', active: '8', recovery: '21', onBlock: '-7', onHit: '击倒', isCancelable: false, notes: '强力突进重拳'),
        FrameMove(name: '能量升击 (Power Charge)', command: '41236K', type: MoveType.special, damage: 1000, startup: '11', active: '4', recovery: '18', onBlock: '-4', onHit: '浮空', isCancelable: false, notes: '突进顶肩撞击，连段起手'),
        FrameMove(name: '升龙裂破 (Rising Tackle)', command: '2蓄8P', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-20', onHit: '击倒', isCancelable: false, notes: '蓄力对空王牌，完全无敌'),
        FrameMove(name: 'SA1: 能量喷泉 (Power Geyser)', command: '2141236P', type: MoveType.superArt, damage: 2100, startup: '10', active: '8', recovery: '38', onBlock: '-18', onHit: '击倒', isCancelable: false, notes: '爆裂地面火柱'),
        FrameMove(name: 'SA3: 狂狼之爪 (Buster Wolf)', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '9', active: '10', recovery: '50', onBlock: '-26', onHit: '击倒', isCancelable: false, notes: 'Are you OK? 必杀终结轰击'),
      ]);
    } else if (id == 'mai') {
      moves.addAll([
        FrameMove(name: '站立轻拳 (5LP)', command: '5LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '4F抢招折扇打击'),
        FrameMove(name: '站立中拳 (5MP)', command: '5MP', type: MoveType.normal, damage: 600, startup: '6', active: '3', recovery: '13', onBlock: '+2', onHit: '+6', isCancelable: true, notes: '被防+2有利，压制主力'),
        FrameMove(name: '花蝶扇 (Kachousen)', command: '236P', type: MoveType.special, damage: 600, startup: '12', active: '-', recovery: '32', onBlock: '-4', onHit: '+2', isCancelable: false, notes: '经典飞扇牵制'),
        FrameMove(name: '必杀忍蜂 (Hissatsu Shinobi Bachi)', command: '41236K', type: MoveType.special, damage: 1200, startup: '13', active: '6', recovery: '24', onBlock: '-10', onHit: '击倒', isCancelable: false, notes: '火焰突进撞击'),
        FrameMove(name: '飞翔龙炎阵 (Ryuuenjin)', command: '623K', type: MoveType.special, damage: 1200, startup: '6', active: '5', recovery: '30', onBlock: '-22', onHit: '击倒', isCancelable: false, notes: '火焰升龙对空，完全无敌'),
        FrameMove(name: 'SA3: 超必杀忍蜂 (Chou Hissatsu Shinobi Bachi)', command: '2141236K', type: MoveType.superArt, damage: 4000, startup: '9', active: '12', recovery: '52', onBlock: '-28', onHit: '击倒', isCancelable: false, notes: '狂暴火狐爆发终结'),
      ]);
    } else if (id == 'akuma') {
      moves.addAll([
        FrameMove(name: '站立轻拳 (5LP)', command: '5LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '4F起手最速'),
        FrameMove(name: '站立中拳 (5MP)', command: '5MP', type: MoveType.normal, damage: 650, startup: '6', active: '3', recovery: '12', onBlock: '+2', onHit: '+7', isCancelable: true, notes: '被防+2有利'),
        FrameMove(name: '豪波动拳 (Gou Hadoken)', command: '236P', type: MoveType.special, damage: 650, startup: '12', active: '-', recovery: '34', onBlock: '-6', onHit: '+1', isCancelable: false, notes: '主力波牵制'),
        FrameMove(name: '斩空波动拳 (空中波)', command: '空中 236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '着地11', onBlock: '+1~+4', onHit: '硬直', isCancelable: false, notes: '空中下落波，进阶压制神器'),
        FrameMove(name: '豪升龙拳 (Gou Shoryuken)', command: '623P', type: MoveType.special, damage: 1300, startup: '5', active: '6', recovery: '33', onBlock: '-23', onHit: '击倒', isCancelable: false, notes: '最强对空，完全无敌'),
        FrameMove(name: '阿修罗闪空 (Ashura Senku)', command: '6+KKK / 4+KKK', type: MoveType.special, damage: 0, startup: '1', active: '15', recovery: '14', onBlock: '无敌位移', onHit: '-', isCancelable: true, notes: '完全无敌瞬移指令'),
        FrameMove(name: 'SA3: 祸灭 / 瞬狱杀 (Shun Goku Satsu)', command: 'LP LP 6 LK HP', type: MoveType.superArt, damage: 4500, startup: '1', active: '2', recovery: '45', onBlock: '不可防御', onHit: '一瞬千击', isCancelable: false, notes: '1F 发生全屏不可防指令投，瞬狱杀！'),
      ]);
    } else if (id == 'bison') {
      moves.addAll([
        FrameMove(name: '站立轻拳 (5LP)', command: '5LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '4F近身反击'),
        FrameMove(name: '站立强脚 (5HK)', command: '5HK', type: MoveType.normal, damage: 900, startup: '11', active: '3', recovery: '18', onBlock: '+1', onHit: '+5', isCancelable: false, notes: '超强站重脚，被防有利+1'),
        FrameMove(name: '精神爆弹 (Psycho Mine 附着)', command: '214P', type: MoveType.special, damage: 800, startup: '15', active: '4', recovery: '20', onBlock: '-4', onHit: '附着炸弹', isCancelable: false, notes: '给对手植入爆弹，后续招式引爆'),
        FrameMove(name: '双重膝压 (Psycho Crusher / Double Knee)', command: '4蓄6K', type: MoveType.special, damage: 1000, startup: '10', active: '5', recovery: '16', onBlock: '-5', onHit: '+2', isCancelable: false, notes: '核心蓄力推角神技'),
        FrameMove(name: '恶魔倒转 (Devil Reverse / Head Press)', command: '2蓄8K', type: MoveType.special, damage: 1100, startup: '22', active: '4', recovery: '14', onBlock: '+2', onHit: '击倒', isCancelable: false, notes: '空降变轨压制'),
        FrameMove(name: 'SA3: 终极精神审判 (Ultimate Psycho)', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '9', active: '10', recovery: '50', onBlock: '-25', onHit: '击倒', isCancelable: false, notes: '维加君临天下终极处刑'),
      ]);
    } else if (id == 'ken') {
      moves.addAll([
        FrameMove(name: '站立轻拳 (5LP)', command: '5LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '最速4F抢招'),
        FrameMove(name: '蹲下中脚 (2MK)', command: '2MK', type: MoveType.normal, damage: 500, startup: '8', active: '3', recovery: '17', onBlock: '-4', onHit: '+1', isCancelable: true, notes: '核心立回下段，可接绿冲/迅雷脚'),
        FrameMove(name: '波动拳 (Hadoken)', command: '236P', type: MoveType.special, damage: 600, startup: '12', active: '-', recovery: '34', onBlock: '-6', onHit: '+1', isCancelable: false, notes: '飞行道具牵制'),
        FrameMove(name: '升龙拳 (Shoryuken)', command: '623P', type: MoveType.special, damage: 1200, startup: '5', active: '6', recovery: '32', onBlock: '-23', onHit: '击倒', isCancelable: false, notes: '完全无敌升龙对空'),
        FrameMove(name: '龙卷旋风脚 (Tatsu)', command: '214K', type: MoveType.special, damage: 1000, startup: '12', active: '10', recovery: '18', onBlock: '-10', onHit: '推角运板', isCancelable: false, notes: '超长距离把对手送入版边'),
        FrameMove(name: '迅雷脚 (Jinrai Kick)', command: '236K', type: MoveType.special, damage: 800, startup: '13', active: '3', recovery: '18', onBlock: '-5', onHit: '多择派生', isCancelable: false, notes: '可派生上中下段强力多择'),
        FrameMove(name: '龙尾脚 (Dragonlash Kick)', command: '623K', type: MoveType.special, damage: 1000, startup: '24', active: '3', recovery: '16', onBlock: '+1', onHit: '+5', isCancelable: false, notes: '重龙尾被防+1有利，突进压制'),
        FrameMove(name: 'SA3: 神龙拳 (Shinryuken)', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '9', active: '8', recovery: '48', onBlock: '-24', onHit: '击倒', isCancelable: false, notes: '火焰旋风火柱爆发'),
      ]);
    } else if (id == 'luke') {
      moves.addAll([
        FrameMove(name: '站立轻拳 (5LP)', command: '5LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '4F快速插动'),
        FrameMove(name: '蹲下中拳 (2MP)', command: '2MP', type: MoveType.normal, damage: 600, startup: '6', active: '3', recovery: '13', onBlock: '+1', onHit: '+6', isCancelable: true, notes: '神级中拳，中距离立回无敌判定'),
        FrameMove(name: '沙弹气功 (Sand Blaster)', command: '236P', type: MoveType.special, damage: 600, startup: '14', active: '-', recovery: '31', onBlock: '-7', onHit: '+1', isCancelable: false, notes: '超高速即时飞行道具'),
        FrameMove(name: '升龙重拳 (Rising Uppercut)', command: '623P', type: MoveType.special, damage: 1200, startup: '6', active: '6', recovery: '30', onBlock: '-20', onHit: '击倒', isCancelable: false, notes: '无敌对空上勾拳'),
        FrameMove(name: '闪电重拳 (Flash Knuckle)', command: '214P (可蓄力)', type: MoveType.special, damage: 1100, startup: '15', active: '4', recovery: '19', onBlock: '-4', onHit: '浮空/墙弹', isCancelable: false, notes: '精准目押蓄力造成超高连段伤害'),
        FrameMove(name: 'SA3: 古烈式终结轰击 (Eraser)', command: '236236P', type: MoveType.superArt, damage: 4000, startup: '9', active: '10', recovery: '48', onBlock: '-25', onHit: '击倒', isCancelable: false, notes: '近身暴烈连拳'),
      ]);
    } else if (id == 'cammy') {
      moves.addAll([
        FrameMove(name: '站立轻拳 (5LP)', command: '5LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '4F抢招'),
        FrameMove(name: '蹲下中脚 (2MK)', command: '2MK', type: MoveType.normal, damage: 500, startup: '7', active: '3', recovery: '16', onBlock: '-4', onHit: '+1', isCancelable: true, notes: '最强7F长腿下段立回'),
        FrameMove(name: '螺旋箭 (Spiral Arrow)', command: '236K', type: MoveType.special, damage: 1000, startup: '11', active: '12', recovery: '18', onBlock: '-12', onHit: '击倒', isCancelable: false, notes: '地面突进滑铲'),
        FrameMove(name: '加农加农钉 (Cannon Spike)', command: '623K', type: MoveType.special, damage: 1200, startup: '5', active: '6', recovery: '31', onBlock: '-22', onHit: '击倒', isCancelable: false, notes: '完全无敌后空翻升龙对空'),
        FrameMove(name: '加农空闪 (Cannon Strike - 俯冲腿)', command: '前跳 214K', type: MoveType.special, damage: 600, startup: '12', active: '4', recovery: '着地8', onBlock: '+1~+3 (打脚部)', onHit: '硬直', isCancelable: false, notes: '压制核心低空俯冲腿'),
        FrameMove(name: 'SA3: 致命蜂刺 (Delta Red Assault)', command: '236236K', type: MoveType.superArt, damage: 4000, startup: '9', active: '10', recovery: '48', onBlock: '-26', onHit: '击倒', isCancelable: false, notes: '全屏极速穿波必杀'),
      ]);
    } else {
      // Universal Base Normals & Specials for all other SF6 Characters
      moves.addAll([
        FrameMove(name: '站立轻拳 (5LP)', command: '5LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '7', onBlock: '+1', onHit: '+5', isCancelable: true, notes: '最速4帧发生，近距离抢招插动'),
        FrameMove(name: '蹲下轻拳 (2LP)', command: '2LP', type: MoveType.normal, damage: 300, startup: '4', active: '3', recovery: '8', onBlock: '-1', onHit: '+4', isCancelable: true, notes: '下盘最速4帧反击'),
        FrameMove(name: '站立中拳 (5MP)', command: '5MP', type: MoveType.normal, damage: 600, startup: '6', active: '3', recovery: '13', onBlock: '+1', onHit: '+6', isCancelable: true, notes: '中距离立回牵制神技'),
        FrameMove(name: '蹲下中脚 (2MK)', command: '2MK', type: MoveType.normal, damage: 500, startup: '8', active: '3', recovery: '17', onBlock: '-4', onHit: '+1', isCancelable: true, notes: '核心下段立回牵制，可接绿冲'),
        FrameMove(name: '站立重拳 (5HP)', command: '5HP', type: MoveType.normal, damage: 800, startup: '9', active: '3', recovery: '20', onBlock: '-3', onHit: '+3', isCancelable: true, notes: '确反与强力单发牵制技'),
        FrameMove(name: '蹲下重拳 (2HP - 核心对空)', command: '2HP', type: MoveType.normal, damage: 800, startup: '8', active: '4', recovery: '22', onBlock: '-10', onHit: '+2', isCancelable: true, notes: '核心对空与打拆确反'),
        FrameMove(name: '蹲下重脚 (2HK - 扫堂腿)', command: '2HK', type: MoveType.normal, damage: 900, startup: '10', active: '3', recovery: '24', onBlock: '-12', onHit: '击倒', isCancelable: false, notes: '大扫腿强击倒地，被防大确反'),
        FrameMove(name: '主力必杀技 (Special Move)', command: '236P/K', type: MoveType.special, damage: 1000, startup: '12', active: '4', recovery: '22', onBlock: '-6', onHit: '击倒', isCancelable: false, notes: '角色专属必杀技，连段与立回核心'),
        FrameMove(name: '主力对空技 (Anti-Air Special)', command: '623P/K', type: MoveType.special, damage: 1200, startup: '6', active: '5', recovery: '30', onBlock: '-20', onHit: '击倒', isCancelable: false, notes: '完全无敌对空必杀'),
        FrameMove(name: 'SA1: 超必杀技 Level 1', command: '236236P', type: MoveType.superArt, damage: 2000, startup: '9', active: '8', recovery: '40', onBlock: '-16', onHit: '击倒', isCancelable: false, notes: '1气无敌超必杀'),
        FrameMove(name: 'SA3: 终极超必杀 Level 3 / CA', command: '236236P/K', type: MoveType.superArt, damage: 4000, startup: '8', active: '12', recovery: '50', onBlock: '-25', onHit: '击倒', isCancelable: false, notes: '3气终极必杀爆发'),
      ]);
    }

    return moves;
  }
}
