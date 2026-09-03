import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/models/app_settings.dart';

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
}
