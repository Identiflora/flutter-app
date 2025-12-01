import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

/// Store the user's ID on the device for later use
Future<void> saveUserID(int userID) async {
  await storage.write(key: 'userID', value: userID.toString());
}

/// Get the user's ID found on the device
Future<int?> getUserID() async {
  String? userIDStr = await storage.read(key: 'userID');
  return userIDStr != null ? int.tryParse(userIDStr) : null;
}

/// Delete the user's ID off of their device (good for login timeouts where they need to sign back in)
Future<void> deleteUserID() async {
  await storage.delete(key: 'userID');
}