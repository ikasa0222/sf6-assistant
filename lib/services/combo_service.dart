// SF6 Combo Service
// Manages combo recipes, search/filter, and display modes

import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/data/sf6_combos_database.dart';
import 'package:sf6_tracker/models/combo_recipe.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';

class ComboService extends ChangeNotifier {
  String _selectedCharacterId = 'ryu';
  CommandDisplayMode _displayMode = CommandDisplayMode.graphic;
  String? _selectedStarterFilter; // null = all
  String _searchQuery = '';
  List<ComboRecipe> _currentCombos = [];
  bool _isLoading = false;

  String get selectedCharacterId => _selectedCharacterId;
  CommandDisplayMode get displayMode => _displayMode;
  String? get selectedStarterFilter => _selectedStarterFilter;
  String get searchQuery => _searchQuery;
  List<ComboRecipe> get currentCombos => _currentCombos;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await Sf6CombosDatabase.init();
    loadCombosForCharacter(_selectedCharacterId);
    _isLoading = false;
    notifyListeners();
  }

  void selectCharacter(String charId) {
    if (_selectedCharacterId == charId) return;
    _selectedCharacterId = charId;
    loadCombosForCharacter(charId);
  }

  void loadCombosForCharacter(String charId) {
    _selectedCharacterId = charId;
    _currentCombos = Sf6CombosDatabase.getCombosForCharacter(charId);
    notifyListeners();
  }

  void setDisplayMode(CommandDisplayMode mode) {
    _displayMode = mode;
    notifyListeners();
  }

  void setStarterFilter(String? starter) {
    if (_selectedStarterFilter == starter) {
      _selectedStarterFilter = null; // Toggle off
    } else {
      _selectedStarterFilter = starter;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  List<ComboRecipe> get filteredCombos {
    return _currentCombos.where((c) {
      // Starter filter
      if (_selectedStarterFilter != null) {
        final starterZh = c.starterZh;
        if (!starterZh.contains(_selectedStarterFilter!) &&
            !c.starterType.toLowerCase().contains(_selectedStarterFilter!.toLowerCase())) {
          return false;
        }
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final matchesSeq = c.comboSequence.toLowerCase().contains(_searchQuery);
        final matchesNotes = c.notes.toLowerCase().contains(_searchQuery);
        final matchesStarter = c.starterZh.toLowerCase().contains(_searchQuery);
        if (!matchesSeq && !matchesNotes && !matchesStarter) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
