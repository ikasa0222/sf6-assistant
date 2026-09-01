import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/models/user_profile.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';

class AuthService extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  
  List<CapcomAccount> _accounts = [];
  CapcomAccount? _activeAccount;
  bool _isLoading = false;

  List<CapcomAccount> get accounts => _accounts;
  CapcomAccount? get activeAccount => _activeAccount;
  bool get isLoggedIn => _activeAccount != null;
  bool get isLoading => _isLoading;

  PlatformProfile? get activePlatform => _activeAccount?.activePlatform;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _accounts = await _storage.getAccounts();
      _activeAccount = await _storage.getActiveAccount();
    } catch (e) {
      debugPrint('AuthService initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> switchAccount(String accountId) async {
    final account = _accounts.firstWhere((a) => a.id == accountId, orElse: () => _accounts.first);
    _activeAccount = account;
    await _storage.setActiveAccountId(accountId);
    notifyListeners();
  }

  Future<void> switchPlatform(int platformIndex) async {
    if (_activeAccount == null) return;
    if (platformIndex >= 0 && platformIndex < _activeAccount!.linkedPlatforms.length) {
      _activeAccount = _activeAccount!.copyWith(activePlatformIndex: platformIndex);
      await _storage.addOrUpdateAccount(_activeAccount!);
      notifyListeners();
    }
  }

  Future<void> updateActiveProfile({
    required String fighterId,
    required String shortId,
    required PlatformType platformType,
    required int lp,
    required int mr,
    String? mainCharId,
    String? clubName,
    List<CharacterUsage>? characterUsages,
  }) async {
    final cleanShortId = shortId.trim();
    final cleanFighterId = fighterId.trim().isNotEmpty ? fighterId.trim() : 'Fighter_$cleanShortId';

    final updatedPlatform = PlatformProfile(
      platformType: platformType,
      shortId: cleanShortId,
      fighterId: cleanFighterId,
      avatarUrl: _activeAccount?.activePlatform?.avatarUrl ?? '',
      currentLp: lp > 0 ? lp : 0,
      currentMr: mr > 0 ? mr : 0,
      clubName: clubName ?? _activeAccount?.activePlatform?.clubName ?? '',
      mainCharId: mainCharId ?? _activeAccount?.activePlatform?.mainCharId ?? '',
      characterUsages: characterUsages ?? _activeAccount?.activePlatform?.characterUsages ?? const [],
    );

    final currentId = _activeAccount?.id ?? 'acc_$cleanShortId';
    final updatedAccount = CapcomAccount(
      id: currentId,
      capcomId: cleanShortId,
      displayName: cleanFighterId,
      cookieSession: _activeAccount?.cookieSession ?? '',
      linkedPlatforms: [updatedPlatform],
      activePlatformIndex: 0,
      lastLoginAt: DateTime.now(),
    );

    await _storage.addOrUpdateAccount(updatedAccount);
    _accounts = await _storage.getAccounts();
    _activeAccount = updatedAccount;
    notifyListeners();
  }

  Future<void> addAccountFromShortId({
    required String shortId,
    required String fighterId,
    required PlatformType platformType,
    int lp = 0,
    int mr = 0,
    String mainCharId = 'luke',
    String clubName = '',
    List<CharacterUsage>? characterUsages,
  }) async {
    final cleanShortId = shortId.trim();
    final cleanFighterId = fighterId.trim().isNotEmpty ? fighterId.trim() : 'SF6_Player';

    final platform = PlatformProfile(
      platformType: platformType,
      shortId: cleanShortId,
      fighterId: cleanFighterId,
      avatarUrl: '',
      currentLp: lp,
      currentMr: mr,
      clubName: clubName,
      mainCharId: mainCharId,
      characterUsages: characterUsages ?? const [],
    );

    final newAccount = CapcomAccount(
      id: 'acc_$cleanShortId',
      capcomId: cleanShortId,
      displayName: cleanFighterId,
      cookieSession: '',
      linkedPlatforms: [platform],
      activePlatformIndex: 0,
      lastLoginAt: DateTime.now(),
    );

    await _storage.addOrUpdateAccount(newAccount);
    _accounts = await _storage.getAccounts();
    _activeAccount = newAccount;
    notifyListeners();
  }

  Future<void> addAccountFromLogin({
    required String capcomId,
    required String displayName,
    required String cookieSession,
    required List<PlatformProfile> platforms,
  }) async {
    final newAccount = CapcomAccount(
      id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
      capcomId: capcomId,
      displayName: displayName,
      cookieSession: cookieSession,
      linkedPlatforms: platforms,
      activePlatformIndex: 0,
      lastLoginAt: DateTime.now(),
    );

    await _storage.addOrUpdateAccount(newAccount);
    _accounts = await _storage.getAccounts();
    _activeAccount = newAccount;
    notifyListeners();
  }

  Future<void> logoutAccount(String accountId) async {
    await _storage.deleteAccount(accountId);
    _accounts = await _storage.getAccounts();
    _activeAccount = await _storage.getActiveAccount();
    notifyListeners();
  }
}
