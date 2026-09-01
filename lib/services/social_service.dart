import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/models/friend_model.dart';
import 'package:sf6_tracker/models/club_model.dart';

class SocialService extends ChangeNotifier {
  List<FriendModel> _friends = [];
  List<ClubModel> _clubs = [];
  bool _isLoading = false;

  List<FriendModel> get friends => _friends;
  List<ClubModel> get clubs => _clubs;
  ClubModel? get club => _clubs.isNotEmpty ? _clubs.first : null;
  bool get isLoading => _isLoading;

  int get onlineFriendsCount => _friends.where((f) => f.isOnline).length;
  int get onlineClubMembersCount => club?.members.where((m) => m.isOnline).length ?? 0;

  void setClubsList(List<ClubModel> clubsList) {
    _clubs = List.from(clubsList);
    notifyListeners();
  }

  void setClubs(List<String> clubNames) {
    _clubs = clubNames
        .where((name) => name.trim().isNotEmpty)
        .map((name) => ClubModel(
              clubId: 'club_${name.hashCode.abs()}',
              clubName: name.trim(),
              tag: name.length > 4 ? name.substring(0, 4).toUpperCase() : name.toUpperCase(),
              emblemUrl: '',
              notice: '欢迎加入 $name 俱乐部！保持活跃与切磋交流！',
              memberCount: 1,
              maxMemberCount: 100,
              totalMonthlyPoints: 0,
              members: [],
            ))
        .toList();
    notifyListeners();
  }

  void setClub(String clubName, {String clubId = '', String notice = ''}) {
    if (clubName.trim().isEmpty) {
      _clubs = [];
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
