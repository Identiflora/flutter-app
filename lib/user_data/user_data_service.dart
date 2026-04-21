import 'package:identiflora/user_data/cache_utils.dart' as cache;
import 'package:identiflora/database_utils.dart' as api;

class UserDataService {
  static final UserDataService _inst = UserDataService._internal();
  factory UserDataService() => _inst;
  UserDataService._internal();

  int _points = 0;
  String _username = '';
  String _badgePath = 'assets/brand/Identiflora_logo.png';
  int _numFriends = 0;

  int get points => _points;
  String get username => _username;
  String get badgePath => _badgePath;
  int get numFriends => _numFriends;

  Future<void> init() async {
    final token = await cache.getAuthToken();
    if (token == null) return;

    final cachedPts = await cache.getUserPts();
    final cachedUsername = await cache.getUsername();
    final cachedBadge = await cache.getUserBadge();
    final cachedNumFriends = await cache.getUserNumFriends();
    if (cachedPts != null) _points = cachedPts;
    if (cachedUsername != null && cachedUsername.isNotEmpty) _username = cachedUsername;
    if (cachedBadge != null && cachedBadge.isNotEmpty) _badgePath = cachedBadge;
    if (cachedNumFriends != null) _numFriends = cachedNumFriends;

    refresh();
  }

  Future<void> refresh() async {
    try {
      final pts = await api.getUserPoints();
      final uname = await api.getUsername();
      final badge = await api.fetchUserBadge();
      final rawFriends = await api.fetchFriendsRaw();
      _points = pts;
      _username = uname;
      if (badge.isNotEmpty) _badgePath = badge;
      _numFriends = rawFriends.length;
      await cache.saveUserPts(pts);
      await cache.saveUsername(uname);
      await cache.saveUserBadge(badge);
      await cache.saveUserNumFriends(_numFriends);
    } catch (_) {}
  }

  Future<void> refreshPoints() async {
    try {
      final pts = await api.getUserPoints();
      _points = pts;
      await cache.saveUserPts(pts);
    } catch (_) {
      final cached = await cache.getUserPts();
      if (cached != null) _points = cached;
    }
  }

  Future<void> refreshNumFriends() async {
    try {
      final rawFriends = await api.fetchFriendsRaw();
      _numFriends = rawFriends.length;
      await cache.saveUserNumFriends(_numFriends);
    } catch (_) {
      final cached = await cache.getUserNumFriends();
      if (cached != null) _numFriends = cached;
    }
  }

  void updateBadge(String path) => _badgePath = path;
  void updateUsername(String name) => _username = name;
  void updateNumFriends(int n) => _numFriends = n;

  void clear() {
    _points = 0;
    _username = '';
    _badgePath = 'assets/brand/Identiflora_logo.png';
    _numFriends = 0;
  }
}
