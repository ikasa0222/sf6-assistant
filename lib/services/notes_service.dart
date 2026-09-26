import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/core/storage/database_helper.dart';
import 'package:sf6_tracker/models/player_note.dart';

class NotesService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<PlayerNote> _notes = [];
  bool _isLoading = false;

  List<PlayerNote> get notes => _notes;
  bool get isLoading => _isLoading;

  List<PlayerNote> getNotesForCharacter(String characterId) {
    final target = characterId.toLowerCase().trim();
    return _notes.where((n) => n.targetKey.toLowerCase() == target).toList();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await _db.getAllNotes();

    // Clean up any legacy dummy notes
    final legacyNote = _notes.where((n) => n.id == 'note_punk').toList();
    if (legacyNote.isNotEmpty) {
      await _db.deleteNote('note_punk');
      _notes.removeWhere((n) => n.id == 'note_punk');
    }

    // Seed comprehensive master notes if empty or incomplete
    if (_notes.length < 5) {
      final sampleNotes = _generateMasterStrategyNotes();
      for (final n in sampleNotes) {
        if (!_notes.any((existing) => existing.id == n.id)) {
          await _db.saveNote(n);
        }
      }
      _notes = await _db.getAllNotes();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrUpdateNote(PlayerNote note) async {
    await _db.saveNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _db.deleteNote(id);
    await loadNotes();
  }

  static List<PlayerNote> get defaultStrategyNotes => _generateMasterStrategyNotes();

  static List<PlayerNote> _generateMasterStrategyNotes() {
    final now = DateTime.now();
    return [
      PlayerNote(
        id: 'note_akuma',
        targetKey: 'akuma',
        isCharacterNote: true,
        title: '豪鬼 (Akuma) 对策要点',
        content: '1. 豪鬼血量仅 9000，连段务必选择大伤害路线或带入 CA 斩杀。\n2. 空中百鬼袭与斩空波动拳用 2HP 蹲重拳稳健对空击坠。\n3. 豪鬼 5HP 破防力极高，注意拉开距离打差合。\n4. 对方倒地起身极爱凹 OD 升龙，多打 Safe Jump (安全跳) 诱骗确反。',
        tags: ['对空', '差合', '血量劣势', '安全跳'],
        updatedAt: now,
      ),
      PlayerNote(
        id: 'note_ken',
        targetKey: 'ken',
        isCharacterNote: true,
        title: '肯 (Ken) 压制与龙尾脚破解',
        content: '1. 重龙尾脚发生24F，被防+1F有利，万万不可盲目出拳；建议在起跳空中直接截击，或预备反击斗气迸发。\n2. 紫电脚 TC (5MP>5HP) 是其最强确认连段，中距离注意下蹲防守。\n3. 迅雷脚有上中下三择派生，若对方爱打下段风镰蹴，注意下防并用 4F 抢招确反。',
        tags: ['反龙尾', '防迅雷', '确反'],
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      PlayerNote(
        id: 'note_ryu',
        targetKey: 'ryu',
        isCharacterNote: true,
        title: '隆 (Ryu) 波掌击与立回要诀',
        content: '1. 隆的电刃炼气蓄满后，波动拳与波掌击判定大幅提升，此时尽量拉开距离招架。\n2. 锁骨割 (6MP) 为 20F 中段，站防后隆处于 -1F 劣势，我方可直接抢攻。\n3. 鸠尾碎 (4HP) 被防 +1F 有利，切忌盲目乱动。',
        tags: ['波掌击', '锁骨割', '招架'],
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      PlayerNote(
        id: 'note_cammy',
        targetKey: 'cammy',
        isCharacterNote: true,
        title: '嘉米 (Cammy) 箭踢与俯冲对策',
        content: '1. 螺旋箭突进被防 -12F，直接 5HP 确反启动大连段。\n2. 空中加农空闪俯冲腿，判定落点如果在腰部以下则嘉米有利，在胸部以上我方有利直接抢 4F。\n3. 留心螺旋箭后绿冲压制，预备反向斗气迸发。',
        tags: ['确反', '箭踢落点', '反绿冲'],
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      PlayerNote(
        id: 'note_zangief',
        targetKey: 'zangief',
        isCharacterNote: true,
        title: '桑吉尔夫 (Zangief) 防抓与压制',
        content: '1. 绿冲 SPD 发生极快，中距离多用 5LK / 2MP 牵制截断其冲刺。\n2. 倒地起身时猜对方普通投或 SPD，可使用垂直跳或后跳避开，下落直接打最大伤害连段。\n3. 地狱头槌 (6HP) 被防 +4F 巨幅有利，防住后务必继续保持防御！',
        tags: ['防抓投', '跳跃躲避', '地狱头槌'],
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      PlayerNote(
        id: 'note_guile',
        targetKey: 'guile',
        isCharacterNote: true,
        title: '古烈 (Guile) 破铁壁波升指南',
        content: '1. 面对音速手刀牵制，多用斗气招架避免斗气槽被削减。\n2. 完美招架手刀后可快速绿冲拉近距离。\n3. 古烈倒立脚升龙判定范围大且完全无敌，切勿无脑跳入，建议在中距离多打 2MK 差合。',
        tags: ['波升流', '完美招架', '立回差合'],
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      PlayerNote(
        id: 'note_chunli',
        targetKey: 'chunli',
        isCharacterNote: true,
        title: '春丽 (Chun-Li) 构段与百裂脚拆解',
        content: '1. 行云流水构具备多种派生，但构切换需要时间，中距离可用长手长脚打断。\n2. 重百裂脚被防 -8F，属于确反点；若接 OD 百裂脚则被防 -2F。\n3. 警惕春丽 2MK 摸奖接绿冲，拉开距离或提前出轻招截击。',
        tags: ['破构', '百裂脚确反', '防绿冲'],
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      PlayerNote(
        id: 'note_luke',
        targetKey: 'luke',
        isCharacterNote: true,
        title: '卢克 (Luke) 闪电拳与沙弹应对',
        content: '1. 沙弹全屏极速命中，但硬直较长，中距离跳入可打大确反。\n2. 闪电重拳目押蓄力阶段被防 -4F，未蓄满可抢 4F 拳确反。\n3. 卢克 4HP 后退重拳专打拆投，近身压制建议多用延迟打拆。',
        tags: ['沙弹', '闪电拳', '打拆防范'],
        updatedAt: now.subtract(const Duration(hours: 7)),
      ),
      PlayerNote(
        id: 'note_juri',
        targetKey: 'juri',
        isCharacterNote: true,
        title: '韩蛛俐 (Juri) 风水引擎与压制',
        content: '1. 岁破冲贴地低速波跟进是核心压制套路，看到地波起手可提前出判定穿波或直接跳跃。\n2. 尽量在中距离压迫，阻止其安心用风破刃存气。\n3. 开启 SA2 风水引擎后，对手通常技无限取消，此时建议专注全防或择机反向斗气迸发。',
        tags: ['岁破冲', '风水引擎', '防压制'],
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
      PlayerNote(
        id: 'note_bison',
        targetKey: 'bison',
        isCharacterNote: true,
        title: '维加 (M. Bison) 精神爆弹与膝压应对',
        content: '1. 被植入精神爆弹后，对手后续招式会引发爆炸碎防，应主动拉开距离或用投技打断。\n2. 双重膝压 (4蓄6K) 被防 -5F，若对手未在最远距离命中，可立即出 4F/5F 拳确反。\n3. 恶魔倒转空降变轨时，建议垂直跳对空击落。',
        tags: ['精神爆弹', '膝压确反', '防空'],
        updatedAt: now.subtract(const Duration(hours: 9)),
      ),
      PlayerNote(
        id: 'note_marisa',
        targetKey: 'marisa',
        isCharacterNote: true,
        title: '玛丽莎 (Marisa) 霸体与防反盾破解',
        content: '1. 玛丽莎重拳与蓄力角斗士猛击带全身霸体，切勿盲目使用斗气迸发反抢。\n2. 斯库图姆防反盾 (22P) 只能格挡上中段攻击，用下蹲轻脚 (2LK) 或普通抓投可直接破盾！\n3. 角斗士猛击未蓄满时被防 -8F，可直接重连段确反。',
        tags: ['下段破盾', '普通投破霸体', '确反'],
        updatedAt: now.subtract(const Duration(hours: 10)),
      ),
      PlayerNote(
        id: 'note_jp',
        targetKey: 'jp',
        isCharacterNote: true,
        title: 'JP (JP) 全屏地刺与遗忘防反破除',
        content: '1. 全屏地刺 (22P) 发生 25F，观察其插杖动作前跳可越过地刺并跳入暴击。\n2. 遗忘防反 (22K) 第1帧防反打击，但对普通投毫无防御力，近身直接抓投！\n3. 一旦近身进入我方压制节奏，JP 没有无敌升龙，猛烈压起身打拆投即可。',
        tags: ['跳地刺', '普通投破防反', '近身狂攻'],
        updatedAt: now.subtract(const Duration(hours: 11)),
      ),
      PlayerNote(
        id: 'note_ed',
        targetKey: 'ed',
        isCharacterNote: true,
        title: '爱德 (Ed) 精神闪击与长鞭对策',
        content: '1. 精神拉扯长拳 (HP蓄力) 距离极长，蓄力时无霸体，快速绿冲或迸发可直接打断。\n2. 精神闪击拳被防 -4F，近身命中后可立刻用最速轻拳确反。\n3. 爱德起手对空依赖升龙拳，近距离多打逆向跳跃打背。',
        tags: ['打断长鞭', '闪击确反', '逆向跳跃'],
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      PlayerNote(
        id: 'note_terry',
        targetKey: 'terry',
        isCharacterNote: true,
        title: '泰瑞 (Terry) 燃烧指节与回旋波防范',
        content: '1. 燃烧指节 (214P) 突进速度快，但重版被防 -7F，近身被防必须确反。\n2. 裂破落 (214K) 是中段下落踢，下防容易漏防，看清动作站防。\n3. 能量波地波牵制时，注意用斗气招架推近立回距离。',
        tags: ['指节确反', '站防裂破落', '招架能量波'],
        updatedAt: now.subtract(const Duration(hours: 13)),
      ),
    ];
  }
}
