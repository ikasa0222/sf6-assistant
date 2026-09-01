import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/models/player_note.dart';
import 'package:sf6_tracker/core/storage/database_helper.dart';

class NotesService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<PlayerNote> _notes = [];
  bool _isLoading = false;

  List<PlayerNote> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await _db.getAllNotes();

    if (_notes.isEmpty) {
      final sampleNotes = _generateSampleNotes();
      for (final n in sampleNotes) {
        await _db.saveNote(n);
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

  static List<PlayerNote> _generateSampleNotes() {
    final now = DateTime.now();
    return [
      PlayerNote(
        id: 'note_akuma',
        targetKey: 'akuma',
        isCharacterNote: true,
        title: '豪鬼 (Akuma) 对策要点',
        content: '1. 豪鬼血量仅 9000，连段务必选择大伤害路线或带入 CA。\n2. 空中百鬼袭与斩空波动拳用 2HP 蹲重拳稳健对空。\n3. 豪鬼 5HP 破防力极高，注意拉开距离打差合。\n4. 对方倒地起身极爱凹 OD 升龙，多打 Safe Jump (安全跳) 诱骗。',
        tags: ['对空', '差合', '血量劣势', '安全跳'],
        updatedAt: now,
      ),
      PlayerNote(
        id: 'note_cammy',
        targetKey: 'cammy',
        isCharacterNote: true,
        title: '嘉米 (Cammy) 对策要点',
        content: '1. 箭踢突进被防 -12F，直接 5HP 确反启动连段。\n2. 空中箭踢判定落点如果在腰部以下则嘉米有利，在胸部以上我方有利直接抢 4F。\n3. 留心螺旋箭后绿冲压制，预备反向斗气迸发。',
        tags: ['确反', '箭踢落点', '反绿冲'],
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      PlayerNote(
        id: 'note_punk',
        targetKey: 'Punk_Da_God',
        isCharacterNote: false,
        title: '对战 Punk_Da_God 玩家习惯',
        content: '• 反应极快，中距离不要盲目放波动拳。\n• 极少无脑凹升龙，多用压键打拆投与延迟投。\n• 擅长在第3局红血时用 SA3 抓确反。',
        tags: ['反应怪', '立回压制', '打拆投'],
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
