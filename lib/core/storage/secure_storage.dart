import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/models/app_settings.dart';
import 'package:sf6_tracker/models/friend_model.dart';

class StorageService {
  static final StorageService instance = StorageService._init();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _keyAccounts = 'sf6_saved_accounts';
  static const String _keyActiveAccountId = 'sf6_active_account_id';
  static const String _keySettings = 'sf6_app_settings';

  StorageService._init();

  Future<List<CapcomAccount>> getAccounts() async {
    try {
      final jsonStr = await _secureStorage.read(key: _keyAccounts);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => CapcomAccount.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error reading accounts from secure storage: $e');
      return [];
    }
  }

  Future<void> saveAccounts(List<CapcomAccount> accounts) async {
    final list = accounts.map((a) => a.toJson()).toList();
    await _secureStorage.write(key: _keyAccounts, value: jsonEncode(list));
  }

  Future<void> addOrUpdateAccount(CapcomAccount account) async {
    final accounts = await getAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id || a.capcomId == account.capcomId);
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    await saveAccounts(accounts);
    await setActiveAccountId(account.id);
  }

  Future<void> deleteAccount(String accountId) async {
    final accounts = await getAccounts();
    accounts.removeWhere((a) => a.id == accountId);
    await saveAccounts(accounts);
    
    final currentActive = await getActiveAccountId();
    if (currentActive == accountId) {
      if (accounts.isNotEmpty) {
        await setActiveAccountId(accounts.first.id);
      } else {
        await _secureStorage.delete(key: _keyActiveAccountId);
      }
    }
  }

  Future<String?> getActiveAccountId() async {
    return await _secureStorage.read(key: _keyActiveAccountId);
  }

  Future<void> setActiveAccountId(String accountId) async {
    await _secureStorage.write(key: _keyActiveAccountId, value: accountId);
  }

  Future<CapcomAccount?> getActiveAccount() async {
    final accounts = await getAccounts();
    if (accounts.isEmpty) return null;
    final activeId = await getActiveAccountId();
    if (activeId == null) return accounts.first;
    return accounts.firstWhere((a) => a.id == activeId, orElse: () => accounts.first);
  }

  static const String _keyClub = 'sf6_club_name';

  Future<String> getClubName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyClub) ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> saveClubName(String clubName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyClub, clubName);
  }

  Future<AppSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keySettings);
      if (jsonStr == null || jsonStr.isEmpty) return const AppSettings();
      return AppSettings.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  Future<void> saveSocialData(String shortId, {List<Map<String, dynamic>>? friends, List<Map<String, dynamic>>? clubs}) async {
    final prefs = await SharedPreferences.getInstance();
    if (friends != null) {
      await prefs.setString('sf6_friends_$shortId', jsonEncode(friends));
    }
    if (clubs != null) {
      await prefs.setString('sf6_clubs_$shortId', jsonEncode(clubs));
    }
  }

  Future<List<Map<String, dynamic>>> getFriendsJson(String shortId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('sf6_friends_$shortId');
      if (str == null || str.isEmpty) return [];
      final list = jsonDecode(str) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getClubsJson(String shortId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('sf6_clubs_$shortId');
      if (str == null || str.isEmpty) return [];
      final list = jsonDecode(str) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRadarStatsJson(String shortId, Map<String, dynamic> stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sf6_radar_$shortId', jsonEncode(stats));
  }

  Future<Map<String, dynamic>?> getRadarStatsJson(String shortId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('sf6_radar_$shortId');
      if (str == null || str.isEmpty) return null;
      return Map<String, dynamic>.from(jsonDecode(str) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCharacterUsagesJson(String shortId, List<Map<String, dynamic>> usages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sf6_usages_$shortId', jsonEncode(usages));
  }

  Future<List<Map<String, dynamic>>> getCharacterUsagesJson(String shortId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('sf6_usages_$shortId');
      if (str == null || str.isEmpty) return [];
      final list = jsonDecode(str) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> getLastUpdateCheckDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('sf6_last_update_check_date');
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastUpdateCheckDate(String dateStr) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sf6_last_update_check_date', dateStr);
    } catch (_) {}
  }

  static const String _followedPlayersPrefKey = 'sf6_followed_short_ids';
  static const String _followedPlayersDataKey = 'sf6_followed_players_data';

  Future<List<FriendModel>> getFollowedPlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_followedPlayersDataKey);
      if (str == null || str.isEmpty) return [];
      final list = jsonDecode(str) as List;
      return list.map((e) => FriendModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFollowedPlayers(List<FriendModel> players) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = players.map((p) => p.toJson()).toList();
      await prefs.setString(_followedPlayersDataKey, jsonEncode(jsonList));
      final ids = players.map((p) => p.shortId.trim()).where((id) => id.isNotEmpty).toList();
      await prefs.setString(_followedPlayersPrefKey, jsonEncode(ids));
    } catch (_) {}
  }

  Future<List<String>> getFollowedShortIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_followedPlayersPrefKey);
      if (str == null || str.isEmpty) return [];
      final list = jsonDecode(str) as List;
      return list.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFollowedShortIds(List<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_followedPlayersPrefKey, jsonEncode(ids));
    } catch (_) {}
  }

  Future<bool> isFollowing(String shortId, [String? fighterId]) async {
    final sId = shortId.trim();
    final fId = (fighterId ?? '').trim().toLowerCase();
    if (sId.isEmpty && fId.isEmpty) return false;

    final players = await getFollowedPlayers();
    for (final p in players) {
      if (sId.isNotEmpty && p.shortId.trim() == sId) return true;
      if (fId.isNotEmpty && p.fighterId.trim().toLowerCase() == fId) return true;
    }

    if (sId.isNotEmpty) {
      final list = await getFollowedShortIds();
      if (list.contains(sId)) return true;
    }
    return false;
  }

  Future<bool> toggleFollowPlayer(FriendModel player) async {
    final sId = player.shortId.trim();
    final fId = player.fighterId.trim().toLowerCase();
    final players = await getFollowedPlayers();

    final existingIdx = players.indexWhere((p) {
      if (sId.isNotEmpty && p.shortId.trim() == sId) return true;
      if (fId.isNotEmpty && p.fighterId.trim().toLowerCase() == fId) return true;
      return false;
    });

    bool nowFollowed;
    if (existingIdx != -1) {
      players.removeAt(existingIdx);
      nowFollowed = false;
    } else {
      players.insert(0, player);
      nowFollowed = true;
    }
    await saveFollowedPlayers(players);
    return nowFollowed;
  }

  Future<bool> toggleFollow(String shortId, [FriendModel? fallbackPlayer]) async {
    final sId = shortId.trim();
    if (sId.isEmpty && fallbackPlayer == null) return false;
    if (fallbackPlayer != null) {
      return await toggleFollowPlayer(fallbackPlayer);
    }
    final list = await getFollowedShortIds();
    bool nowFollowed;
    if (list.contains(sId)) {
      list.remove(sId);
      nowFollowed = false;
    } else {
      list.insert(0, sId);
      nowFollowed = true;
    }
    await saveFollowedShortIds(list);
    return nowFollowed;
  }

  static const String _keyLastAnnouncementVersion = 'sf6_last_announcement_version';

  Future<String?> getLastSeenAnnouncementVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastAnnouncementVersion);
  }

  Future<void> setLastSeenAnnouncementVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastAnnouncementVersion, version);
  }
}
