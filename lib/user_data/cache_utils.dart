import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

/// Store the user's auth token on the device for later use
Future<void> saveAuthToken(String token) async {
  await storage.write(key: 'authToken', value: token.toString());
}

/// Get the user's auth token found on the device
Future<String?> getAuthToken() async {
  String? authTokenStr = await storage.read(key: 'authToken');
  return authTokenStr;// if not found will return null
}

/// Delete the user's auth token off of their device (good for login timeouts where they need to sign back in)
Future<void> deleteAuthToken() async {
  await storage.delete(key: 'authToken');
}

/// Store the user's username on the device for later use
Future<void> saveUsername(String username) async {
  await storage.write(key: 'username', value: username);
}

/// Get the user's username found on the device
Future<String?> getUsername() async {
  String? usernameStr = await storage.read(key: 'username');
  return usernameStr;
}

/// Delete the user's username off of their device
Future<void> deleteUsername() async {
  await storage.delete(key: 'username');
}

/// Store the user's points on the device for later use
Future<void> saveUserPts(int pts) async {
  await storage.write(key: 'points', value: pts.toString());
}

/// Get the user's points found on the device
Future<int?> getUserPts() async {
  String? userPtsStr = await storage.read(key: 'points');
  return userPtsStr != null ? int.tryParse(userPtsStr) : null;
}

/// Delete the user's points off of their device
Future<void> deleteUserPts() async {
  await storage.delete(key: 'points');
}

/// Store the user's badge filepath on the device for later use
Future<void> saveUserBadge(String badgePath) async {
  await storage.write(key: 'badge_path', value: badgePath);
}

/// Get the user's username found on the device
Future<String?> getUserBadge() async {
  String? badgePathStr = await storage.read(key: 'badge_path');
  return badgePathStr;
}

/// Delete the user's username off of their device
Future<void> deleteUserBadge() async {
  await storage.delete(key: 'badge_path');
}

/// Store the user's points on the device for later use
Future<void> saveUserNumFriends(int numFriends) async {
  await storage.write(key: 'num_friends', value: numFriends.toString());
}

/// Get the user's points found on the device
Future<int?> getUserNumFriends() async {
  String? numFriendsStr = await storage.read(key: 'num_friends');
  return numFriendsStr != null ? int.tryParse(numFriendsStr) : null;
}

/// Delete the user's points off of their device
Future<void> deleteUserNumFriends() async {
  await storage.delete(key: 'num_friends');
}