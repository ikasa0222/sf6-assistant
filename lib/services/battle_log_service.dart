import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/user_profile.dart';
import 'package:sf6_tracker/core/storage/database_helper.dart';

import 'package:sf6_tracker/core/storage/secure_storage.dart';

class BattleLogService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<BattleRecord> _records = [];
  bool _isLoading = false;
  UserProfile? _userProfile;

  List<BattleRecord> get records => _records;
  bool get isLoading => _isLoading;
  UserProfile? get userProfile => _userProfile;

  int get recentWins => _records.take(20).where((r) => r.isWin).length;
  int get recentTotal => min(20, _records.length);
  double get recentWinRate => recentTotal > 0 ? (recentWins / recentTotal) * 100.0 : 0.0;
  List<bool> get recentForm => _records.take(10).map((r) => r.isWin).toList().reversed.toList();

  Future<void> loadRecords({
    required String shortId,
    required String platform,
    String fighterId = '',
    int? lp,
    int? mr,
    String? mainCharId,
    String? clubName,
    List<CharacterUsage>? characterUsages,
    BattleType? filterType,
    bool forceSync = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    _records = await _db.getBattleRecords(
      shortId: shortId,
      platform: platform,
      battleType: filterType,
      limit: 100,
    );

    final savedRadar = await StorageService.instance.getRadarStatsJson(shortId);
    final radarStats = savedRadar != null ? RadarStats.fromJson(savedRadar) : RadarStats.defaultStats();

    // Persist or restore characterUsages from local storage
    List<CharacterUsage> resolvedUsages = [];
    if (characterUsages != null && characterUsages.isNotEmpty) {
      resolvedUsages = characterUsages.where((u) => u.lp > 0 || u.mr > 0).toList();
      await StorageService.instance.saveCharacterUsagesJson(
        shortId,
        resolvedUsages.map((u) => u.toJson()).toList(),
      );
    } else {
      final savedUsagesJson = await StorageService.instance.getCharacterUsagesJson(shortId);
      if (savedUsagesJson.isNotEmpty) {
        resolvedUsages = savedUsagesJson
            .map((e) => CharacterUsage.fromJson(e))
            .where((u) => u.lp > 0 || u.mr > 0)
            .toList();
      }
    }

    _calculateProfileSummary(
      shortId,
      platform,
      fighterId: fighterId,
      initialLp: lp,
      initialMr: mr,
      mainCharId: mainCharId,
      clubName: clubName,
      characterUsages: resolvedUsages,
      radarStats: radarStats,
    );

    _isLoading = false;
    notifyListeners();
  }

  void _calculateProfileSummary(
    String shortId,
    String platform, {
    String fighterId = '',
    int? initialLp,
    int? initialMr,
    String? mainCharId,
    String? clubName,
    List<CharacterUsage>? characterUsages,
    RadarStats? radarStats,
  }) {
    final totalMatches = _records.length;
    final totalWins = _records.where((r) => r.isWin).length;
    final winRate = totalMatches > 0 ? (totalWins / totalMatches) * 100.0 : 0.0;

    int currentStreak = 0;
    bool currentStreakOngoing = true;
    int maxStreak = 0;
    int tempStreak = 0;

    for (final r in _records) {
      if (r.isWin) {
        if (currentStreakOngoing) currentStreak++;
        tempStreak++;
        if (tempStreak > maxStreak) maxStreak = tempStreak;
      } else {
        currentStreakOngoing = false;
        tempStreak = 0;
      }
    }

    final displayName = fighterId.trim().isNotEmpty
        ? fighterId.trim()
        : (shortId.isNotEmpty ? '玩家_$shortId' : '未登录玩家');

    final rawLp = initialLp ?? (_records.isNotEmpty ? (_records.first.playerCurrentLp ?? 0) : 0);
    final rawMr = initialMr ?? (_records.isNotEmpty ? (_records.first.playerCurrentMr ?? 0) : 0);
    final actualLp = rawLp > 0 ? rawLp : 0;
    final actualMr = rawMr > 0 ? rawMr : 0;

    final filteredUsages = (characterUsages ?? []).where((u) => u.lp > 0 || u.mr > 0).map((u) {
      if (u.matches == 0 && _records.isNotEmpty) {
        final cRecs = _records.where((r) => r.playerCharacterId.toLowerCase() == u.characterId.toLowerCase()).toList();
        if (cRecs.isNotEmpty) {
          final mCount = cRecs.length;
          final wCount = cRecs.where((r) => r.isWin).length;
          final wr = (wCount / mCount) * 100.0;
          return CharacterUsage(
            characterId: u.characterId,
            matches: mCount,
            wins: wCount,
            winRate: wr,
            lp: u.lp,
            mr: u.mr,
          );
        }
      }
      return u;
    }).toList();

    String resolvedMainChar = 'luke';
    if (mainCharId != null && mainCharId.trim().isNotEmpty) {
      resolvedMainChar = mainCharId.trim();
    } else if (filteredUsages.isNotEmpty) {
      resolvedMainChar = filteredUsages.first.characterId;
    } else if (_records.isNotEmpty && _records.first.playerCharacterId.isNotEmpty) {
      resolvedMainChar = _records.first.playerCharacterId;
    }

    int resolvedLp = actualLp;
    int resolvedMr = actualMr;
    if (filteredUsages.isNotEmpty) {
      CharacterUsage? mainUsage;
      for (final u in filteredUsages) {
        if (u.characterId.toLowerCase() == resolvedMainChar.toLowerCase()) {
          mainUsage = u;
          break;
        }
      }
      if (mainUsage != null && (mainUsage.lp > 0 || mainUsage.mr > 0)) {
        resolvedLp = mainUsage.lp;
        resolvedMr = mainUsage.mr;
      } else if (resolvedLp <= 0 && resolvedMr <= 0) {
        final sorted = List<CharacterUsage>.from(filteredUsages)..sort((a, b) => b.lp.compareTo(a.lp));
        resolvedLp = sorted.first.lp;
        resolvedMr = sorted.first.mr;
      }
    }

    final isMaster = resolvedMr > 0 || _records.any((r) => (r.playerCurrentMr ?? 0) > 0);

    _userProfile = UserProfile(
      shortId: shortId,
      fighterId: displayName,
      avatarUrl: '',
      title: isMaster ? 'Master Challenger' : 'Ranked Challenger',
      clubName: clubName ?? '',
      platform: platform,
      lp: resolvedLp,
      mr: resolvedMr,
      globalRank: null,
      mainCharacterId: resolvedMainChar,
      totalMatches: totalMatches,
      totalWins: totalWins,
      winRate: winRate,
      currentStreak: currentStreak,
      maxStreak: maxStreak > 0 ? maxStreak : currentStreak,
      characterUsages: filteredUsages,
      radarStats: radarStats ?? RadarStats.defaultStats(),
      updatedAt: DateTime.now(),
    );
  }
}
