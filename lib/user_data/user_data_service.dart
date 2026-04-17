import 'package:identiflora/user_data/cache_utils.dart' as cache;
import 'package:identiflora/database_utils.dart' as api;

class UserDataService {
  static final UserDataService _inst = UserDataService._internal();
  factory UserDataService() => _inst;
  UserDataService._internal();

  int _points = 0;
  String _username = '';
  String _badgePath = 'assets/brand/Identiflora_logo.png';

  int get points => _points;
  String get username => _username;
  String get badgePath => _badgePath;

  Future<void> init() async {
    final token = await cache.getAuthToken();
    if (token == null) return;

    final cachedPts = await cache.getUserPts();
    final cachedUsername = await cache.getUsername();
    final cachedBadge = await cache.getUserBadge();
    if (cachedPts != null) _points = cachedPts;
    if (cachedUsername != null && cachedUsername.isNotEmpty) _username = cachedUsername;
    if (cachedBadge != null && cachedBadge.isNotEmpty) _badgePath = cachedBadge;

    _refreshFromApi();
  }

  Future<void> _refreshFromApi() async {
    try {
      final pts = await api.getUserPoints();
      final uname = await api.getUsername();
      final badge = await api.fetchUserBadge();
      _points = pts;
      _username = uname;
      if (badge.isNotEmpty) _badgePath = badge;
      await cache.saveUserPts(pts);
      await cache.saveUsername(uname);
      await cache.saveUserBadge(badge);
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

  void updateBadge(String path) => _badgePath = path;
  void updateUsername(String name) => _username = name;

  void clear() {
    _points = 0;
    _username = '';
    _badgePath = 'assets/brand/Identiflora_logo.png';
  }
}
