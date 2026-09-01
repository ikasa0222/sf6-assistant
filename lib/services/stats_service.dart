import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/models/matchup_stat.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/core/storage/database_helper.dart';

class StatsService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<MatchupStat> _matchupStats = [];
  List<MatchupStat> _officialMatchupStats = [];
  List<MatchupStat> _localMatchupStats = [];
  List<Map<String, dynamic>> _ratingHistory = [];
  Map<String, int> _myCharacterCounts = {};
  String _selectedMyCharacterId = 'all';
  BattleType? _selectedBattleType;
  bool _useOfficialStats = true;
  bool _isLoading = false;

  List<MatchupStat> get matchupStats => _matchupStats;
  List<MatchupStat> get officialMatchupStats => _officialMatchupStats;
  List<MatchupStat> get localMatchupStats => _localMatchupStats;
  List<Map<String, dynamic>> get ratingHistory => _ratingHistory;
  Map<String, int> get myCharacterCounts => _myCharacterCounts;
  String get selectedMyCharacterId => _selectedMyCharacterId;
  BattleType? get selectedBattleType => _selectedBattleType;
  bool get useOfficialStats => _useOfficialStats;
  bool get hasOfficialStats => _officialMatchupStats.isNotEmpty;
  bool get isLoading => _isLoading;

  List<MatchupStat> get bestMatchups {
    final list = _matchupStats.where((m) => m.totalMatches >= 1).toList();
    list.sort((a, b) => b.winRate.compareTo(a.winRate));
    return list.take(3).toList();
  }

  List<MatchupStat> get worstMatchups {
    final list = _matchupStats.where((m) => m.totalMatches >= 1).toList();
    list.sort((a, b) => a.winRate.compareTo(b.winRate));
    return list.take(3).toList();
  }

  int get totalMatches => _matchupStats.fold(0, (sum, item) => sum + item.totalMatches);
  int get totalWins => _matchupStats.fold(0, (sum, item) => sum + item.wins);
  double get overallWinRate => totalMatches > 0 ? (totalWins / totalMatches) * 100.0 : 0.0;

  Future<void> loadStats({
    required String shortId,
    required String platform,
    String? myCharacterId,
    BattleType? battleType,
  }) async {
    _isLoading = true;
    notifyListeners();

    if (myCharacterId != null) {
      _selectedMyCharacterId = myCharacterId;
    }
    _selectedBattleType = battleType;

    _myCharacterCounts = await _db.getMyCharacterMatchCounts(
      shortId: shortId,
      platform: platform,
      battleType: _selectedBattleType,
    );

    _officialMatchupStats = await _db.getOfficialMatchupStats(
      shortId: shortId,
      platform: platform,
      myCharacterId: _selectedMyCharacterId,
    );

    _localMatchupStats = await _db.getMatchupStats(
      shortId: shortId,
      platform: platform,
      myCharacterId: _selectedMyCharacterId == 'all' ? null : _selectedMyCharacterId,
      battleType: _selectedBattleType,
    );

    if (_useOfficialStats && _officialMatchupStats.isNotEmpty) {
      _matchupStats = _officialMatchupStats;
    } else {
      _matchupStats = _localMatchupStats;
    }

    _ratingHistory = await _db.getRatingHistory(
      shortId: shortId,
      platform: platform,
      battleType: _selectedBattleType,
      limit: 30,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setStatsSource(bool useOfficial, {required String shortId, required String platform}) async {
    _useOfficialStats = useOfficial;
    if (_useOfficialStats && _officialMatchupStats.isNotEmpty) {
      _matchupStats = _officialMatchupStats;
    } else {
      _matchupStats = _localMatchupStats;
    }
    notifyListeners();
  }

  Future<void> selectMyCharacter(String charId, {required String shortId, required String platform}) async {
    _selectedMyCharacterId = charId;
    await loadStats(shortId: shortId, platform: platform, myCharacterId: charId, battleType: _selectedBattleType);
  }

  Future<void> selectBattleType(BattleType? type, {required String shortId, required String platform}) async {
    _selectedBattleType = type;
    await loadStats(shortId: shortId, platform: platform, myCharacterId: _selectedMyCharacterId, battleType: type);
  }
}
