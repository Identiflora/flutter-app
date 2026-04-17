import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:identiflora/user_data/history_utils.dart';

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

/// Store points earned while offline, to be flushed to the server on reconnect.
/// This is a delta (points to add), not the user's total.
Future<void> saveQueuedPts(int pts) async {
  await storage.write(key: 'points_queue', value: pts.toString());
}

/// Get the queued offline points delta.
Future<int?> getQueuedPts() async {
  String? str = await storage.read(key: 'points_queue');
  return str != null ? int.tryParse(str) : null;
}

/// Delete the queued offline points delta after it has been submitted.
Future<void> deleteQueuedPts() async {
  await storage.delete(key: 'points_queue');
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

/// Store the user history on the device for later use
Future<void> saveUserHistory(HistoryData identification) async {
  int? offlineHistoryID = await getOfflineUserHistoryCount();

  if(offlineHistoryID == null) {
    offlineHistoryID = 1;
  }
  else {
    offlineHistoryID = offlineHistoryID + 1;
  }

  await storage.write(key: 'history_$offlineHistoryID', value: jsonEncode(identification.toJson()));
  await saveOfflineUserHistoryCount(offlineHistoryID);
}

/// Get the user history found on the device
Future<List<HistoryData>?> getUserHistory() async {
  final int? offlineHistoryCount = await getOfflineUserHistoryCount();
  if(offlineHistoryCount == null) return null;

  List<HistoryData> userHistory = List.empty(growable: true);
  String? historyJson;
  HistoryData currentHistory;

  for(int i = 1; i <= offlineHistoryCount; i++) {
    historyJson = await storage.read(key: 'history_$i');
    if(historyJson == null) throw FormatException("Unable to get offline history for index $i");
  
    currentHistory = HistoryData.fromJson(jsonDecode(historyJson));
    userHistory.add(currentHistory);
  }

  return userHistory;
}

/// Delete the user history off of their device
Future<void> deleteUserHistory() async {
  final int? count = await getOfflineUserHistoryCount();
  if(count == null) return;
  for(int i = count; i > 0; i--) {
    await storage.delete(key: 'history_$i');
  }
  await deleteOfflineUserHistoryCount();
}

/// Store the user's offline history count on the device for later use
Future<void> saveOfflineUserHistoryCount(int count) async {
  await storage.write(key: 'history_count', value: count.toString());
}

/// Get the user's offline history count found on the device
Future<int?> getOfflineUserHistoryCount() async {
  String? historyCountStr = await storage.read(key: 'history_count');
  return historyCountStr != null ? int.tryParse(historyCountStr) : null;
}

/// Delete the user's offline history count off of their device
Future<void> deleteOfflineUserHistoryCount() async {
  await storage.delete(key: 'history_count');
}