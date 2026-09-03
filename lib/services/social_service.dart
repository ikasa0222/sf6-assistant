import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/models/friend_model.dart';
import 'package:sf6_tracker/models/club_model.dart';

class SocialService extends ChangeNotifier {
  List<FriendModel> _friends = [];
  List<ClubModel> _clubs = [];
  int _selectedClubIndex = 0;
  bool _isLoading = false;

  List<FriendModel> get friends => _friends;
  List<ClubModel> get clubs => _clubs;
  int get selectedClubIndex => _selectedClubIndex;
  
  ClubModel? get club => activeClub;
  ClubModel? get activeClub {
    if (_clubs.isEmpty) return null;
    if (_selectedClubIndex >= 0 && _selectedClubIndex < _clubs.length) {
      return _clubs[_selectedClubIndex];
    }
    return _clubs.first;
  }
  
  bool get isLoading => _isLoading;

  int get onlineFriendsCount => _friends.where((f) => f.isOnline).length;
  int get onlineClubMembersCount {
    final cur = activeClub;
    if (cur == null) return 0;
    final countFromMembers = cur.members.where((m) => m.isOnline).length;
    return countFromMembers > 0 ? countFromMembers : cur.onlineMemberCount;
  }

  void selectClubIndex(int index) {
    if (index >= 0 && index < _clubs.length && index != _selectedClubIndex) {
      _selectedClubIndex = index;
      notifyListeners();
    }
  }

  void setClubsList(List<ClubModel> clubsList) {
    _clubs = List.from(clubsList);
    // Prefer selecting the main club if present
    final mainIdx = _clubs.indexWhere((c) => c.isMainClub);
    _selectedClubIndex = mainIdx != -1 ? mainIdx : 0;
    notifyListeners();
  }

  void setClubs(List<String> clubNames) {
    _clubs = clubNames
        .where((name) => name.trim().isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final idx = entry.key;
          final name = entry.value.trim();
          return ClubModel(
            clubId: 'club_${name.hashCode.abs()}',
            clubName: name,
            tag: name.length > 4 ? name.substring(0, 4).toUpperCase() : name.toUpperCase(),
            emblemUrl: '',
            notice: '',
            memberCount: 0,
            maxMemberCount: 100,
            totalMonthlyPoints: 0,
            isMainClub: idx == 0,
            onlineMemberCount: 0,
            members: [],
          );
        })
        .toList();
    _selectedClubIndex = 0;
    notifyListeners();
  }

  void setClub(String clubName, {String clubId = '', String notice = ''}) {
    if (clubName.trim().isEmpty) {
      _clubs = [];
      _selectedClubIndex = 0;
    } else {
      setClubs([clubName.trim()]);
    }
  }

  void setFriends(List<FriendModel> friendsList) {
    _friends = List.from(friendsList);
    notifyListeners();
  }

  Future<void> loadSocialData({String? clubName, List<String>? clubNames, String? shortId}) async {
    _isLoading = true;
    notifyListeners();

    if (shortId != null && shortId.isNotEmpty) {
      final savedFriendsJson = await StorageService.instance.getFriendsJson(shortId);
      final savedClubsJson = await StorageService.instance.getClubsJson(shortId);
      if (savedFriendsJson.isNotEmpty) {
        _friends = savedFriendsJson.map((e) => FriendModel.fromJson(e)).toList();
      }
      if (savedClubsJson.isNotEmpty) {
        _clubs = savedClubsJson.map((e) => ClubModel.fromJson(e)).toList();
      } else if (clubNames != null && clubNames.isNotEmpty) {
        setClubs(clubNames);
      } else if (clubName != null && clubName.trim().isNotEmpty) {
        setClubs([clubName.trim()]);
      } else {
        _clubs = [];
      }
    } else if (clubNames != null && clubNames.isNotEmpty) {
      setClubs(clubNames);
    } else if (clubName != null && clubName.trim().isNotEmpty) {
      setClubs([clubName.trim()]);
    } else {
      _clubs = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
