import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/data/frame_data_database.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';

class FrameDataService extends ChangeNotifier {
  String _selectedCharacterId = 'elena';
  List<FrameMove> _currentMoves = [];
  bool _isLoading = false;
  String _searchQuery = '';
  MoveType? _selectedCategory;
  bool _filterOnlyPlusOnBlock = false;
  bool _filterOnlyPunishable = false;
  CommandDisplayMode _displayMode = CommandDisplayMode.graphic;

  String get selectedCharacterId => _selectedCharacterId;
  List<FrameMove> get currentMoves => _filteredMoves();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  MoveType? get selectedCategory => _selectedCategory;
  bool get filterOnlyPlusOnBlock => _filterOnlyPlusOnBlock;
  bool get filterOnlyPunishable => _filterOnlyPunishable;
  CommandDisplayMode get displayMode => _displayMode;

  void setDisplayMode(CommandDisplayMode mode) {
    _displayMode = mode;
    notifyListeners();
  }

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
    return FrameDataDatabase.getCharacterMoves(charId);
  }
}
