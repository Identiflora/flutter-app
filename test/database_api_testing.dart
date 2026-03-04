// @Timeout(Duration(minutes: 5))
// library;

// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:identiflora/database_utils.dart';
// import 'package:identiflora/environment.dart';
// import 'package:test/test.dart';



// !!! TESTS IN THIS FILE DO NOT CURRENTLY WORK AND CANNOT WORK DUE TO THIS BEING UNIT TESTING INSTEAD OF INTEGRATION TESTING !!!
// TO-DO: ADD INTEGRATION TESTING FOR API CALLS (if we want to)



// void main() async {
//   const bool useProduction = bool.fromEnvironment('PRODUCTION', defaultValue: true);

//   if(useProduction) {
//     await dotenv.load(fileName: '.env.production');
//   }
//   else {
//     await dotenv.load(fileName: '.env.development');
//   }

//   setUpAll(() {
//     FlutterSecureStorage.setMockInitialValues({});
//   });

//   debugPrint("All setup! Using API: ${Environment.apiUrl}");

//   group('Leaderboard tests', () {
//     test('User count should not be null', () async {
//       final int userCount = await fetchUserCount();
//       expect(userCount, isNotNull);
//     });

//     test('Leaderboard should not be null', () async {
//       final users = await submitGlobalLeaderboardRequest(leaderboardSize: 100);
//       expect(users, isNotNull);
//     });

//     test('Leaderboard should be equal to leaderboardSize submission or have equal users to user count', () async {
//       final users = await submitGlobalLeaderboardRequest(leaderboardSize: 100);
//       final int userCount = await fetchUserCount();
//       expect(users.length, anyOf(100, userCount));
//     });
//   });
// }